//
//  QWDownloadItem.h
//  Qingwen
//
//  Created by Aimy on 7/16/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BookVO.h"
#import "VolumeVO.h"

NS_ASSUME_NONNULL_BEGIN

@interface QWDownloadItem : NSObject

@property (nonatomic, copy, readonly) NSString *bookId;
@property (nonatomic, copy, readonly) NSString *volumeId;
@property (nonatomic, strong, readonly) BookVO *book;
@property (nonatomic, strong, readonly) VolumeVO *volume;

@property (nonatomic, strong, readonly) QWOperationManager *operationManager;


@property (nonatomic, readonly) int64_t totalCount;//总进度
@property (nonatomic, readonly) int64_t downloadCount;//下载的进度

@property (nonatomic, readonly, getter=isCompleted) BOOL completed;//完成
@property (nonatomic, readonly, getter=isErrorCompleted) BOOL errorCompleted;//完成,但是有内容没有下载下来
@property (nonatomic, readonly) BOOL start;//是否开始了

//初始化
- (void)configWithBook:(BookVO * __nonnull)book volume:(VolumeVO * __nonnull)volume;
- (void)clearItem;//停止清除

- (void)updateWithChapterId:(NSString * __nonnull)chapterId andImageCount:(NSInteger)imageCount;//某一章的内容下载完了
- (void)updateWithErrorWithChapterId:(NSString * __nonnull)chapterId;//某一章的内容下载出错
- (void)updateSubCountWithChapterId:(NSString * __nonnull)chapterId;//某一章的某一张图片下载完成了
- (void)updateSubCountErrorWithChapterId:(NSString * __nonnull)chapterId;//某一章的某一张图片下载失败了

@end

NS_ASSUME_NONNULL_END
