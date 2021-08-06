//
//  QWSubscriberLogic.h
//  Qingwen
//
//  Created by mumu on 16/10/8.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import "QWBaseLogic.h"
#import "SubscriberList.h"
@interface QWSubscriberLogic : QWBaseLogic

#pragma mark - 书

@property (nonatomic, copy) NSNumber *autoPurechase;

@property (nonatomic, strong) SubscriberList *subscriberList;

- (void)doSubscriberBookWithBook:(NSNumber *)bookId useVoucher:(NSNumber *)useVoucher andCompleteBlock:(QWCompletionBlock)aBlock;

- (void)getSubscriberChapterCostWithChapterId:(NSNumber *)chapterId andCompleteBlock:(QWCompletionBlock)aBlock;

- (void)doSubscriberChaperWithChapterId:(NSNumber *)chapterId useVoucher:(NSNumber *)useVoucher andCompleteBlock:(QWCompletionBlock)aBlock;

- (void)getPurchaseListWithBookId:(NSNumber *)bookId andCompleteBlock:(QWCompletionBlock)aBlock;

- (void)getSubscriberChaptersWithBookId:(NSNumber *)bookId andCompleteBlock:(QWCompletionBlock)aBlock;

- (void)doSubscriberMultipleChapterWithChapterIdList:(NSArray *)chapterIdList
                                              bookId:(NSNumber *)bookId
                                          useVoucher:(NSNumber *)useVoucher
                                    andCompleteBlock:(QWCompletionBlock)aBlock;

- (void)getSubscriberInfoWithBookId:(NSNumber *)bookId andCompleteBlock:(QWCompletionBlock)aBlock;
- (void)doSubscriberChaperWithVolumeId:(NSNumber *)volumeId useVoucher:(NSNumber *)useVoucher bookId:(NSNumber*)bookId andCompleteBlock:(QWCompletionBlock)aBlock;
//登录状态下查询多章购买价格
- (void)getSubscriberChaptersWithChapterList:(NSArray *)ChapterList andCompleteBlock:(QWCompletionBlock)aBlock;
//查询是否购买成功
-(void)QueryWhetherBuySuccessWithKey:(NSString *)key andCompleteBlock:(QWCompletionBlock)aBlock;
#pragma mark - 演绘
- (void)getGameChapterWithChapterId:(NSString *)chapterId andCompleteBlocK:(QWCompletionBlock)aBlock;
- (void)doSubscriberGameChapterWithChapterId:(NSString *)chapterId gameId:(NSString *)gameId andCompleteBlock:(QWCompletionBlock)aBlock;

@end
