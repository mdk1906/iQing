//
//  QWFileManager.m
//  Qingwen
//
//  Created by Aimy on 7/3/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWFileManager.h"

#import "QWDownloadItem.h"
#import "BookCD.h"
#import "VolumeCD.h"
#import <GBVersionTracking/GBVersionTracking.h>


@implementation QWFileManager

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);

    NSError *error = nil;
    BOOL success = [URL setResourceValue: @YES
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

+ (NSString *)usedSpaceAndfreeSpace
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileSysAttributes = [fileManager attributesOfFileSystemForPath:[self qingwenPath] error:nil];
    NSNumber *freeSpace = [fileSysAttributes objectForKey:NSFileSystemFreeSize];
    __unused NSNumber *totalSpace = [fileSysAttributes objectForKey:NSFileSystemSize];
    NSString *str= [NSString stringWithFormat:@"%0.1fMB", [freeSpace longLongValue] / 1024.0 / 1024.0];
    NSLog(@"剩余 %@",str);

    return str;
}

+ (BOOL)isSpaceAvailable
{
    return YES;
}

+ (NSString *)libPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    return path;
}

+ (NSString *)coredataPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"Qingwen"];
    return path;
}

+ (NSString *)coredataLibPath:(NSString *)name
{
    NSString *path = [[self coredataPath] stringByAppendingPathComponent:name];
    return path;
}

+ (NSString *)qingwenPath
{
    NSString *path = [[self libPath] stringByAppendingPathComponent:@"qingwen"];
    return path;
}

+ (NSString *)bookPath:(NSString *)bookId
{
    NSString *path = [[self qingwenPath] stringByAppendingPathComponent:bookId];
    return path;
}

static NSManagedObjectContext *_qwContext = nil;

+ (NSManagedObjectContext *)qwContext
{
    if (_qwContext == nil) {
        _qwContext = [NSManagedObjectContext MR_contextWithStoreCoordinator:[NSPersistentStoreCoordinator MR_defaultStoreCoordinator]];
    }

    return _qwContext;
}

+ (void)configDirectory
{
    //folder
    [self createFolderIfNeeded:[self qingwenPath]];
    [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[self qingwenPath]]];

    //core data
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"Qingwen"];
    [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[self coredataPath]]];

    //空间情况
    [self usedSpaceAndfreeSpace];
}

+ (void)createFolderIfNeeded:(NSString *)folder
{
    NSAssert(folder, @"folder 不能为空");

    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folder isDirectory:nil]) {
        [manager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

+ (BOOL)isFileExistWithFileUrl:(NSString *)url
{
    NSAssert(url, @"url 不能为空");

    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager fileExistsAtPath:url isDirectory:nil];
}

//历史记录
+ (NSArray *)loadHistory
{
    NSString *historyFile = [NSString stringWithFormat:@"%@/history.plist", [self qingwenPath]];
    NSArray *historys = [NSArray arrayWithContentsOfFile:historyFile];
    return historys ?: @[];
}

+ (void)saveHistory:(NSArray *)historys
{
    NSAssert(historys, @"historys 不能为空");
    
    NSString *historyFile = [NSString stringWithFormat:@"%@/history.plist", [self qingwenPath]];
    [historys writeToFile:historyFile atomically:YES];
}

#pragma mark - directory

+ (NSString *)loadBookWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId
{
    NSAssert(bookId, @"bookId 不能为空");
    NSAssert(volumeId, @"volumeId 不能为空");
    NSString *bookFile = [NSString stringWithFormat:@"%@/%@/%@/book.json", [self qingwenPath], bookId, volumeId];
    return [NSString stringWithContentsOfFile:bookFile encoding:NSUTF8StringEncoding error:NULL];
}

+ (UIImage *)loadBookCoverWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId
{
    NSAssert(bookId, @"bookId 不能为空");
    NSAssert(volumeId, @"volumeId 不能为空");
    BookVO *book = [BookVO voWithJson:[self loadBookWithBookId:bookId volumeId:volumeId]];
    NSString *bookCoverPath = [NSString stringWithFormat:@"%@/%@/%@/%@", [self qingwenPath], bookId, volumeId, book.cover];
    return [UIImage imageWithContentsOfFile:bookCoverPath];
}

+ (NSString *)loadVolumeWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId
{
    NSAssert(bookId, @"bookId 不能为空");
    NSAssert(volumeId, @"volumeId 不能为空");
    NSString *volumeFile = [NSString stringWithFormat:@"%@/%@/%@/volume.json", [self qingwenPath], bookId, volumeId];
    return [NSString stringWithContentsOfFile:volumeFile encoding:NSUTF8StringEncoding error:NULL];
}

+ (NSString *)loadChapterWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId
{
    NSAssert(bookId, @"bookId 不能为空");
    NSAssert(volumeId, @"volumeId 不能为空");
    NSString *chapterFile = [NSString stringWithFormat:@"%@/%@/%@/chapter.json", [self qingwenPath], bookId, volumeId];
    return [NSString stringWithContentsOfFile:chapterFile encoding:NSUTF8StringEncoding error:NULL];
}

+ (NSString *)loadContentWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId chapterId:(NSString *)chapterId
{
    NSAssert(bookId, @"bookId 不能为空");
    NSAssert(volumeId, @"volumeId 不能为空");
    NSAssert(chapterId, @"chapterId 不能为空");
    NSString *contentFile = [NSString stringWithFormat:@"%@/%@/%@/chapter/%@.json", [self qingwenPath], bookId, volumeId, chapterId];
    NSString *str = [NSString stringWithContentsOfFile:contentFile encoding:NSUTF8StringEncoding error:NULL];
    return str;
}

+ (NSString *)imagePathWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId chapterId:(NSString *)chapterId imageName:(NSString *)imageName
{
    if (bookId.length && volumeId.length && chapterId.length && imageName.length) {
        NSString *imageFile = [NSString stringWithFormat:@"%@/%@/%@/%@", [self qingwenPath], bookId, volumeId, imageName];
        return imageFile;
    }

    return nil;
}

+ (void)deleteBookWithBookId:(NSString *)bookId
{
    NSAssert(bookId, @"bookId 不能为空");

    NSString *volumePath = [NSString stringWithFormat:@"%@/%@", [self qingwenPath], bookId];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:volumePath error:nil];

    for (VolumeCD *volumeCD in [VolumeCD MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"bookId == %@", bookId] inContext:[QWFileManager qwContext]]) {
        [volumeCD setDeleted];
    }

    [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];
}

+ (void)deleteVolumeWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId write:(BOOL)write
{
    NSAssert(bookId, @"bookId 不能为空");
    NSAssert(volumeId, @"volumeId 不能为空");

    NSString *volumePath = [NSString stringWithFormat:@"%@/%@/%@", [self qingwenPath], bookId, volumeId];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:volumePath error:nil];

    VolumeCD *volumeCD = [VolumeCD MR_findFirstByAttribute:@"nid" withValue:volumeId inContext:[QWFileManager qwContext]];
    [volumeCD setDeleted];

    if (write) {
        [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];
    }
}

+ (BOOL)isVolumeDownloadedWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId update_time:(NSDate *)update_time
{
    VolumeVO *downloadedVolumeVO = [VolumeVO voWithJson:[QWFileManager loadVolumeWithBookId:bookId volumeId:volumeId]];
    
    if ((downloadedVolumeVO && downloadedVolumeVO.updated_time && [update_time timeIntervalSinceDate:downloadedVolumeVO.updated_time] <= 1)) {
        //timeIntervalSinceDate 可能会有毫秒的误差
        return YES;
    }

    return NO;
}

+ (BOOL)isVolumeDownloadedAnyVersionWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId
{
    VolumeVO *downloadedVolumeVO = [VolumeVO voWithJson:[QWFileManager loadVolumeWithBookId:bookId volumeId:volumeId]];
    return downloadedVolumeVO != nil;
}


//3.2.0

+ (NSString *)chapterPathWithBooId:(NSString *)bookId volumeId:(NSString *)volumeId
{
    NSAssert(bookId, @"bookId 不能为空");
    NSAssert(volumeId, @"volumeId 不能为空");
    
    NSString *bookFolder = [[self qingwenPath] stringByAppendingPathComponent:bookId];
    NSString *chapterPath = [bookFolder stringByAppendingPathComponent:volumeId];
    [self createFolderIfNeeded:chapterPath];
    return chapterPath;
}

+ (NSString *)filePathWithFileName:(NSString *)fileName bookId:(NSString *)bookId volumeId:(NSString *)volumeId
{
    NSAssert(fileName, @"fileName 不能为空");
    NSAssert(bookId, @"bookId 不能为空");
    NSAssert(volumeId, @"volumeId 不能为空");
    
    NSString *chapterPath = [self chapterPathWithBooId:bookId volumeId:volumeId];
    NSString *path = [chapterPath stringByAppendingPathComponent:fileName];
    return path;
}


//存取某一卷 Volume.json
+ (void)saveVolumeWithBookId:(NSString *)bookId volumeJson:(NSString *)volumeJson volumeId:(NSString *)volumeId {
    NSAssert(bookId, @"bookId 不能为空");
    NSAssert(volumeJson, @"volume Json不能为空");
    NSAssert(volumeId, @"volumeId 不能为空");
    
    
    NSString *path = [self filePathWithFileName:@"volume.json" bookId:bookId volumeId:volumeId];
    [volumeJson writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}

                          
//存取某一章 Chapters.json
+ (void)saveChaptersWithBookId:(NSString *)bookId ChapterJson:(NSString *)chapterJson volumeId:(NSString *)volumeId {
    NSAssert(bookId, @"bookId 不能为空");
    NSAssert(chapterJson, @"chapter Json不能为空");
    NSAssert(volumeId, @"volumeId 不能为空");
    
    NSString *path = [self filePathWithFileName:@"chapter.json" bookId:bookId volumeId:volumeId];
    //    NSString *path = [volumePath stringByAppendingPathComponent:@"volume"];
    
    [chapterJson writeToFile:path atomically:true encoding:NSUTF8StringEncoding error:nil];
}

//是否存取了某一个章节
+ (BOOL)isContentSavedWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId chapterId:(NSString *)chapterId
{
    NSAssert(bookId, @"bookId 不能为空");
    NSAssert(chapterId, @"chapterId 不能为空");
    NSAssert(volumeId, @"volumeId 不能为空");
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/chapter/%@.json",[self qingwenPath],volumeId,chapterId];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path]) {
        return YES;
    }
    return NO;
}

+ (void)saveContentWithJson:(NSString *)json bookId:(NSString *)bookId volumeId:(NSString *)volumeId chapterId:(NSString *)chapterId {
    NSAssert(json, @"content json 不能为空");
    NSAssert(bookId, @"bookId 不能为空");
    NSAssert(chapterId, @"chapterId 不能为空");
    
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:json];
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@/chapter",[self qingwenPath],bookId,volumeId];
    [self createFolderIfNeeded:path];
    NSString *jsonPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json",chapterId]];
    [json writeToFile:jsonPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

//设置某一章下载完成
+ (void)setDoneWithBookId:(NSString *)bookId chapterId:(NSString *)chapterId
{
    NSAssert(bookId, @"bookId 不能为空");
    NSAssert(chapterId, @"chapterId 不能为空");
    
//    NSString *path = [self filePathWithFileName:@"content_done" bookId:bookId chapterId:chapterId];
//    [[NSData data] writeToFile:path atomically:YES];
}

//是否完整下载了某个章节，包括图片
+ (BOOL)isChapterDownloadedWithBookId:(NSString *)bookId chapterId:(NSString *)chapterId
{
    NSAssert(bookId, @"bookId 不能为空");
    NSAssert(chapterId, @"chapterId 不能为空");
    
//    NSString *path = [self filePathWithFileName:@"content_done" bookId:bookId chapterId:chapterId];
//    NSFileManager *manager = [NSFileManager defaultManager];
//    if ([manager fileExistsAtPath:path]) {
//        return YES;
//    }
    
    return NO;
}
//存储图片内容
+ (void)saveImageWithImage:(UIImage *)image bookId:(NSString *)bookId volumeId:(NSString *)volumeId contentFileName:(NSString *)fileName
{
    NSAssert(image, @"image 不能为空");
    NSAssert(bookId, @"bookId 不能为空");
    NSAssert(volumeId, @"chapterId 不能为空");
    
    NSString *valuePath = [[QWFileManager qingwenPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/",bookId,volumeId]];
    NSArray *pathComponents = fileName.pathComponents;
    NSString *filePath = [fileName stringByReplacingOccurrencesOfString:pathComponents.lastObject withString:@""];
    NSString *imageFloader = [valuePath stringByAppendingPathComponent:filePath];
    [self createFolderIfNeeded:imageFloader];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);

    [imageData writeToFile:[valuePath stringByAppendingPathComponent:fileName] atomically:YES];
}

//是否已经存在某个卷
+ (BOOL)isVolumeExitWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId {
    NSAssert(bookId, @"bookId 不能为空");
    NSAssert(volumeId, @"VolumeId不能为空");
    NSString *bookPath = [[self qingwenPath]stringByAppendingPathComponent:bookId];
    NSString *volumePath = [bookPath stringByAppendingPathComponent:volumeId];
    
    return  [self isFileExistWithFileUrl:volumePath];
}

//是否存在某一个章节
+ (BOOL)isChapterExitWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId chapterId:(NSString *)chapterId {
//    NSAssert(bookId, @"bookId 不能为空");
//    NSAssert(volumeId, @"VolumeId不能为空");
    NSString *bookPath = [[self qingwenPath]stringByAppendingPathComponent:bookId];
    NSString *volumePath = [bookPath stringByAppendingPathComponent:volumeId];
    NSString *chapterPath = [volumePath stringByAppendingPathComponent:[NSString stringWithFormat:@"chapter/%@.json",chapterId]];
    
    return  [self isFileExistWithFileUrl:chapterPath];
}

#pragma mark - webView缓存
+ (NSString *)webpPath{
    [self createFolderIfNeeded:[[self qingwenPath] stringByAppendingPathComponent:@"webP"]];
    return [[self qingwenPath] stringByAppendingPathComponent:@"webP"];
}
//存储图片的地址
+ (NSString *)getWebImagePathWithUrl:(NSString *)url {
    NSString *replaceUrl = [url stringByReplacingOccurrencesOfString:@"." withString:@"-"];
    replaceUrl = [replaceUrl stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    replaceUrl = [replaceUrl stringByReplacingOccurrencesOfString:@"webp" withString:@"xx"];
    replaceUrl = [replaceUrl stringByAppendingString:@".jpg"];
    
    NSString *path = [[self webpPath] stringByAppendingPathComponent:replaceUrl];
    
    return path;
}
//是否存储某图片
+ (BOOL)isExitWithUrl:(NSString *)url {
    NSString *replaceUrl = [url stringByReplacingOccurrencesOfString:@"." withString:@"-"];
    replaceUrl = [replaceUrl stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    replaceUrl = [replaceUrl stringByReplacingOccurrencesOfString:@"webp" withString:@"xx"];
    replaceUrl = [replaceUrl stringByAppendingString:@".jpg"];
    NSString *path = [[self webpPath] stringByAppendingPathComponent:replaceUrl];
    
    return [self isFileExistWithFileUrl:path];
}

+ (NSMutableArray *)GetAllBookFilesPath:(NSString *)bookId{
    NSString *bookPath = [[self qingwenPath]stringByAppendingPathComponent:bookId];

    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *chapterArray = [[NSMutableArray alloc] init];
    NSArray *fileList = [[NSArray alloc] init];
    fileList = [fileManager contentsOfDirectoryAtPath:bookPath error:nil];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:bookPath];
    
    //遍历属性
    NSString *fileName;
    //下面这个方法最为关键 可以给fileName赋值，获得文件名（带文件后缀）。
    while (fileName = [enumerator nextObject]) {
        if([fileName containsString:@"/chapter/"]){
            NSRange range = [fileName rangeOfString:@"/chapter/"];
            fileName = [fileName substringFromIndex:range.location + range.length];
            [chapterArray addObject:fileName];
        }

    }
    
   return chapterArray;
}
@end
