//
//  QWGameLogic.m
//  Qingwen
//
//  Created by Aimy on 5/15/16.
//  Copyright © 2016 iQing. All rights reserved.
//

#import "QWGameLogic.h"

@implementation QWGameLogic

- (void)getSlideWithCompleteBlock:(QWCompletionBlock)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"type"] = @2;
    params[@"channel"] = self.channel;
    
    QWOperationParam *param = [QWInterface getWithDomainUrl:@"gamerecommend/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            BestVO *vo = [BestVO voWithDict:aResponseObject];
            self.slideVO = vo;
            
            if (aBlock) {
                aBlock(self.slideVO, nil);
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

- (void)getRecommendWithCompleteBlock:(QWCompletionBlock)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"type"] = @3;
    
    QWOperationParam *param = [QWInterface getWithDomainUrl:@"gamerecommend/" params:nil andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            BestVO *vo = [BestVO voWithDict:aResponseObject];

            if (IS_IPHONE_DEVICE && vo.results.count > 6) {
                vo.results = (id)[vo.results subarrayWithRange:NSMakeRange(0, 6)];
            }

            self.bestVO = vo;

            if (aBlock) {
                aBlock(self.bestVO, nil);
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

- (void)getRankListWithType:(NSInteger)type andCompleteBlock:(QWCompletionBlock)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"channel"] = self.channel;

    QWOperationParam *param = [QWInterface getWithDomainUrl:@"game/tiprankall/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            ListVO *vo = [ListVO voWithDict:aResponseObject];
            if (IS_IPHONE_DEVICE && vo.results.count > 3) {
                vo.results = (id)[vo.results subarrayWithRange:NSMakeRange(0, 3)];
            }

            self.dayVO = vo;

            if (aBlock) {
                aBlock(self.dayVO, nil);
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

- (void)getHeavyCoinRankListWithType:(NSInteger)type andCompleteBlock:(QWCompletionBlock _Nullable)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"period"] = @(type);
    params[@"channel"] = self.channel;

    QWOperationParam *param = [QWInterface getWithDomainUrl:@"game/awardrankall/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            ListVO *vo = [ListVO voWithDict:aResponseObject];
            if (IS_IPHONE_DEVICE && vo.results.count > 3) {
                vo.results = (id)[vo.results subarrayWithRange:NSMakeRange(0, 3)];
            }
            self.goldVO = vo;
            if (aBlock) {
                aBlock(self.goldVO, nil);
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


- (BOOL)isShow
{
    return self.bestVO && self.dayVO;
}

- (void)getBookRallyWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"channel"] = self.channel;

    QWOperationParam *param = [QWInterface getWithDomainUrl:@"game/tiprallyrank/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            ListVO *vo = [ListVO voWithDict:aResponseObject];

            if (IS_IPHONE_DEVICE && vo.results.count > 4) {
                vo.results = (id)[vo.results subarrayWithRange:NSMakeRange(0, 4)];
            }

            self.bookRallyVO = vo;

            if (aBlock) {
                aBlock(self.bookRallyVO, nil);
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

- (void)getGoldRallyWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"channel"] = self.channel;

    QWOperationParam *param = [QWInterface getWithDomainUrl:@"game/awardrallyrank/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            ListVO *vo = [ListVO voWithDict:aResponseObject];
            
            if (IS_IPHONE_DEVICE && vo.results.count > 4) {
                vo.results = (id)[vo.results subarrayWithRange:NSMakeRange(0, 4)];
            }
            
            self.goldRallyVO = vo;
            
            if (aBlock) {
                aBlock(self.goldRallyVO, nil);
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

@end
