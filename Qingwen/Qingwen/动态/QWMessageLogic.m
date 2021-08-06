//
//  QWMessageLogic.m
//  Qingwen
//
//  Created by Aimy on 8/21/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWMessageLogic.h"

#import "QWInterface.h"

@implementation QWMessageLogic

- (void)getFeedWithUrl:(NSString *)url completeBlock:(QWCompletionBlock)aBlock
{
    if (! [QWGlobalValue sharedInstance].isLogin) {
        self.messageListVO = nil;
        
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return;
    }

    NSMutableDictionary *params = @{}.mutableCopy;

    NSString *currentUrl = url;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    if (self.messageListVO.next) {
        currentUrl = self.messageListVO.next;
    }

    QWOperationParam *param = [QWInterface getWithUrl:currentUrl params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (!anError) {
            MessageListVO *vo = [MessageListVO voWithDict:aResponseObject];
            if (self.messageListVO.results.count) {
                [self.messageListVO addResultsWithNewPage:vo];
            }
            else {
                self.messageListVO = vo;
            }

            if (aBlock) {
                aBlock(self.messageListVO, nil);
            }
        }
        else {
            if (! [QWGlobalValue sharedInstance].isLogin) {
                self.messageListVO = nil;
            }
            
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];
    param.useOrigin = YES;
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

- (void)migrateWithBookIds:(NSArray *)ids andCompleteBlock:(QWCompletionBlock)block
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;

    if (ids.count > 200) {
        ids = [ids subarrayWithRange:NSMakeRange(0, 200)];
    }

    params[@"books"] = [ids componentsJoinedByString:@","];

    QWOperationParam *param = [QWInterface getWithUrl:[QWGlobalValue sharedInstance].user.book_sync_url params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (block) {
            block(aResponseObject, anError);
        }
    }];
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

@end
