//
//  QWGameLogic.h
//  Qingwen
//
//  Created by Aimy on 5/15/16.
//  Copyright © 2016 iQing. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface QWGameLogic: QWBaseLogic

@property (nonatomic, strong, nullable) BestVO *slideVO;
@property (nonatomic, strong, nullable) BestVO *bestVO;

@property (nonatomic, strong, nullable) ListVO *goldVO;
@property (nonatomic, strong, nullable) ListVO *dayVO;
@property (nonatomic, strong, nullable) ListVO *bookRallyVO;
@property (nonatomic, strong, nullable) ListVO *goldRallyVO;

@property (nonatomic, strong, nullable) NSNumber *channel; //QWChannelType

//轮播图
- (void)getSlideWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock;

//推荐
- (void)getRecommendWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock;

//重石热榜 0日，1周
- (void)getHeavyCoinRankListWithType:(NSInteger)type andCompleteBlock:(QWCompletionBlock _Nullable)aBlock;
//全站热榜 0日，1周
- (void)getRankListWithType:(NSInteger)type andCompleteBlock:(QWCompletionBlock _Nullable)aBlock;

//全站轻石上升
- (void)getBookRallyWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock;
//全站重石上升
- (void)getGoldRallyWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock;

- (BOOL)isShow;

@end

NS_ASSUME_NONNULL_END
