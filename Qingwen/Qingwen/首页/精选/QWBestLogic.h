//
//  QWBestLogic.h
//  Qingwen
//
//  Created by Aimy on 7/3/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBaseLogic.h"

#import "BestVO.h"
#import "ListVO.h"
#import "UserPageVO.h"
#import "PromotionListVO.h"
#import "EntranceVO.h"

NS_ASSUME_NONNULL_BEGIN

@interface QWBestLogic : QWBaseLogic

@property (nonatomic, strong, nullable) BestVO *slideVO;
@property (nonatomic, strong, nullable) NSArray *discussItems;
@property (nonatomic, strong, nullable) BestVO *bestVO; //主编推荐

@property (nonatomic, strong, nullable) BestVO *smallBestVO; //小编推荐
@property (nonatomic, strong, nullable) BestVO *newlyWorkVO;   //新秀推荐
@property (nonatomic, strong, nullable) BestVO *hotWorkVO;   //热门作品
@property (nonatomic, strong, nullable) BestVO *dicountWorkVO; //打折作品推荐
@property (nonatomic, strong, nullable) ListVO *updateListVO; //最近更新
@property (nonatomic, strong, nullable) BestVO *zoneRecommendVO; //分区推荐

@property (nonatomic, strong, nullable) NSNumber *channel; //QWChannelType

@property (nonatomic, strong, nullable) NSArray *entrances; //入口图

@property (nonatomic, assign) BOOL showActivityPageNumber;

//轮播图
- (void)getSlideWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock;
//推荐
- (void)getRecommendWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock;
//小编推荐
- (void)getSmallBestVOWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock;
//新秀推荐
- (void)getNewlyWorkVOWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock;
//热门推荐
- (void)getHotWorkVOWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock;
//限时优惠
- (void)getDicountWorkVOWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock;
//分区推荐
- (void)getZoneRecommendVOWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock;
//最近更新
- (void)getUpdateListVOWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock;

- (void)getOngoingActivityListWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock;

- (BOOL)isShow;

- (void)getPromotionCookiesWithUrl:(NSString *)url andCompleteBlock:(QWCompletionBlock _Nullable)aBlock;

@end

NS_ASSUME_NONNULL_END
