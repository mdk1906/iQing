//
//  QWSquareLogic.h
//  Qingwen
//
//  Created by mumu on 17/3/25.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWBestLogic.h"
#import "SquareVO.h"
#import "StoneRankVO.h"
@interface QWSquareLogic : QWBaseLogic

@property (nonatomic, strong, nullable) PromotionListVO *promotionVO;
@property (nonatomic, strong, nullable) NSDictionary *stoneRankVO;
@property (nonatomic, strong, nullable) NSArray<SquareVO> *hotDiscussList;

@property (nonatomic, nullable, copy) NSNumber *discussLastCount; //少年讨论更新数

//获取男性讨论区更新数
- (void)getDiscussLastCountWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock;

//活动
- (void)getPromotionWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock;
//投石榜
- (void)getStoneRankWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock;
//热门讨论
- (void)getHotDuscussListWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock;

- (BOOL)isShow;
- (BOOL)showHot;
@end
