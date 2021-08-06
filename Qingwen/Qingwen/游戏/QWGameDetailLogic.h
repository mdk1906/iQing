//
//  QWGameDetailLogic.h
//  Qingwen
//
//  Created by Aimy on 7/6/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBaseLogic.h"

#import "UserPageVO.h"

@class DirectoryVO;
@class BookVO;
@class ListVO;
@class VolumeList;
@class VolumeVO;

NS_ASSUME_NONNULL_BEGIN

@interface QWGameDetailLogic : QWBaseLogic

@property (nonatomic, strong, nullable) BookVO *bookVO;
@property (nonatomic, strong, nullable) ListVO *likeList;
@property (nonatomic, copy, nullable) NSNumber *discussLastCount;
@property (nonatomic, copy, nullable) NSString *discussUrl;
@property (nonatomic, copy, nullable) NSNumber *attention;
@property (nonatomic, copy, nullable) NSNumber *check;

@property (nonatomic, copy, nullable) UserPageVO *userPageVO;
@property (nonatomic, copy, nullable) UserPageVO *heavyUserPageVO;

@property (nonatomic, strong, nullable) VolumeList *volumeList;
@property (nonatomic, strong, nullable) NSArray *chapters;

@property (nonatomic, copy) UserPageVO *faithPageVO;
@property (nonatomic, copy) UserPageVO *awardDymicPageVO;

//提交弹幕
- (void)submitDanmu:(NSString *)key content:(NSString *)content completeBlock:(QWCompletionBlock _Nullable)aBlock;

- (void)getDirectoryWithUrl:(NSString * _Nullable)url andCompleteBlock:(QWCompletionBlock)aBlock;

- (void)getDetailWithBookName:(NSString * _Nullable)bookName andCompleteBlock:(QWCompletionBlock)aBlock;
- (void)getDetailWithBookId:(NSString * _Nullable)bookId andCompleteBlock:(QWCompletionBlock)aBlock;
- (void)getDetailWithBookUrl:(NSString * _Nullable)book_url andCompleteBlock:(QWCompletionBlock)aBlock;
//获取重石
- (void)getHeavyChargeWithCompleteBlock:(QWCompletionBlock)aBlock;
//获取轻石
- (void)getChargeWithCompleteBlock:(QWCompletionBlock)aBlock;
//是否购买
- (void)doBuyWithCompleteBlock:(QWCompletionBlock)aBlock;

- (void)doChargeWithCoin:(NSInteger)coin andCompleteBlock:(QWCompletionBlock)aBlock;
- (void)doChargeWithGold:(NSInteger)gold andCompleteBlock:(QWCompletionBlock)aBlock;
- (void)checkWithCompleteBlock:(QWCompletionBlock)aBlock;
- (void)doAttentionWithCompleteBlock:(QWCompletionBlock)aBlock;
- (void)getAttentionWithCompleteBlock:(QWCompletionBlock)aBlock;
- (void)getLikeWithCompleteBlock:(QWCompletionBlock)aBlock;
- (void)getDiscussLastCountWithCompleteBlock:(QWCompletionBlock)aBlock;
- (void)getVolumeWithCompleteBlock:(QWCompletionBlock)aBlock;
- (void)getContributionVolumeWithCompleteBlock:(QWCompletionBlock)aBlock;

- (void)getChapterWithUrl:(NSString * _Nullable)url andCompleteBlock:(QWCompletionBlock)aBlock;

- (void)getVolumeDownloadWithBookId:(NSString * _Nullable)bookId volumeId:(NSString * _Nullable)volumeId url:(NSString * _Nullable)url andCompleteBlock:(QWCompletionBlock)aBlock;

- (void)getFaithPageWithCompleteBlock:(QWCompletionBlock)aBlock;
- (void)getAwardDymicPageWithCompleteBlock:(QWCompletionBlock)aBlock;

//获取演绘独有的channel_token
- (void)getChannelTokenWithCompleteBlock:(QWCompletionBlock)aBlock;
- (void)getVoteInfoWithCompleteBlock:(QWCompletionBlock)aBlock;
- (void)getVoteActivityInfoWithCompleteBlock:(QWCompletionBlock)aBlock;

- (BOOL)canRead;
@end

NS_ASSUME_NONNULL_END
