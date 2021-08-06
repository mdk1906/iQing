//
//  QWFileManager.h
//  Qingwen
//
//  Created by Aimy on 7/3/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QWFileManager : NSObject

+ (NSManagedObjectContext *)qwContext;

+ (NSString *)usedSpaceAndfreeSpace;

//历史记录
+ (NSArray *)loadHistory;
+ (void)saveHistory:(NSArray *)historys;

//初始化目录
+ (void)configDirectory;

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

+ (BOOL)isSpaceAvailable;

//存储的目录
+ (NSString *)libPath;
+ (NSString *)qingwenPath;
+ (NSString *)bookPath:(NSString *)bookId;
+ (void)createFolderIfNeeded:(NSString *)folder;

//文件是否存在
+ (BOOL)isFileExistWithFileUrl:(NSString *)url;

#pragma mark - 书
//书是否下载完毕
+ (BOOL)isVolumeDownloadedWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId update_time:(NSDate *)update_time;
+ (BOOL)isVolumeDownloadedAnyVersionWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId;

//删除书的卷
+ (void)deleteBookWithBookId:(NSString *)bookId;
+ (void)deleteVolumeWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId write:(BOOL)write;

#pragma mark - 目录
//加载书
+ (NSString *)loadBookWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId;
//加载书的封面
+ (UIImage *)loadBookCoverWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId;
//加载卷
+ (NSString *)loadVolumeWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId;
//加载卷的章
+ (NSString *)loadChapterWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId;
//加载章的内容
+ (NSString *)loadContentWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId chapterId:(NSString *)chapterId;
//图片地址
+ (NSString *)imagePathWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId chapterId:(NSString *)chapterId imageName:(NSString *)imageName;

//存取某一卷 Volume.json
+ (void)saveVolumeWithBookId:(NSString *)bookId volumeJson:(NSString *)volumeJson volumeId:(NSString *)volumeId;
//存取某一章 Chapters.json
+ (void)saveChaptersWithBookId:(NSString *)bookId ChapterJson:(NSString *)chapterJson volumeId:(NSString *)volumedId;

//3.2.0 单张下载
#pragma mark - 图片
//存储图片内容
+ (void)saveImageWithImage:(UIImage *)image bookId:(NSString *)bookId volumeId:(NSString *)volumeId contentFileName:(NSString *)fileName;

#pragma mark - 章节
//设置某一章下载完成
+ (void)setDoneWithBookId:(NSString *)bookId chapterId:(NSString *)chapterId;

//查询是否有某个章节的内容
+ (BOOL)isContentSavedWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId chapterId:(NSString *)chapterId;
//存储内容
+ (void)saveContentWithJson:(NSString *)json bookId:(NSString *)bookId volumeId:(NSString *)volumeId chapterId:(NSString *)chapterId;

//是否完整下载了某个章节，包括图片
+ (BOOL)isChapterDownloadedWithBookId:(NSString *)bookId chapterId:(NSString *)chapterId;

//是否已经存在某个卷
+ (BOOL)isVolumeExitWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId;

//是否存在某一个章节
+ (BOOL)isChapterExitWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId chapterId:(NSString *)chapterId;

#pragma mark - webView缓存
//存储图片的地址
+ (NSString *)getWebImagePathWithUrl:(NSString *)url;
//是否存储某图片
+ (BOOL)isExitWithUrl:(NSString *)url;

+ (NSMutableArray *)GetAllBookFilesPath:(NSString *)bookId;
@end

NS_ASSUME_NONNULL_END
