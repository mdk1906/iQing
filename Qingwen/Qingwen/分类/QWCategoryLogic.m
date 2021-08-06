//
//  QWCategoryLogic.m
//  Qingwen
//
//  Created by Aimy on 7/4/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWCategoryLogic.h"

#import "QWInterface.h"

@implementation QWCategoryLogic

- (void)getCategoryWithCompleteBlock:(QWCompletionBlock)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;

    QWOperationParam *param = [QWInterface getCategoryWithParams:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            CategoryVO *vo = [CategoryVO voWithDict:aResponseObject];
            self.categoryVO = vo;
            if (aBlock) {
                aBlock(self.categoryVO, nil);
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

- (void)getCategoryDiscussWithCompleteBlock:(QWCompletionBlock)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;

    QWOperationParam *param = [QWInterface getCategoryDiscussWithParams:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            self.discussItems = [CategoryDiscussVO arrayOfModelsFromDictionaries:aResponseObject error:NULL];
            if (aBlock) {
                aBlock(self.discussItems, nil);
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
