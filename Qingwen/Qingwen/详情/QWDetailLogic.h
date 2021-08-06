//
//  QWDetailLogic.h
//  Qingwen
//
//  Created by Aimy on 7/6/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBaseLogic.h"

#import "UserPageVO.h"
#import "SubscriberList.h"
@class DirectoryVO;
@class BookVO;
@class ListVO;
@class VolumeList;
@class VolumeVO;

@interface QWDetailLogic : QWBaseLogic

@property (nonatomic, strong) BookVO *bookVO;
@property (nonatomic, strong) ListVO *likeList;
@property (nonatomic, strong) FavoriteBooksVO *favBooks;
@property (nonatomic, copy) NSNumber *discussLastCount;
@property (nonatomic, copy) NSString *discussUrl;
@property (nonatomic, copy) NSNumber *attention;

@property (nonatomic, copy) UserPageVO *userPageVO;
@property (nonatomic, copy) UserPageVO *heavyUserPageVO;

@property (nonatomic, strong) VolumeList *volumeList;
@property (nonatomic, strong) NSArray *chapters;

//3.2.0
@property (nonatomic, copy) UserPageVO *subscriberPageVO;
@property (nonatomic, copy) UserPageVO *faithPageVO;
@property (nonatomic, copy) UserPageVO *awardDymicPageVO;

- (void)getDirectoryWithUrl:(NSString *)url andCompleteBlock:(QWCompletionBlock)aBlock;

- (void)getDetailWithBookName:(NSString *)bookName andCompleteBlock:(QWCompletionBlock)aBlock;
- (void)getDetailWithBookId:(NSString *)bookId andCompleteBlock:(QWCompletionBlock)aBlock;
- (void)getDetailWithBookUrl:(NSString *)book_url andCompleteBlock:(QWCompletionBlock)aBlock;
- (void)doAttentionWithCompleteBlock:(QWCompletionBlock)aBlock;
- (void)getAttentionWithCompleteBlock:(QWCompletionBlock)aBlock;
- (void)doAttentionWithParams:(NSString*)s_url andCompleteBlock:(QWCompletionBlock)aBlock;
- (void)getLikeWithCompleteBlock:(QWCompletionBlock)aBlock;
- (void)getDiscussLastCountWithCompleteBlock:(QWCompletionBlock)aBlock;
- (void)getVolumeWithCompleteBlock:(QWCompletionBlock)aBlock;
- (void)getContributionVolumeWithCompleteBlock:(QWCompletionBlock)aBlock;

- (void)getChapterWithUrl:(NSString *)url andCompleteBlock:(QWCompletionBlock)aBlock;

- (void)getVolumeDownloadWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId url:(NSString *)url andCompleteBlock:(QWCompletionBlock)aBlock;

//3.2.0
//废弃
- (void)getHeavyChargeWithCompleteBlock:(QWCompletionBlock)aBlock;
- (void)getChargeWithCompleteBlock:(QWCompletionBlock)aBlock;
- (void)doChargeWithCoin:(NSInteger)coin andCompleteBlock:(QWCompletionBlock)aBlock;
- (void)doChargeWithGold:(NSInteger)gold andCompleteBlock:(QWCompletionBlock)aBlock;
- (void)doChargeToFavorite:(NSInteger)type amount:(NSInteger)amount andCompleteBlock:(QWCompletionBlock)aBlock;
//新增
- (void)getSubscriberListWithCompleteBlock:(QWCompletionBlock)aBlock;
- (void)getFaithPageWithCompleteBlock:(QWCompletionBlock)aBlock;
- (void)getAwardDymicPageWithCompleteBlock:(QWCompletionBlock)aBlock;
- (void)getSubscriberInfoWithCompleteBlock:(QWCompletionBlock)aBlock;
- (void)getVoteInfoWithCompleteBlock:(QWCompletionBlock)aBlock;
- (void)getVoteActivityInfoWithCompleteBlock:(QWCompletionBlock)aBlock;

//购买信息
-(void)getPaidInfoWithUrl:(NSString *)url CompleteBlock:(QWCompletionBlock)aBlock;

- (BOOL)canRead;
@end
