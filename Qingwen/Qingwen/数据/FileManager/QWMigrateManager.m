//
//  QWMigrateManager.m
//  Qingwen
//
//  Created by Aimy on 9/11/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWMigrateManager.h"

#import "BookVO.h"
#import "BookCD.h"
#import "VolumeCD.h"
#import "VolumeList.h"
#import "QWJsonKit.h"
#import <GBVersionTracking.h>
#import "QWFileManager.h"
#import "QWUserDefaults.h"
#import "BookContinueReadingCD.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <SDImageCache.h>

@implementation QWMigrateManager

#pragma mark - directory

+ (NSDictionary *)loadDirectoryWithBookId:(NSString *)bookId
{
    NSAssert(bookId, @"bookId 不能为空");

    NSString *bookFolder = [[QWFileManager qingwenPath] stringByAppendingPathComponent:bookId];
    NSString *bookDirectory = [bookFolder stringByAppendingPathComponent:@"directory"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:bookDirectory]) {
        NSData *convetedData = [NSData dataWithContentsOfFile:bookDirectory];
        return [NSKeyedUnarchiver unarchiveObjectWithData:convetedData];
    }

    return nil;
}

#pragma mark - content

+ (NSString *)chapterPathWithBooId:(NSString *)bookId chapterId:(NSString *)chapterId
{
    NSAssert(bookId, @"bookId 不能为空");
    NSAssert(chapterId, @"chapterId 不能为空");

    NSString *bookFolder = [[QWFileManager qingwenPath] stringByAppendingPathComponent:bookId];
    NSString *chapterPath = [bookFolder stringByAppendingPathComponent:chapterId];
    [QWFileManager createFolderIfNeeded:chapterPath];
    return chapterPath;
}

+ (NSString *)filePathWithFileName:(NSString *)fileName bookId:(NSString *)bookId chapterId:(NSString *)chapterId
{
    NSAssert(fileName, @"fileName 不能为空");
    NSAssert(bookId, @"bookId 不能为空");
    NSAssert(chapterId, @"chapterId 不能为空");

    NSString *chapterPath = [self chapterPathWithBooId:bookId chapterId:chapterId];
    NSString *path = [chapterPath stringByAppendingPathComponent:fileName];
    return path;
}

+ (NSDictionary *)loadContentWithBookId:(NSString *)bookId chapterId:(NSString *)chapterId
{
    NSAssert(bookId, @"bookId 不能为空");
    NSAssert(chapterId, @"chapterId 不能为空");

    NSString *path = [self filePathWithFileName:@"content" bookId:bookId chapterId:chapterId];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }

    return nil;
}

+ (BOOL)isChapterDownloadedWithBookId:(NSString *)bookId chapterId:(NSString *)chapterId
{
    NSAssert(bookId, @"bookId 不能为空");
    NSAssert(chapterId, @"chapterId 不能为空");

    NSString *path = [self filePathWithFileName:@"content_done" bookId:bookId chapterId:chapterId];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path]) {
        return YES;
    }

    return NO;
}

+ (void)migrate
{
    if ([GBVersionTracking isFirstLaunchForVersion] && [GBVersionTracking previousVersion].floatValue < 1.3) {
        //更换了profile获取个人信息，之前的版本都没有存储，所以清除登录
        [[QWGlobalValue sharedInstance] clear];
    }

    if ([GBVersionTracking isFirstLaunchForVersion] && [GBVersionTracking previousVersion] && [GBVersionTracking previousVersion].floatValue < 1.9) {
        //增加了coin，1.9之前的版本都没有存储，所以清除登录
        [[QWGlobalValue sharedInstance] clear];
    }

    NSArray *versions = [GBVersionTracking versionHistory];
    //证明是从1.4.0升级到1.6.5版本的, 如果在iOS9.0以下，就会出现迁移问题所以要重新迁移
    if ([versions containsObject:@"1.4.0"] &&
        ! [QWUserDefaults sharedInstance][@"migrateReading1.7.0"] &&
        [QWUserDefaults sharedInstance][@"migrateReading1.5"] && IOS_SDK_LESS_THAN(9.0)) {
        [QWUserDefaults sharedInstance][@"migrateReading1.5"] = nil;
        [self migrateReading];
    }

    if ([versions containsObject:@"1.4.0"] &&
        ! [QWUserDefaults sharedInstance][@"migrateDownload1.7.0"] &&
        [QWUserDefaults sharedInstance][@"migrateDownload1.5"] && IOS_SDK_LESS_THAN(9.0)) {
        [QWUserDefaults sharedInstance][@"migrateDownload1.5"] = nil;
        [self migrateDownload];
    }
}

+ (void)migrateReading
{
    NSArray *readingCDs = [BookContinueReadingCD MR_findAllInContext:[QWFileManager qwContext]];
    for (BookContinueReadingCD *readingCD in readingCDs) {
        [readingCD MR_deleteEntityInContext:[QWFileManager qwContext]];
    }

    NSArray *books = [BookCD MR_findByAttribute:@"read" withValue:@YES inContext:[QWFileManager qwContext]];
    for (BookCD *bookCD in books) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
        BookContinueReadingCD *readingCD = [BookContinueReadingCD MR_createEntityInContext:[QWFileManager qwContext]];
        readingCD.bookId = bookCD.nid;
        readingCD.volumeIndex = bookCD.volumeIndex;
        readingCD.chapterIndex = bookCD.chapterIndex;
        readingCD.location = bookCD.location;
#pragma clang diagnostic pop
    }

    [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];

    [QWUserDefaults sharedInstance][@"migrateReading1.7.0"] = @YES;
}

static MBProgressHUD *hud = nil;

+ (void)migrateDownload
{
    NSArray *books = [BookCD MR_findByAttribute:@"download" withValue:@YES inContext:[QWFileManager qwContext]];
    if ( ! books.count) {
        NSLog(@"没有在1.5版本之前下载书籍，不用迁移");
        [QWUserDefaults sharedInstance][@"migrateDownload1.7.0"] = @YES;
        return ;
    }

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1.0 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"正在迁移下载";

        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1.0 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self doMigrateDownload1_6_5];
            [self doMigrateDownload1_7_0];
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.labelText = @"已完成";
                [hud hide:YES afterDelay:1.f];
                hud = nil;
            });
            [QWUserDefaults sharedInstance][@"migrateDownload1.7.0"] = @YES;
        });
    });
}

+ (void)doMigrateDownload1_6_5
{
    NSLog(@"开始迁移");
    NSString *tempPath = [[QWFileManager libPath] stringByAppendingPathComponent:@"qingwen-temp"];
    [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
    [QWFileManager createFolderIfNeeded:tempPath];//创建qingwen-temp目录
    [QWFileManager addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:tempPath]];

    NSArray *books = [BookCD MR_findByAttribute:@"download" withValue:@YES inContext:[QWFileManager qwContext]];
    NSLog(@"共迁移%@本书", @(books.count));

    [books enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BookCD *bookCD = obj;
        NSLog(@"迁移书<%@>", bookCD.title);
        NSString *bookPath = [tempPath stringByAppendingPathComponent:bookCD.nid.stringValue];
        [QWFileManager createFolderIfNeeded:bookPath];//创建书目录

        __block int volumeSuccessCount = 0;
        VolumeList *volumeList = [VolumeList voWithDict:[self loadDirectoryWithBookId:bookCD.nid.stringValue]];
        [volumeList.results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            VolumeVO *volume = obj;
            NSLog(@"迁移书<%@>, 卷<%@>", bookCD.title, volume.title);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
            if (bookCD.volumeIndex.integerValue == idx) {
                VolumeCD *volumeCD = [VolumeCD MR_findFirstByAttribute:@"nid" withValue:volume.nid inContext:[QWFileManager qwContext]];
                if ( ! volumeCD) {
                    volumeCD = [VolumeCD MR_createEntityInContext:[QWFileManager qwContext]];
                    [volumeCD updateWithVolumeVO:volume bookId:bookCD.nid];
                }

                volumeCD.chapterIndex = bookCD.chapterIndex;
                volumeCD.location = bookCD.location;
                [volumeCD setReading];
            }
#pragma clang diagnostic pop

            if ([self migrateVolume:volume withBookCD:bookCD]) {
                volumeSuccessCount++;
            };
        }];

        if (volumeSuccessCount == 0) {//没有下载成功任何一卷，则删除书
            bookCD.download = NO;
            bookCD.lastDownloadTime = nil;
            [[NSFileManager defaultManager] removeItemAtPath:bookPath error:nil];
        }

        //删除1.6.5的整书下载目录，这样最后就只剩余1.7.0的分卷下载的目录了
        {
            NSString *bookFolder = [[QWFileManager qingwenPath] stringByAppendingPathComponent:bookCD.nid.stringValue];
            [[NSFileManager defaultManager] removeItemAtPath:bookFolder error:nil];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            hud.labelText = [NSString stringWithFormat:@"%.1f％", idx * 100.0 / books.count];
        });
    }];
}

+ (BOOL)migrateVolume:(VolumeVO *)volume withBookCD:(BookCD *)bookCD
{
    __block BOOL success = YES;
    NSString *tempPath = [[QWFileManager libPath] stringByAppendingPathComponent:@"qingwen-temp"];
    NSString *bookPath = [tempPath stringByAppendingPathComponent:bookCD.nid.stringValue];
    NSString *volumePath = [bookPath stringByAppendingPathComponent:volume.nid.stringValue];

    [QWFileManager createFolderIfNeeded:volumePath];//创建卷目录

    //写入书
    {
        BookVO *bookVO = [bookCD toBookVO];
        bookVO.cover = [NSString stringWithFormat:@"/cover/%@/cover.jpg", bookCD.nid.stringValue];
        NSString *bookJson = bookVO.toJSONString;
        [bookJson writeToFile:[volumePath stringByAppendingPathComponent:@"book.json"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    //写入封面
    {
        //存储封面
        UIImage *cover = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[QWConvertImageString convertPicURL:bookCD.cover imageSizeType:QWImageSizeTypeCoverThumbnail]];
        if (cover) {
            NSData *imageData = UIImageJPEGRepresentation(cover, 1.f);
            NSString *coverPath = [volumePath stringByAppendingFormat:@"/cover/%@", bookCD.nid.stringValue];
            [QWFileManager createFolderIfNeeded:coverPath];
            NSString *coverFilePath = [coverPath stringByAppendingPathComponent:@"cover.jpg"];
            [imageData writeToFile:coverFilePath atomically:NO];
        }
    }
    //写入卷
    {
        VolumeVO *tempVolume = volume.copy;
        tempVolume.chapter = nil;
        NSString *volumeJson = tempVolume.toJSONString;
        [volumeJson writeToFile:[volumePath stringByAppendingPathComponent:@"volume.json"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    //写入章列表
    {
        VolumeVO *tempVolume = [VolumeVO new];
        tempVolume.chapter = volume.chapter;
        NSDictionary *chapter = tempVolume.toDictionary[@"chapter"];
        NSString *volumeJson = [QWJsonKit stringFromDict:chapter];
        [volumeJson writeToFile:[volumePath stringByAppendingPathComponent:@"chapter.json"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }

    NSString *volumeImagePath = [volumePath stringByAppendingPathComponent:[NSString stringWithFormat:@"book/%@/%@", bookCD.nid, volume.nid]];
    [QWFileManager createFolderIfNeeded:volumeImagePath];//创建图片卷目录
    [QWFileManager createFolderIfNeeded:[volumePath stringByAppendingPathComponent:@"chapter"]];//创建章节目录

    [volume.chapter enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ChapterVO *chapter = obj;

        //有未下载成功的章节，所以删除
        if ( ! [self isChapterDownloadedWithBookId:bookCD.nid.stringValue chapterId:chapter.nid.stringValue]) {
            success = NO;
            *stop = YES;
            return ;
        }

        [QWFileManager createFolderIfNeeded:[volumeImagePath stringByAppendingPathComponent:chapter.nid.stringValue]];//创建图片章目录

        ContentVO *content = [ContentVO voWithDict:[self loadContentWithBookId:bookCD.nid.stringValue chapterId:chapter.nid.stringValue]];

        [content.results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ContentItemVO *contentItem = obj;
            if ([contentItem.type isEqualToNumber:@1]) {
                NSString *fileName = contentItem.value;
                NSString *keyName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@""];
                keyName = [keyName stringByReplacingOccurrencesOfString:@":" withString:@""];
                NSString *filePathStr = [self filePathWithFileName:keyName bookId:bookCD.nid.stringValue chapterId:chapter.nid.stringValue];

                NSString *tempImageName = [[contentItem.value componentsSeparatedByString:@"/"] lastObject];
                [[NSFileManager defaultManager] copyItemAtPath:filePathStr toPath:[volumeImagePath stringByAppendingFormat:@"/%@/%@", chapter.nid.stringValue, tempImageName] error:nil];

                //修改图片链接到新的格式
                contentItem.value = [NSString stringWithFormat:@"/book/%@/%@/%@/%@", bookCD.nid.stringValue, volume.nid.stringValue, chapter.nid.stringValue, tempImageName];
            }
        }];

        //写入章列表
        {
            NSDictionary *contentItems = content.toDictionary[@"results"];
            NSString *contentItemsJson = [QWJsonKit stringFromDict:contentItems];
            [contentItemsJson writeToFile:[volumePath stringByAppendingFormat:@"/chapter/%@.json", chapter.nid.stringValue] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }];

    if ( ! success) {//不成功就删除卷目录
        NSLog(@"迁移书<%@>, 卷<%@> -> 失败", bookCD.title, volume.title);
        [[NSFileManager defaultManager] removeItemAtPath:volumePath error:nil];
    }
    else {
        NSLog(@"迁移书<%@>, 卷<%@> -> 成功", bookCD.title, volume.title);
        VolumeCD *volumeCD = [VolumeCD MR_findFirstByAttribute:@"nid" withValue:volume.nid inContext:[QWFileManager qwContext]];
        if ( ! volumeCD) {
            volumeCD = [VolumeCD MR_createEntityInContext:[QWFileManager qwContext]];
            [volumeCD updateWithVolumeVO:volume bookId:bookCD.nid];
        }
        volumeCD.download = YES;
        volumeCD.lastDownloadTime = bookCD.lastDownloadTime;
    }

    return success;
}

+ (void)doMigrateDownload1_7_0
{
    NSString *tempPath = [[QWFileManager libPath] stringByAppendingPathComponent:@"qingwen-temp"];

    NSArray<NSString *> *books = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[QWFileManager qingwenPath] error:NULL];
    [books enumerateObjectsUsingBlock:^(NSString * _Nonnull book, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([book rangeOfString:@"patch.js"].location != NSNotFound || [book rangeOfString:@"reading_config"].location != NSNotFound) {
            return ;
        }

        NSString *bookPath = [[QWFileManager qingwenPath] stringByAppendingPathComponent:book];
        NSArray *volumes = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bookPath error:NULL];
        [volumes enumerateObjectsUsingBlock:^(NSString * _Nonnull volume, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *volumePath = [bookPath stringByAppendingPathComponent:volume];
            NSString *bookJsonPath = [volumePath stringByAppendingPathComponent:@"book.json"];
            NSString *bookJson = [NSString stringWithContentsOfFile:bookJsonPath encoding:NSUTF8StringEncoding error:NULL];
            BookVO *bookVO = [BookVO voWithJson:bookJson];
            BookCD *bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == NO", bookVO.nid] inContext:[QWFileManager qwContext]];
            if (! bookCD) {
                bookCD = [BookCD MR_createEntityInContext:[QWFileManager qwContext]];
                [bookCD updateWithBookVO:bookVO];
            }

            bookCD.download = YES;
            bookCD.lastReadTime = [NSDate date];

            NSString *volumeJsonPath = [volumePath stringByAppendingPathComponent:@"volume.json"];
            NSString *volumeJson = [NSString stringWithContentsOfFile:volumeJsonPath encoding:NSUTF8StringEncoding error:NULL];
            VolumeVO *volumeVO = [VolumeVO voWithJson:volumeJson];
            VolumeCD *volumeCD = [VolumeCD MR_findFirstByAttribute:@"nid" withValue:volumeVO.nid inContext:[QWFileManager qwContext]];
            if (! volumeCD) {
                volumeCD = [VolumeCD MR_createEntityInContext:[QWFileManager qwContext]];
                [volumeCD updateWithVolumeVO:volumeVO bookId:bookVO.nid];
            }
            volumeCD.download = YES;
            volumeCD.lastDownloadTime = [NSDate date];

            NSString *cover = bookCD.cover;
            NSString *coverPath = [NSString stringWithFormat:@"%@%@", volumePath, cover];
            UIImage *image = [UIImage imageWithContentsOfFile:coverPath];
            if (image) {
                NSLog(@"迁移书图片<%@> -> 成功", cover);
                [[SDImageCache sharedImageCache] storeImage:image forKey:[NSString stringWithFormat:@"%@-coverThumbnail", cover]completion:nil];
            }
        }];

        NSLog(@"迁移书<%@> -> 成功", book);

        NSString *destBookPath = [bookPath stringByReplacingOccurrencesOfString:@"qingwen" withString:@"qingwen-temp"];
        [[NSFileManager defaultManager] moveItemAtPath:bookPath toPath:destBookPath error:NULL];
    }];

    [[NSFileManager defaultManager] removeItemAtPath:[QWFileManager qingwenPath] error:NULL];
    [[NSFileManager defaultManager] moveItemAtPath:tempPath toPath:[QWFileManager qingwenPath] error:NULL];
    [QWFileManager addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:[QWFileManager qingwenPath]]];
    [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];

    NSLog(@"迁移完成");
}

@end
