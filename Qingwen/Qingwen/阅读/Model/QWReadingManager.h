//
//  QWReadingManager.h
//  Qingwen
//
//  Created by Aimy on 7/27/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VolumeCD;
@class VolumeVO;
@class QWReadingVC;
@class BookCD;
#import "BookPageVO.h"
#import "VolumeList.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QWReadingContentType) {
    QWReadingContentTypeContent = 0,//文字内容
    QWReadingContentTypeImage,//本地图片
    QWReadingContentTypeNetImage,//网络图片
    QWReadingContentTypeChapter,//章节开始加载，显示封面
    QWReadingContentTypeChapterDone,//章节加载结束

    QWReadingContentTypeError = 999,//错误
};

typedef void(^QWReadingContentCompletionBlock)(id __nullable content, QWReadingContentType type);

@interface QWReadingManager : NSObject

+ (QWReadingManager * __nonnull)sharedInstance;

@property (nonatomic, strong, readonly, nullable) BookCD *bookCD;//书
@property (nonatomic, strong, readonly, nullable) VolumeVO *currentVolumeVO;//当前卷VO
@property (nonatomic, strong, readonly, nullable) VolumeList *volumes;

@property (nonatomic) BOOL offline;//离线阅读

//在线阅读
- (void)startOnlineReadingWithBookId:(NSNumber * __nonnull)bookId volumes:(VolumeList * __nonnull)volumes;

//离线阅读
- (void)startOfflineReadingWithBookId:(NSNumber * __nonnull)bookId volumes:(VolumeList * __nonnull)volumes;

//停止阅读，释放资源
- (void)stopReading;

//释放资源
- (void)didReceiveMemoryWarning;

#pragma mark - 弹幕状态
- (void)recordBookDanmuStatus:(BOOL)status;
- (BOOL)isOpenDanmu;

#pragma mark - 获取内容

//通过vc计算当前的内容
- (void)getReadingContentWithReadingVC:(QWReadingVC *)readingVC andCompleteBlock:(QWReadingContentCompletionBlock)aBlock;

//通过vc获取某一页vc
- (QWReadingVC *)getPageAtIndex:(NSInteger)index readingVC:(QWReadingVC *)currentVC;

//通过vc获取下一页vc
- (QWReadingVC *)getNextPageReadingVCWithCurrentReadingVC:(QWReadingVC *)currentVC;

//通过vc获取上一页vc
- (QWReadingVC *)getPreviousPageReadingVCWithCurrentReadingVC:(QWReadingVC *)currentVC;

//通过vc获取下一章vc
- (QWReadingVC *)getNextChapterReadingVCWithCurrentReadingVC:(QWReadingVC *)currentVC;

//通过vc获取上一章vc
- (QWReadingVC *)getPreviousChapterReadingVCWithCurrentReadingVC:(QWReadingVC *)currentVC;

//通过vc获取某一章
- (QWReadingVC *)getChapterReadingVCWithChapterIndex:(NSInteger)index currentVC:(QWReadingVC *)currentVC;

- (QWReadingVC *)getChapterReadingVCWithBook:(BookVO *)book volumes:(VolumeList *)volumes indexPath:(NSIndexPath *)indexPath currentVC:(QWReadingVC *)currentVC;
-(NSNumber *)getChapterIdWithReadingVC:(QWReadingVC *)readingVC;
@end

NS_ASSUME_NONNULL_END
