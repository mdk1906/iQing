//
//  QWListLogic.m
//  Qingwen
//
//  Created by Aimy on 7/4/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWListLogic.h"

#import "QWInterface.h"

@implementation QWListLogic

- (void)getWithUrl:(NSString *)aUrl andCompleteBlock:(QWCompletionBlock)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;

    if (self.channelType) {
        params[@"channel"] = @(self.channelType);
    }

    if (self.period) {
        params[@"period"] = self.period;
    }
    if (self.category) {
        params[@"category"] = self.category;
    }
    if (self.type) {
        params[@"type"] = self.type;
    }
    
    switch (self.sortType) {
        case QWSortTypeTime:
            params[@"field"] = @"updated_time";
            break;
        default:
            break;
    }

    NSString *currentUrl = aUrl;
    if (self.listVO.next.length) {
        currentUrl = self.listVO.next;
    }

    QWOperationParam *param = [QWInterface getWithUrl:currentUrl params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            ListVO *vo = [ListVO voWithDict:aResponseObject];
            if (self.listVO.results.count) {
                [self.listVO addResultsWithNewPage:vo];
            }
            else {
                self.listVO = vo;
            }
            
            if (aBlock) {
                aBlock(self.listVO, nil);
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

- (void)getWithUrl1:(nullable NSString *)aUrl1 andCompleteBlock:(nullable QWCompletionBlock)aBlock {
    NSMutableDictionary *params = @{}.mutableCopy;

    if (self.channelType) {
        params[@"channel"] = @(self.channelType);
    }
    if (self.order) {
        params[@"order"] = self.order;
    }else {
        params[@"order"] = @"update";
    }
    if (self.works) {
        params[@"works"] = self.works;
    } else {
        params[@"works"] = @"all";
    }
    NSString *currentUrl = aUrl1;
    if (self.listVO.next.length) {
        currentUrl = self.listVO.next;
    }
    QWOperationParam *param = [QWInterface getWithUrl:currentUrl params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            ListVO *vo = [ListVO voWithDict:aResponseObject];
            if (self.listVO.results.count) {
                [self.listVO addResultsWithNewPage:vo];
            }
            else {
                self.listVO = vo;
            }
            
            if (aBlock) {
                aBlock(self.listVO, nil);
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

- (void)getBoutiqueWithUrl:(nullable NSString *)aUrl andCompleteBlock:(nullable QWCompletionBlock)aBlock {
    NSMutableDictionary *params = @{}.mutableCopy;
    if (self.channelType) {
        params[@"channel"] = @(self.channelType);
    }
    if (self.order) {
        params[@"order"] = self.order;
    } else {
        params[@"order"] = @"update";
    }
    if (self.rank.integerValue > 0) {
        params[@"rank"] = self.rank;
    } else {
        params[@"rank"] = @(4);
    }
    NSString *currenUrl = aUrl;
    if (self.listVO.next.length) {
        currenUrl = self.listVO.next;
    }
    QWOperationParam *param = [QWInterface getWithUrl:currenUrl params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (aResponseObject && !anError) {
            ListVO *vo = [ListVO voWithDict:aResponseObject];
            if (self.listVO.count) {
                [self.listVO addResultsWithNewPage:vo];
            }
            else {
                self.listVO = vo;
            }
            if (aBlock) {
                aBlock(vo, anError);
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

