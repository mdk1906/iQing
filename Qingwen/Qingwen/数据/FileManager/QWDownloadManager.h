//
//  QWDownloadManager.h
//  Qingwen
//
//  Created by Aimy on 7/16/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QWFileManager.h"
#import "QWDownloadItem.h"

NS_ASSUME_NONNULL_BEGIN

extern const NSString * kQWImageHost;


@interface QWDownloadManager : NSObject

+ (QWDownloadManager * __nonnull)sharedInstance;

//本卷是否正在下载
- (BOOL)isDownloadingWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId;

//本书（单章下载）是否正在下载
- (BOOL)isDownloadingWithBookId:(NSString *)bookId;

//停止下载
- (void)stopDownloadWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId;

//获取正在下载的downloaditem
- (QWDownloadItem *)getDownloadingItemWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId;

//获取不是正在下载的对象item，（可能断开了下载，但是是下载的状态）
//- (QWDownloadItem *)getUnStartDownloadItemWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId;

////下载全书
//- (QWDownloadItem *)downloadWithBookVO:(BookVO *)bookVO volumeVO:(VolumeVO *)volumeVO;
//下载选定章节
- (QWDownloadItem *)downloadWithChapters:(NSArray *)chapter volume:(VolumeVO *)volume book:(BookVO *)book;
@end

NS_ASSUME_NONNULL_END
