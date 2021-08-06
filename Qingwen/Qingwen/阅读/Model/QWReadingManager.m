//
//  QWReadingManager.m
//  Qingwen
//
//  Created by Aimy on 7/27/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWReadingManager.h"

#import "QWNetworkManager.h"
#import "QWCoreTextHelper.h"
#import "QWInterface.h"
#import "QWFileManager.h"
#import "QWReadingVC.h"
#import "BookCD.h"
#import "VolumeCD.h"
#import "QWBaseLogic.h"
#import "QWJsonKit.h"
#import "VolumeList.h"

@interface QWReadingManager ()

@property (nonatomic, strong, nullable) BookPageVO *currentPage;
@property (nonatomic, strong, nullable) BookCD *bookCD;
@property (nonatomic, strong, nullable) VolumeList *volumes;//当前卷VO

@property (nonatomic, strong) QWOperationManager *operationManager;

@property (nonatomic) BOOL start;//阅读开始

@end

@implementation QWReadingManager

DEF_SINGLETON(QWReadingManager);

- (QWOperationManager *)operationManager
{
    if (!_operationManager) {
        _operationManager = [[QWNetworkManager sharedInstance] generateoperationManagerWithOwner:self];
    }

    return _operationManager;
}

- (void)startOnlineReadingWithBookId:(NSNumber * __nonnull)bookId volumes:(VolumeList * __nonnull)volumes
{
    NSAssert(bookId, @"bookId 不能为空");
    NSAssert(volumes, @"volumes 不能为空");

    if (self.start) {
        [self stopReading];
    }

    self.volumes = volumes;
    [self.volumes configDirectory];

    self.bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == NO", bookId] inContext:[QWFileManager qwContext]];
    NSAssert(self.bookCD, @"bookCD 不能为空");

    self.start = YES;
    self.offline = NO;
}

- (void)startOfflineReadingWithBookId:(NSNumber * __nonnull)bookId volumes:(VolumeList * __nonnull)volumes
{
    NSAssert(bookId, @"bookId 不能为空");
    NSAssert(volumes, @"volumes 不能为空");

    if (self.start) {
        [self stopReading];
    }

    self.volumes = volumes;
    [self.volumes configOfflineDirectoryWithBookId:bookId.stringValue];

    self.bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == NO", bookId] inContext:[QWFileManager qwContext]];;
    NSAssert(self.bookCD, @"bookCD 不能为空");

    self.offline = YES;
    self.start = YES;
}

- (void)stopReading
{
    [self.operationManager.operationQueue cancelAllOperations];//停止下载内容

    //存储进度
    [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];

    self.bookCD = nil;
    self.volumes = nil;
    self.currentPage = nil;
    self.offline = NO;
    self.start = NO;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"didReceiveMemoryWarning");
    [self.volumes.results enumerateObjectsUsingBlock:^(VolumeVO * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        VolumeCD *volumeCD = [VolumeCD MR_findFirstByAttribute:@"nid" withValue:obj.nid inContext:[QWFileManager qwContext]];
        NSInteger chapterIndex = volumeCD.chapterIndex.integerValue;
        BOOL clearAll = !self.currentPage.volumeId || (! [obj.nid isEqualToNumber:self.currentPage.volumeId]);
        [obj.chapter enumerateObjectsUsingBlock:^(ChapterVO * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (clearAll || idx != chapterIndex) {
                [obj clearChapter];
            }
        }];
    }];
}

- (VolumeVO *)currentVolumeVO
{
    return [self.volumes.results filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"nid == %@", self.currentPage.volumeId]].firstObject;
}

- (VolumeCD *)currentVolumeCD
{
    return [VolumeCD MR_findFirstByAttribute:@"nid" withValue:self.currentPage.volumeId inContext:[QWFileManager qwContext]];
}

#pragma mark - 弹幕状态

- (NSString *)recordBookFileName {
    NSString *path = [[QWFileManager qingwenPath] stringByAppendingPathComponent:@"bookDanmu_record.plist"];
    return path;
}

- (void)recordBookDanmuStatus:(BOOL)status {
    NSMutableArray *recordArray = [NSMutableArray arrayWithContentsOfFile:[self recordBookFileName]];
    if (!recordArray) {
        recordArray = [NSMutableArray array];
    }
    if (status) {//记录
        if ([recordArray containsObject:self.bookCD.nid]) {
            return;
        }
        else {
            [recordArray addObject:self.bookCD.nid];
        }
    }
    else { //删除
        if ([recordArray containsObject:self.bookCD.nid]) {
            [recordArray removeObject:self.bookCD.nid];
        }
        else {
            return;
        }
    }
    [recordArray writeToFile:[self recordBookFileName] atomically:YES];
}

- (BOOL)isOpenDanmu {
    NSArray *recordArray = [NSArray arrayWithContentsOfFile:[self recordBookFileName]];
    if ([recordArray containsObject:self.bookCD.nid]) {
        return false;
    }
    else {
        return true;
    }
}

#pragma mark - 获取内容

- (QWReadingVC *)getPageAtIndex:(NSInteger)index readingVC:(QWReadingVC *)currentVC
{
    if (!self.start) {
        return nil;
    }

    if (currentVC.isLoading) {
        return nil;
    }

    VolumeVO *volume = self.currentVolumeVO;
    ChapterVO *chapter = volume.chapter[currentVC.currentPage.chapterIndex];
    BookPageVO *page = chapter.bookPages[@(index)];
    NSLog(@"跳转到%@",page);

    QWReadingVC *vc = [currentVC.storyboard instantiateViewControllerWithIdentifier:@"readingvc"];
    vc.currentPage = page;
    return vc;
}

- (QWReadingVC *)getNextChapterReadingVCWithCurrentReadingVC:(QWReadingVC *)currentVC
{
    if (!self.start) {
        return nil;
    }

    if (currentVC.isLoading) {
        return nil;
    }

    VolumeVO *volume = self.currentVolumeVO;
    if (currentVC.currentPage.chapterIndex + 1 < volume.chapter.count) {
        NSLog(@"下一章");
        self.currentVolumeCD.chapterIndex = @(currentVC.currentPage.chapterIndex + 1);
        self.currentVolumeCD.location = @0;
    }
    else if (self.volumes.results.lastObject != volume) {
        NSLog(@"下一卷的第一章");
        VolumeVO *nextVolume = self.volumes.results[[self.volumes.results indexOfObject:volume] + 1];
        self.currentPage.volumeId = nextVolume.nid;
        if (!self.currentVolumeCD) {
            VolumeCD *volumeCD = [VolumeCD MR_createEntityInContext:[QWFileManager qwContext]];
            [volumeCD updateWithVolumeVO:nextVolume bookId:self.bookCD.nid];
        }
        self.currentVolumeCD.chapterIndex = @0;
        self.currentVolumeCD.location = @0;
    }
    else {
        NSLog(@"没有下一章了");
        return nil;
    }

    [self.currentVolumeCD setReading];

    QWReadingVC *vc = [currentVC.storyboard instantiateViewControllerWithIdentifier:@"readingvc"];
    return vc;
}

- (QWReadingVC *)getPreviousChapterReadingVCWithCurrentReadingVC:(QWReadingVC *)currentVC
{
    if (!self.start) {
        return nil;
    }

    if (currentVC.isLoading) {
        return nil;
    }

    VolumeVO *volume = self.currentVolumeVO;
    if (currentVC.currentPage.chapterIndex > 0) {
        NSLog(@"上一章");
        self.currentVolumeCD.chapterIndex = @(currentVC.currentPage.chapterIndex - 1);
        self.currentVolumeCD.location = @0;
    }
    else if (self.volumes.results.firstObject != volume) {
        NSLog(@"上一卷的最后一章");
        VolumeVO *previousVolume = self.volumes.results[[self.volumes.results indexOfObject:volume] - 1];
        self.currentPage.volumeId = previousVolume.nid;
        if (!self.currentVolumeCD) {
            VolumeCD *volumeCD = [VolumeCD MR_createEntityInContext:[QWFileManager qwContext]];
            [volumeCD updateWithVolumeVO:previousVolume bookId:self.bookCD.nid];
        }
        self.currentVolumeCD.chapterIndex = @(previousVolume.chapter.count - 1);
        self.currentVolumeCD.location = @0;
    }
    else {
        NSLog(@"没有上一章了");
        return nil;
    }

    [self.currentVolumeCD setReading];

    QWReadingVC *vc = [currentVC.storyboard instantiateViewControllerWithIdentifier:@"readingvc"];
    return vc;
}

- (QWReadingVC *)getChapterReadingVCWithBook:(BookVO *)book volumes:(VolumeList *)volumes indexPath:(NSIndexPath *)indexPath currentVC:(QWReadingVC *)currentVC{
    VolumeVO *volume = volumes.results[indexPath.section];
    volume.collection = book.collection;
    if (!self.start) {
        return nil;
    }
    
    if (currentVC.isLoading) {
        return nil;
    }
    {
    VolumeCD *volumeCD = [VolumeCD MR_findFirstByAttribute:@"nid" withValue:volume.nid inContext:[QWFileManager qwContext]];
    if (!volumeCD) {
        volumeCD = [VolumeCD MR_createEntityInContext:[QWFileManager qwContext]];
        [volumeCD updateWithVolumeVO:volume bookId:book.nid];
        volumeCD.chapterIndex = @0;
        volumeCD.location = @0;
    }
    
    if (indexPath && volumeCD.chapterIndex && volumeCD.chapterIndex.integerValue != indexPath.row - 1) {//如果读的不是这个章节，则写成这个章节
        volumeCD.chapterIndex = @(indexPath.row - 1);
        volumeCD.location = @0;
    }
    
    [volumeCD setReading];
    
    [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];
    }
    QWReadingVC *vc = [currentVC.storyboard instantiateViewControllerWithIdentifier:@"readingvc"];
    return vc;
}
- (QWReadingVC *)getChapterReadingVCWithChapterIndex:(NSInteger)index currentVC:(QWReadingVC *)currentVC
{
    
    if (!self.start) {
        return nil;
    }

    if (currentVC.isLoading) {
        return nil;
    }

    self.currentVolumeCD.chapterIndex = @(index);
    self.currentVolumeCD.location = @0;

    [self.currentVolumeCD setReading];

    QWReadingVC *vc = [currentVC.storyboard instantiateViewControllerWithIdentifier:@"readingvc"];
    return vc;
}

- (QWReadingVC *)getNextPageReadingVCWithCurrentReadingVC:(QWReadingVC *)currentVC
{
    if (!self.start) {
        return nil;
    }

    QWReadingVC *vc = [currentVC.storyboard instantiateViewControllerWithIdentifier:@"readingvc"];

    vc.previousPage = currentVC.currentPage;
    vc.currentPage = currentVC.nextPage;

    vc.nextPage = [self.volumes getNextPageWithPage:currentVC.nextPage];

    NSLog(@"\n");
    NSLog(@"===================");
    NSLog(@"%@ <- %@ -> %@",vc.previousPage, vc.currentPage, vc.nextPage);
    NSLog(@"===================");
    NSLog(@"\n");
    return vc;
}

- (QWReadingVC *)getPreviousPageReadingVCWithCurrentReadingVC:(QWReadingVC *)currentVC
{
    if (!self.start) {
        return nil;
    }
    
    QWReadingVC *vc = [currentVC.storyboard instantiateViewControllerWithIdentifier:@"readingvc"];

    vc.nextPage = currentVC.currentPage;
    vc.currentPage = currentVC.previousPage;
    vc.previousPage = [self.volumes getPreviousPageWithPage:currentVC.previousPage];

    NSLog(@"\n");
    NSLog(@"===================");
    NSLog(@"%@ <- %@ -> %@",vc.previousPage, vc.currentPage, vc.nextPage);
    NSLog(@"===================");
    NSLog(@"\n");

    return vc;
}

- (void)configReadingContentWithReadingVC:(QWReadingVC *)readingVC
{
    QWReadingVC *vc = readingVC;

    if (vc.currentPage.pageIndex == NSNotFound) {//当只知道location，而不知道pageindex的时候使用
        NSInteger pageIndex = [self getPageIndexWithPage:vc.currentPage];
        VolumeVO *volume = self.currentVolumeVO;
        ChapterVO *chapter = volume.chapter[vc.currentPage.chapterIndex];
        vc.currentPage = chapter.bookPages[@(pageIndex)];
    }

    if (vc.currentPage.pageIndex == -1 || vc.currentPage.range.location == NSNotFound) {//不知道pageIndex所以是最后一页
        VolumeVO *volume = self.currentVolumeVO;
        ChapterVO *chapter = volume.chapter[vc.currentPage.chapterIndex];
        vc.currentPage = chapter.bookPages[@(chapter.pageCount - 1)];
    }

    vc.nextPage = [self.volumes getNextPageWithPage:vc.currentPage];
    vc.previousPage = [self.volumes getPreviousPageWithPage:vc.currentPage];

    NSLog(@"\n");
    NSLog(@"configReadingContentWithReadingVC");
    NSLog(@"===================");
    NSLog(@"%@ <- %@ -> %@",vc.previousPage, vc.currentPage, vc.nextPage);
    NSLog(@"===================");
    NSLog(@"");
}

- (void)getReadingContentWithReadingVC:(QWReadingVC *)readingVC andCompleteBlock:(QWReadingContentCompletionBlock)aBlock
{
    if (!self.start) {
        return ;
    }

    if (!readingVC.currentPage) {//如果没有当前的page，那么这个vc应该就是跳转进度的，或者继续阅读的
        VolumeCD *volumeCD = [VolumeCD findLastReadingVolumeWithBookId:self.bookCD.nid];
        readingVC.currentPage = [BookPageVO new];
        readingVC.currentPage.volumeId = volumeCD.nid;
        readingVC.currentPage.chapterIndex = volumeCD.chapterIndex.integerValue;
//        NSLog(@"volumeCD.chapterIndex.integerValue = %ld",(long)volumeCD.chapterIndex.integerValue);
        readingVC.currentPage.range = NSMakeRange(volumeCD.location.integerValue, 0);
        if (volumeCD.location.integerValue == 0) {
            readingVC.currentPage.pageIndex = 0;
        }
        else {
            readingVC.currentPage.pageIndex = NSNotFound;
        }
    }

    self.currentPage = readingVC.currentPage;
    
    VolumeVO *volume = self.currentVolumeVO;
    ChapterVO *chapter = volume.chapter[self.currentPage.chapterIndex];
    
    WEAK_SELF;

    if (self.currentPage.pageIndex == 0) {
        if (aBlock) {
            aBlock(kQWPlaceholderChapterAttributeName, QWReadingContentTypeChapter);
        }
    }

    void (^configDataBlock)() = [^() {//从网络取数据
        STRONG_SELF;
        [self performInThreadBlock:^{
            if (!chapter.isCompleted) {
                [chapter configChapter];
                
            }
            
            [self configReadingContentWithReadingVC:readingVC];

            [self getPageWithReadingVC:readingVC andCompleteBlock:^(id __nullable content, QWCoreTextContentType type) {
                STRONG_SELF;

                [self saveReadingProgressWithReadingVC:readingVC];

                [self performInMainThreadBlock:^{
                    STRONG_SELF;
                    if (aBlock) {
                        switch (type) {
                            case QWCoreTextContentTypeContent:
                                aBlock(content, QWReadingContentTypeContent);
                                break;
                            case QWCoreTextContentTypeCustom:
                            {
                                if ([content isKindOfClass:[NSString class]] && [kQWPlaceholderChapterAttributeName isEqualToString:content]) {
                                    aBlock(content, QWReadingContentTypeChapterDone);
                                }
                                else {
                                    if (self.offline) {
                                        aBlock(content, QWReadingContentTypeImage);
                                    }
                                    else {
                                        aBlock(content, QWReadingContentTypeNetImage);
                                    }
                                }
                            }
                                break;
                            default:
                                aBlock([NSError errorWithDomain:@"core text error" code:999 userInfo:nil], QWReadingContentTypeError);
                                break;
                        }
                    }
                }];
            }];
        }];
    } copy];

    void (^getContentBlock)() = [^() {//从网络取数据
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"limit"] = @(READING_CONTENT_PAGE_SIZE);//计算出一个屏幕大概显示的行数
        params[@"offset"] = @(chapter.contentVO.results.count);
        params[@"device_id"] = [QWGlobalValue sharedInstance].deviceToken;
        if (readingVC.wacthAdData != nil) {
            params[@"ad_key"] = readingVC.wacthAdData;
            readingVC.isSubscribe = NO;
        }
        if (chapter.type.integerValue == 2 || [QWGlobalValue sharedInstance].isLogin) {
            params[@"token"] = [QWGlobalValue sharedInstance].token;
            QWOperationParam *param = [QWInterface getWithUrl:chapter.content_url params:params andCompleteBlock:^(id aResponseObject, NSError *anError){
                if (aResponseObject && !anError) {
                    STRONG_SELF;
                    [self performInThreadBlock:^{
                        STRONG_SELF;
                        chapter.contentVO = [ContentVO voWithDict:aResponseObject];
                        chapter.amount = [aResponseObject objectForKey:@"amount"];
                        chapter.points = [aResponseObject objectForKey:@"points"];
                        chapter.battle = [aResponseObject objectForKey:@"battle"];
                        chapter.amount_coin = [aResponseObject objectForKey:@"amount_coin"];
                        chapter.can_use_voucher = [aResponseObject objectForKey:@"can_use_voucher"];
                        chapter.buy_type = [aResponseObject objectForKey:@"buy_type"];
                        chapter.volume_amount_coin = [aResponseObject objectForKey:@"volume_amount_coin"];
                        chapter.volume_battle = [aResponseObject objectForKey:@"volume_battle"];
                        chapter.volume_chapter_count = [aResponseObject objectForKey:@"volume_chapter_count"];
                        chapter.volume_need_amount = [aResponseObject objectForKey:@"volume_need_amount"];
                        chapter.volume_points = [aResponseObject objectForKey:@"volume_points"];
                        configDataBlock();
                    }];
                }
                else {
#ifndef DEBUG
                    if (anError.code == 404) {//内容不存在导致
                        StatisticVO *statistic = [StatisticVO new];
                        statistic.bookId = self.bookCD.nid.stringValue;
                        statistic.chapterId = chapter.nid.stringValue;
                        statistic.contentUrl = chapter.content_url;
                        [[BaiduMobStat defaultStat] logEvent:@"content404" eventLabel:statistic.toJSONString];
                    }
#endif
                    if (aBlock) {
                        aBlock(anError, QWReadingContentTypeError);
                    }
                }

            }];
//            param.printLog = NO;
            param.requestType = QWRequestTypePost;
            [self.operationManager requestWithParam:param];
        } else  {
            QWOperationParam *param = [QWInterface getWithUrl:chapter.content_url params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
                if (aResponseObject && !anError) {
                    STRONG_SELF;
                    [self performInThreadBlock:^{
                        STRONG_SELF;
                        chapter.contentVO = [ContentVO voWithDict:aResponseObject];
                        chapter.amount = [aResponseObject objectForKey:@"amount"];
                        chapter.points = [aResponseObject objectForKey:@"points"];
                        chapter.battle = [aResponseObject objectForKey:@"battle"];
                        chapter.amount_coin = [aResponseObject objectForKey:@"amount_coin"];
                        chapter.can_use_voucher = [aResponseObject objectForKey:@"can_use_voucher"];
                        chapter.buy_type = [aResponseObject objectForKey:@"buy_type"];
                        chapter.volume_amount_coin = [aResponseObject objectForKey:@"volume_amount_coin"];
                        chapter.volume_battle = [aResponseObject objectForKey:@"volume_battle"];
                        chapter.volume_chapter_count = [aResponseObject objectForKey:@"volume_chapter_count"];
                        chapter.volume_need_amount = [aResponseObject objectForKey:@"volume_need_amount"];
                        chapter.volume_points = [aResponseObject objectForKey:@"volume_points"];
                        configDataBlock();
                    }];
                }
                else {
#ifndef DEBUG
                    if (anError.code == 404) {//内容不存在导致
                        StatisticVO *statistic = [StatisticVO new];
                        statistic.bookId = self.bookCD.nid.stringValue;
                        statistic.chapterId = chapter.nid.stringValue;
                        statistic.contentUrl = chapter.content_url;
                        [[BaiduMobStat defaultStat] logEvent:@"content404" eventLabel:statistic.toJSONString];
                    }
#endif
                    if (aBlock) {
                        aBlock(anError, QWReadingContentTypeError);
                    }
                }
            }];
            
//            param.printLog = NO;
            
            [self.operationManager requestWithParam:param];
        }
        
    } copy];

    //如果没有content则加载, 没有加载完也要加载
    if (!chapter.contentVO || (chapter.contentVO.results.count < chapter.contentVO.count.integerValue)) {
        if (self.offline) {//从下载过来，直接从硬盘取
            [self performInThreadBlock:^{
                STRONG_SELF;
                NSData *contentData = [[QWFileManager loadContentWithBookId:self.bookCD.nid.stringValue volumeId:volume.nid.stringValue chapterId:chapter.nid.stringValue] dataUsingEncoding:NSUTF8StringEncoding] ?: [NSData data];
                ContentVO *contentVO = [ContentVO new];
                contentVO.results = (id)[ContentItemVO arrayOfModelsFromData:contentData error:NULL];
                chapter.contentVO = contentVO;
                configDataBlock();
            }];
        }
        else {//不是从下载来，就从网络取
            getContentBlock();
        }
    }
    else {//数据充足，则直接生成image

        if (chapter.readingBG != [QWReadingConfig sharedInstance].readingBG ||
            chapter.fontSize != [QWReadingConfig sharedInstance].fontSize ||
            chapter.traditional != [QWReadingConfig sharedInstance].traditional ||
            chapter.originalFont != [QWReadingConfig sharedInstance].originalFont ||
            chapter.landscape != [QWReadingConfig sharedInstance].landscape ||
            chapter.showDanmu != [QWReadingConfig sharedInstance].showDanmu) {
            chapter.completed = NO;
        }
        
        configDataBlock();
    }
}

- (void)getnextReadingContentWithReadingVC:(QWReadingVC *)readingVC andCompleteBlock:(QWReadingContentCompletionBlock)aBlock
{
    if (!self.start) {
        return ;
    }
    
    if (!readingVC.currentPage) {//如果没有当前的page，那么这个vc应该就是跳转进度的，或者继续阅读的
        VolumeCD *volumeCD = [VolumeCD findLastReadingVolumeWithBookId:self.bookCD.nid];
        readingVC.currentPage = [BookPageVO new];
        readingVC.currentPage.volumeId = volumeCD.nid;
        readingVC.currentPage.chapterIndex = volumeCD.chapterIndex.integerValue +1;
        NSLog(@"volumeCD.chapterIndex.integerValue2 = %ld",(long)volumeCD.chapterIndex.integerValue);
        readingVC.currentPage.range = NSMakeRange(volumeCD.location.integerValue, 0);
        if (volumeCD.location.integerValue == 0) {
            readingVC.currentPage.pageIndex = 0;
        }
        else {
            readingVC.currentPage.pageIndex = NSNotFound;
        }
    }
    
    self.currentPage = readingVC.currentPage;
    
    VolumeVO *volume = self.currentVolumeVO;
    ChapterVO *chapter = volume.chapter[self.currentPage.chapterIndex];
    
    WEAK_SELF;
    
    if (self.currentPage.pageIndex == 0) {
        if (aBlock) {
            aBlock(kQWPlaceholderChapterAttributeName, QWReadingContentTypeChapter);
        }
    }
    
    void (^configDataBlock)() = [^() {//从网络取数据
        STRONG_SELF;
        [self performInThreadBlock:^{
            if (!chapter.isCompleted) {
                [chapter configChapter];
            }
            
            [self configReadingContentWithReadingVC:readingVC];
            
            [self getPageWithReadingVC:readingVC andCompleteBlock:^(id __nullable content, QWCoreTextContentType type) {
                STRONG_SELF;
                
                [self saveReadingProgressWithReadingVC:readingVC];
                
                [self performInMainThreadBlock:^{
                    STRONG_SELF;
                    if (aBlock) {
                        switch (type) {
                            case QWCoreTextContentTypeContent:
                                aBlock(content, QWReadingContentTypeContent);
                                break;
                            case QWCoreTextContentTypeCustom:
                            {
                                if ([content isKindOfClass:[NSString class]] && [kQWPlaceholderChapterAttributeName isEqualToString:content]) {
                                    aBlock(content, QWReadingContentTypeChapterDone);
                                }
                                else {
                                    if (self.offline) {
                                        aBlock(content, QWReadingContentTypeImage);
                                    }
                                    else {
                                        aBlock(content, QWReadingContentTypeNetImage);
                                    }
                                }
                            }
                                break;
                            default:
                                aBlock([NSError errorWithDomain:@"core text error" code:999 userInfo:nil], QWReadingContentTypeError);
                                break;
                        }
                    }
                }];
            }];
        }];
    } copy];
    
    void (^getContentBlock)() = [^() {//从网络取数据
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"limit"] = @(READING_CONTENT_PAGE_SIZE);//计算出一个屏幕大概显示的行数
        params[@"offset"] = @(chapter.contentVO.results.count);
        if (chapter.type.integerValue == 2 && [QWGlobalValue sharedInstance].isLogin) {
            params[@"token"] = [QWGlobalValue sharedInstance].token;
            QWOperationParam *param = [QWInterface getWithUrl:chapter.content_url params:params andCompleteBlock:^(id aResponseObject, NSError *anError){
                if (aResponseObject && !anError) {
                    STRONG_SELF;
                    [self performInThreadBlock:^{
                        STRONG_SELF;
                        chapter.contentVO = [ContentVO voWithDict:aResponseObject];
                        chapter.amount = [aResponseObject objectForKey:@"amount"];
                        chapter.points = [aResponseObject objectForKey:@"points"];
                        chapter.battle = [aResponseObject objectForKey:@"battle"];
                        chapter.amount_coin = [aResponseObject objectForKey:@"amount_coin"];
                        chapter.can_use_voucher = [aResponseObject objectForKey:@"can_use_voucher"];
                        chapter.buy_type = [aResponseObject objectForKey:@"buy_type"];
                        chapter.volume_amount_coin = [aResponseObject objectForKey:@"volume_amount_coin"];
                        chapter.volume_battle = [aResponseObject objectForKey:@"volume_battle"];
                        chapter.volume_chapter_count = [aResponseObject objectForKey:@"volume_chapter_count"];
                        chapter.volume_need_amount = [aResponseObject objectForKey:@"volume_need_amount"];
                        chapter.volume_points = [aResponseObject objectForKey:@"volume_points"];
                        configDataBlock();
                    }];
                }
                else {
#ifndef DEBUG
                    if (anError.code == 404) {//内容不存在导致
                        StatisticVO *statistic = [StatisticVO new];
                        statistic.bookId = self.bookCD.nid.stringValue;
                        statistic.chapterId = chapter.nid.stringValue;
                        statistic.contentUrl = chapter.content_url;
                        [[BaiduMobStat defaultStat] logEvent:@"content404" eventLabel:statistic.toJSONString];
                    }
#endif
                    if (aBlock) {
                        aBlock(anError, QWReadingContentTypeError);
                    }
                }
                
            }];
            //            param.printLog = NO;
            param.requestType = QWRequestTypePost;
            [self.operationManager requestWithParam:param];
        } else  {
            QWOperationParam *param = [QWInterface getWithUrl:chapter.content_url params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
                if (aResponseObject && !anError) {
                    STRONG_SELF;
                    [self performInThreadBlock:^{
                        STRONG_SELF;
                        chapter.contentVO = [ContentVO voWithDict:aResponseObject];
                        chapter.amount = [aResponseObject objectForKey:@"amount"];
                        chapter.points = [aResponseObject objectForKey:@"points"];
                        chapter.battle = [aResponseObject objectForKey:@"battle"];
                        chapter.amount_coin = [aResponseObject objectForKey:@"amount_coin"];
                        chapter.can_use_voucher = [aResponseObject objectForKey:@"can_use_voucher"];
                        chapter.buy_type = [aResponseObject objectForKey:@"buy_type"];
                        chapter.volume_amount_coin = [aResponseObject objectForKey:@"volume_amount_coin"];
                        chapter.volume_battle = [aResponseObject objectForKey:@"volume_battle"];
                        chapter.volume_chapter_count = [aResponseObject objectForKey:@"volume_chapter_count"];
                        chapter.volume_need_amount = [aResponseObject objectForKey:@"volume_need_amount"];
                        chapter.volume_points = [aResponseObject objectForKey:@"volume_points"];
                        configDataBlock();
                    }];
                }
                else {
#ifndef DEBUG
                    if (anError.code == 404) {//内容不存在导致
                        StatisticVO *statistic = [StatisticVO new];
                        statistic.bookId = self.bookCD.nid.stringValue;
                        statistic.chapterId = chapter.nid.stringValue;
                        statistic.contentUrl = chapter.content_url;
                        [[BaiduMobStat defaultStat] logEvent:@"content404" eventLabel:statistic.toJSONString];
                    }
#endif
                    if (aBlock) {
                        aBlock(anError, QWReadingContentTypeError);
                    }
                }
            }];
            
            //            param.printLog = NO;
            
            [self.operationManager requestWithParam:param];
        }
        
    } copy];
    
    //如果没有content则加载, 没有加载完也要加载
    if (!chapter.contentVO || (chapter.contentVO.results.count < chapter.contentVO.count.integerValue)) {
        if (self.offline) {//从下载过来，直接从硬盘取
            [self performInThreadBlock:^{
                STRONG_SELF;
                NSData *contentData = [[QWFileManager loadContentWithBookId:self.bookCD.nid.stringValue volumeId:volume.nid.stringValue chapterId:chapter.nid.stringValue] dataUsingEncoding:NSUTF8StringEncoding] ?: [NSData data];
                ContentVO *contentVO = [ContentVO new];
                contentVO.results = (id)[ContentItemVO arrayOfModelsFromData:contentData error:NULL];
                chapter.contentVO = contentVO;
                configDataBlock();
            }];
        }
        else {//不是从下载来，就从网络取
            getContentBlock();
        }
    }
    else {//数据充足，则直接生成image
        
        if (chapter.readingBG != [QWReadingConfig sharedInstance].readingBG ||
            chapter.fontSize != [QWReadingConfig sharedInstance].fontSize ||
            chapter.traditional != [QWReadingConfig sharedInstance].traditional ||
            chapter.originalFont != [QWReadingConfig sharedInstance].originalFont ||
            chapter.landscape != [QWReadingConfig sharedInstance].landscape || chapter.showDanmu != [QWReadingConfig sharedInstance].showDanmu) {
            chapter.completed = NO;
        }
        
        configDataBlock();
    }
}
- (void)saveReadingProgressWithReadingVC:(QWReadingVC *)readingVC
{
    //存储当前阅读的书的信息
    VolumeVO *volume = self.currentVolumeVO;
    VolumeCD *volumeCD = self.currentVolumeCD;
    if (!self.currentVolumeCD) {
        VolumeCD *volumeCD = [VolumeCD MR_createEntityInContext:[QWFileManager qwContext]];
        [volumeCD updateWithVolumeVO:volume bookId:self.bookCD.nid];
    }
    volumeCD.chapterIndex = @(readingVC.currentPage.chapterIndex);
    volumeCD.location = @(readingVC.currentPage.range.location);
    [volumeCD setReading];

    [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];//写入
}

- (void)getPageWithReadingVC:(QWReadingVC *)readingVC andCompleteBlock:(QWCoreTextHelperCompleteBlock)aBlock
{
    CGRect bounds = [QWReadingConfig sharedInstance].readingBounds;
    VolumeVO *volume = self.currentVolumeVO;
    ChapterVO *chapter = volume.chapter[readingVC.currentPage.chapterIndex];
    NSAttributedString *tempAttributedString = chapter.attributedString.copy;

    NSRange drawRange = readingVC.currentPage.range;

    NSLog(@"\n");
    NSLog(@"===================");
    NSLog(@"绘图 %@ <- %@ == %@ -> %@",readingVC.previousPage, readingVC.currentPage, NSStringFromRange(drawRange), readingVC.nextPage);
    NSLog(@"===================");
    NSLog(@"\n");
    
    //画图
    WEAK_SELF;
    [QWCoreTextHelper getPageRangeAttributedString:tempAttributedString inDrawRect:bounds inTextRect:bounds range:drawRange draw:YES framesetter:chapter.framesetter andCompleteBlock:^(id __nullable content, QWCoreTextContentType type) {
        STRONG_SELF;
        if (aBlock) {
            aBlock(content, type);
        }
    }];
    
    
    
}

- (NSInteger)getPageIndexWithPage:(BookPageVO *)pageVO
{
    VolumeVO *volume = self.currentVolumeVO;
    ChapterVO *chapter = volume.chapter[pageVO.chapterIndex];
    __block NSInteger pageIndex = 0;
    [chapter.bookPages.copy enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, BookPageVO * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.range.location <= pageVO.range.location && (obj.range.location + obj.range.length) > pageVO.range.location) {
            pageIndex = key.integerValue;
            *stop = YES;
        }
    }];

    return pageIndex;
}

- (NSNumber *)getChapterIdWithReadingVC:(QWReadingVC *)readingVC{
    NSNumber *chapterId = [NSNumber new];
    if (!readingVC.currentPage) {//如果没有当前的page，那么这个vc应该就是跳转进度的，或者继续阅读的
        VolumeCD *volumeCD = [VolumeCD findLastReadingVolumeWithBookId:self.bookCD.nid];
        readingVC.currentPage = [BookPageVO new];
        readingVC.currentPage.volumeId = volumeCD.nid;
        readingVC.currentPage.chapterIndex = volumeCD.chapterIndex.integerValue;
        //        NSLog(@"volumeCD.chapterIndex.integerValue = %ld",(long)volumeCD.chapterIndex.integerValue);
        readingVC.currentPage.range = NSMakeRange(volumeCD.location.integerValue, 0);
        if (volumeCD.location.integerValue == 0) {
            readingVC.currentPage.pageIndex = 0;
        }
        else {
            readingVC.currentPage.pageIndex = NSNotFound;
        }
    }
    self.currentPage = readingVC.currentPage;
    
    VolumeVO *volume = self.currentVolumeVO;
    ChapterVO *chapter = volume.chapter[self.currentPage.chapterIndex];
    chapterId = chapter.nid;
    return chapterId;
}
@end
