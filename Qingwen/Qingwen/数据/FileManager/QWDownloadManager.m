//
//  QWDownloadManager.m
//  Qingwen
//
//  Created by Aimy on 7/16/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWDownloadManager.h"
#import <SDImageCache.h>
#import "StatisticVO.h"
#import <SDWebImageManager.h>
NSString * const QWImageHost = @"http://image.iqing.in/";

@interface QWDownloadManager ()

@property (nonatomic, strong) NSMutableArray *books;//在下载的book队列,list of QWDownloadItem

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic, strong) NSTimer *updateTimer;

@end

@implementation QWDownloadManager

DEF_SINGLETON(QWDownloadManager);

- (instancetype)init
{
    self = [super init];
    self.books = @[].mutableCopy;
    self.backgroundTask = UIBackgroundTaskInvalid;
    
    WEAK_SELF;
    [self observeNotification:UIApplicationDidBecomeActiveNotification withBlock:^(__weak id self, NSNotification *notification) {
        if ( ! notification) {
            return ;
        }
        
        KVO_STRONG_SELF;
        [kvoSelf reinstateBackgroundTask];
    }];
    return self;
}

- (void)reinstateBackgroundTask
{
    if (self.books.count && self.updateTimer == nil && self.backgroundTask == UIBackgroundTaskInvalid) {
        [self registerBackgroundTask];
    }
}

- (void)registerBackgroundTask
{
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:.5f target:self selector:@selector(update) userInfo:nil repeats:YES];
    [self resumeAllDownload];
    WEAK_SELF;
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"download" expirationHandler:^{
        STRONG_SELF;
        [self endBackgroundTask];
    }];
}

- (void)endBackgroundTask
{
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
    self.backgroundTask = UIBackgroundTaskInvalid;
    [self.updateTimer invalidate];
    self.updateTimer = nil;
    [self suspendAllDownload];
}

- (void)update
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        NSLog(@"Background time remaining = %.1f seconds", [UIApplication sharedApplication].backgroundTimeRemaining);
        if ([UIApplication sharedApplication].backgroundTimeRemaining < 5) {
            NSLog(@"end background");
            [self endBackgroundTask];
        }
    }
}

- (BOOL)isDownloadingWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId
{
    return [self getDownloadingItemWithBookId:bookId volumeId:volumeId] != nil;
}

- (BOOL)isDownloadingWithBookId:(NSString *)bookId {
    return [self getDownloadingItemWIthBookId:bookId] != nil;
}

- (void)suspendAllDownload
{
    for (QWDownloadItem *item in self.books.copy) {
        item.operationManager.operationQueue.suspended = YES;
    }
}

- (void)resumeAllDownload
{
    QWDownloadItem *item = [self.books.copy firstObject];
    item.operationManager.operationQueue.suspended = NO;
}
- (QWDownloadItem *)startDownloadWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId
{
    QWDownloadItem *item = [self getDownloadingItemWithBookId:bookId volumeId:volumeId];
    if (item) {
        [item clearItem];
    }
    else {
        item = [QWDownloadItem new];
        [self.books addObject:item];
    }
    NSInteger index = [self.books.copy indexOfObject:item];
    item.operationManager.operationQueue.suspended = (index > 0);
    
    [self reinstateBackgroundTask];
    
    return item;
}

- (void)stopDownloadWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId
{
    QWDownloadItem *item = [self getDownloadingItemWithBookId:bookId volumeId:volumeId];
    if (item) {
        [item clearItem];
        NSLog(@"itemdealloc----%@",item.volume.title);
        [self.books removeObject:item];
    }
    
    QWDownloadItem *firstItem = [self.books.copy firstObject];
    
    firstItem.operationManager.operationQueue.suspended = NO;
    
    
    if (!firstItem) {
        [self endBackgroundTask];
    }
}

- (QWDownloadItem *)getDownloadingItemWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId
{
    return [[self.books.copy filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"bookId == %@ AND volumeId == %@", bookId, volumeId]] firstObject];
}
- (QWDownloadItem *)getDownloadingItemWIthBookId:(NSString *)bookId {
    return [[self.books.copy filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"bookId == %@",bookId]] firstObject];
}

//- (QWDownloadItem *)getUnStartDownloadItemWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId
//{
//    QWDownloadItem *item = [QWDownloadItem new];
//    [item configUnstartedWithVolumeId:volumeId];
//    return item;
//}

- (QWDownloadItem *)downloadWithChapters:(NSArray *)chapter volume:(VolumeVO *)volume book:(BookVO *)book {
    
    if (!chapter || chapter.count <= 0) {
        return nil;
    }
    NSLog(@"%@---%@---%ld",book.title, volume.title, (unsigned long)chapter.count);
    
    QWDownloadItem *item = [self startDownloadWithBookId:book.nid.stringValue volumeId:volume.nid.stringValue];
    [item configWithBook:book volume:volume];
    WEAK_SELF;
    [item observeProperty:@"completed" withBlock:^(__weak id self, id old, id newVal) {
        KVO_STRONG_SELF;
        QWDownloadItem *item = self;
        NSLog(@"QWDownloadItem = %@",item);
        if (item.isCompleted) {
            [kvoSelf saveVolumeDirectoryWithVolume:volume book:book];
            [kvoSelf stopDownloadWithBookId:book.nid.stringValue volumeId:volume.nid.stringValue];
            
        }
    }];
    
    
    [item observeProperty:@"errorCompleted" withBlock:^(__weak id self, id old, id newVal) {
        KVO_STRONG_SELF;
        QWDownloadItem *item = self;
        if (item.isErrorCompleted) {
            [kvoSelf stopDownloadWithBookId:book.nid.stringValue volumeId:volume.nid.stringValue];
            [kvoSelf saveVolumeDirectoryWithVolume:volume book:book];
        }
    }];
    [self performInThreadBlock:^{
        if (chapter) {
            [chapter enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                @autoreleasepool {
                    ChapterVO *chapter = obj;
                    [self downloadWithChapter:chapter.copy item:item];
                }
            }];
        }
    }];
    
    return item;
}


//下载某一章节
- (void)downloadWithChapter:(ChapterVO *)chapter item:(QWDownloadItem *)item
{
    NSString *chapterId = chapter.nid.stringValue;
    NSString *bookId = item.bookId.copy;
    NSString *volumeId = item.volumeId.copy;
    __unused NSString *content_url = chapter.content_url;
    
    if (![QWFileManager isContentSavedWithBookId:bookId volumeId:volumeId chapterId:chapterId]) {
        WEAK_SELF;
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"token"] = [QWGlobalValue sharedInstance].token;
        QWOperationParam *param = [QWInterface getWithUrl:chapter.content_url params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
            STRONG_SELF;
            [self performInThreadBlock:^{
                STRONG_SELF;
                if (!anError && aResponseObject) {
                    
                    ContentVO *contentVO = [ContentVO voWithDict:aResponseObject];
                    NSData *data = [NSJSONSerialization dataWithJSONObject:[ChapterVO arrayOfDictionariesFromModels:contentVO.results ]options:NSJSONWritingPrettyPrinted error:nil];
                    [QWFileManager saveContentWithJson:[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] bookId:item.bookId volumeId:item.volumeId chapterId:chapterId];//存内容
                    NSArray *images = [contentVO.results filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == 1"]];
                    NSInteger count = images.count;
                    if (chapterId) {
                        [item updateWithChapterId:chapterId andImageCount:count];
                        [self downloadImagesWithContent:contentVO chapterId:chapterId andItem:item];
                    }
                }
                else {
#ifndef DEBUG
                    if (anError.code == 404) {//内容不存在导致
                        NSMutableDictionary *attributes = @{}.mutableCopy;
                        attributes[@"bookId"] = item.bookId;
                        attributes[@"chapterId"] = chapterId;
                        attributes[@"contentUrl"] = content_url;
                        StatisticVO *statistic = [StatisticVO voWithDict:attributes];
                        [[BaiduMobStat defaultStat] logEvent:@"content404" eventLabel:statistic.toJSONString];
                    }
#endif
                    [item updateWithErrorWithChapterId:chapterId];
                    NSMutableDictionary *attributes = @{}.mutableCopy;
                    attributes[@"bookId"] = item.bookId;
                    attributes[@"chapterId"] = chapterId;
                    attributes[@"contentUrl"] = content_url;
                    NSLog(@"下载错误%ld---%@",(long)anError.code,attributes);
                }
            }];
        }];
        param.printLog = NO;
        param.requestType = QWRequestTypePost;
        param.retryTimes = 5;
        param.timeoutTime = 100;
        [item.operationManager requestWithParam:param];
    }
}

- (void)downloadImagesWithContent:(ContentVO *)content chapterId:(NSString *)chapterId andItem:(QWDownloadItem *)item
{
    WEAK_SELF;
    ContentVO *contentVO = content;
    NSArray *images = [contentVO.results filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == 1"]];
    [images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        @autoreleasepool {
            ContentItemVO *contentItemVO = obj;
            NSString *fileName = contentItemVO.value;
            NSString *keyName = [fileName stringByReplacingOccurrencesOfString:QWImageHost withString:@""];
            NSString *valumePath = [[QWFileManager qingwenPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",item.bookId, item.volumeId]];
            NSString *filePathStr = [valumePath stringByAppendingPathComponent:keyName];
            if (![QWFileManager isFileExistWithFileUrl:filePathStr]) {
                //                QWOperationParam *param = [QWInterface getWithUrl:[QWConvertImageString convertPicURL:contentItemVO.value imageSizeType:QWImageSizeTypeIllustration] andCompleteBlock:^(id aResponseObject, NSError *anError) {
                //                    STRONG_SELF;
                //
                //                    [self performInThreadBlock:^{
                //                        NSLog(@"下载数据 = %@ ",aResponseObject);
                //                        if (!anError) {
                //                            NSLog(@"filePathStr = %@",filePathStr);
                //
                //                            [QWFileManager saveImageWithImage:aResponseObject bookId:item.bookId volumeId:item.volumeId contentFileName:keyName];
                //                            [item updateSubCountWithChapterId:chapterId];
                //                        }
                //                        else {
                //#ifndef DEBUG
                //                            if (anError.code == 404) {//图片不存在导致
                //                                NSMutableDictionary *attributes = @{}.mutableCopy;
                //                                attributes[@"bookId"] = item.bookId;
                //                                attributes[@"chapterId"] = chapterId;
                //                                attributes[@"imageUrl"] = [QWConvertImageString convertPicURL:contentItemVO.value imageSizeType:QWImageSizeTypeIllustration];
                //                                StatisticVO *statistic = [StatisticVO voWithDict:attributes];
                //                                [[BaiduMobStat defaultStat] logEvent:@"image404" eventLabel:statistic.toJSONString];
                //                            }
                //#endif
                //                            [item updateSubCountErrorWithChapterId:chapterId];
                //                        }
                //                    }];
                //                }];
                //                param.image = YES;
                //                param.printLog = NO;
                //                param.retryTimes = 5;
                //                param.timeoutTime = 100;
                //                [item.operationManager requestWithParam:param];
                
                //sdweb下载图片
                [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:fileName] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                    
                } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    NSLog(@"image xiazaichenggong");
                    [QWFileManager saveImageWithImage:image bookId:item.bookId volumeId:item.volumeId contentFileName:keyName];
                    [item updateSubCountWithChapterId:chapterId];
                }];
            }
            else {
                [item updateSubCountWithChapterId:chapterId];
            }
        }
    }];
}

//存入Volume.json、chapter.json、book.json、
- (void)saveVolumeDirectoryWithVolume:(VolumeVO *)currentVolume book:(BookVO *)book {
    NSString *bookPath = [[QWFileManager qingwenPath] stringByAppendingPathComponent:book.nid.stringValue];
    NSString *volumePath = [bookPath stringByAppendingPathComponent:currentVolume.nid.stringValue];
    [QWFileManager createFolderIfNeeded:volumePath];//创建卷目录
    //存储封面
    {
        UIImage *cover = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[QWConvertImageString convertPicURL:book.cover imageSizeType:QWImageSizeTypeCoverThumbnail]];
        if (cover) {
            NSData *imageData = UIImageJPEGRepresentation(cover, 1.f);
            NSString *coverPath = [volumePath stringByAppendingPathComponent:@"cover"];
            [QWFileManager createFolderIfNeeded:coverPath];
            NSString *str = [book.cover stringByReplacingOccurrencesOfString:@"http://image.iqing.in/cover/" withString:@""];
            NSString *coverFilePath = [coverPath stringByAppendingPathComponent:str];
            [imageData writeToFile:coverFilePath atomically:NO];
        }
    }
    //写入书
    {
        BookVO *bookVO = book;
        
        NSString *bookJson = bookVO.toJSONString;
        [bookJson writeToFile:[volumePath stringByAppendingPathComponent:@"book.json"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    //再次写入的时候需要在原来的基础上添加
    VolumeVO *volume1 = [VolumeVO voWithJson:[QWFileManager loadVolumeWithBookId:book.nid.stringValue volumeId:currentVolume.nid.stringValue]];
    if (volume1) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:volume1.chapter];
        [currentVolume.chapter enumerateObjectsUsingBlock:^(ChapterVO*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            int i = 0;
            for (ChapterVO *chapter in tempArray) {
                if (chapter.nid == obj.nid) {
                    break;
                }
                i++;
            }
            if (i == tempArray.count) {
                [tempArray addObject:obj];
            }
        }];
        [tempArray sortUsingComparator:^NSComparisonResult(ChapterVO*  _Nonnull obj1, ChapterVO*  _Nonnull obj2) {
            if (obj2.order && obj1.order) {
                return [obj1.order compare:obj2.order];
            }
            else {
                return NSOrderedSame;
            }
        }];
        volume1.chapter = tempArray.copy;
    }else {
        volume1 = currentVolume;
    }
    
    //写入章列表
    {
        [QWFileManager saveVolumeWithBookId:[book.nid stringValue] volumeJson:[volume1 toJSONString] volumeId:[volume1.nid stringValue]];
        
    }
    
    //写入卷
    {
        NSData *data = [NSJSONSerialization dataWithJSONObject:[ChapterVO arrayOfDictionariesFromModels:volume1.chapter ]options:NSJSONWritingPrettyPrinted error:nil];
        [QWFileManager saveChaptersWithBookId:[book.nid stringValue] ChapterJson:[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] volumeId:[volume1.nid stringValue]];
    }
}

@end
