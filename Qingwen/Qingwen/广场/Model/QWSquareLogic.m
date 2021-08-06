//
//  QWSquareLogic.m
//  Qingwen
//
//  Created by mumu on 17/3/25.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWSquareLogic.h"

@implementation QWSquareLogic

- (void)getDiscussLastCountWithCompleteBlock:(QWCompletionBlock)aBlock
{
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/brand/55dfe20f9d2fd159f2bbc125/last_count/",[QWOperationParam currentBfDomain]] andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            self.discussLastCount = aResponseObject[@"count"];
            
            if (aBlock) {
                aBlock(self.discussLastCount, nil);
            }
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];
    param.useOrigin = YES;
    [self.operationManager requestWithParam:param];
}

//活动
- (void)getPromotionWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"channel"] = @1;
    
    QWOperationParam *param = [QWInterface getWithDomainUrl:@"climax/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            PromotionListVO *vo = [PromotionListVO voWithDict:aResponseObject];
            self.promotionVO = vo;
            if (aBlock) {
                aBlock(self.promotionVO, nil);
            }
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];
    
    [self.operationManager requestWithParam:param];
}
//投石榜
- (void)getStoneRankWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock {
    NSMutableDictionary *params = @{}.mutableCopy;
//    params[@"channel"] = @1;
    
    QWOperationParam *param = [QWInterface getWithDomainUrl:@"v3/statistic/book/week_gold_merit_rank/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            self.stoneRankVO = aResponseObject;
            if (aBlock) {
                aBlock(self.stoneRankVO, nil);
            }
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];
    
    [self.operationManager requestWithParam:param];
}
//热门讨论
- (void)getHotDuscussListWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock {
    
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/v3/brand/brand_hot_rank/",[QWOperationParam currentBfDomain]] andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (aResponseObject && !anError) {
            NSError *error;
            NSArray *list = [SquareVO arrayOfModelsFromDictionaries:aResponseObject error:&error];
            self.hotDiscussList = (NSArray<SquareVO> *)list;
            if (aBlock) {
                if (error) {
                    NSLog(@"jsonModel 解析错误 通知后端");
                    aBlock(nil, error);
                }
                else {
                    aBlock(self.hotDiscussList, anError);
                }
            }
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];
    param.useOrigin = true;
    [self.operationManager requestWithParam:param];
}

- (BOOL)isShow {
    return self.hotDiscussList && self.promotionVO;
}
- (BOOL)showHot{
    NSDictionary *dict = QWGlobalValue.sharedInstance.systemSwitchesDic;
    NSLog(@"[QWGlobalValue sharedInstance]123 = %@",dict);
   NSString *type = [dict[@"hot_discuss"] stringValue];
    if ([type isEqualToString:@"2"]) {
        return NO;
    }
    else if ([type isEqualToString:@"1"]) {
        if ([QWGlobalValue sharedInstance].isLogin == NO) {
            return NO;
        }
        else{
            return YES;
        }
    }
    else  {
        return YES;
    }
}
@end
