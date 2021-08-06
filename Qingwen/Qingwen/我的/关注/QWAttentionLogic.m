//
//  QWAttentionLogic.m
//  Qingwen
//
//  Created by Aimy on 8/24/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWAttentionLogic.h"

#import "QWInterface.h"

@implementation QWAttentionLogic

- (void)getFriendWithUrl:(NSString *)aUrl andCompleteBlock:(QWCompletionBlock)aBlock
{
    if (![QWGlobalValue sharedInstance].isLogin) {
        //如果为空，代表未登录，不需要获取个人信息
        [self showToastWithTitle:@"请重新登录" subtitle:nil type:ToastTypeAlert];
        return ;
    }

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;

    NSString *currentUrl = aUrl;
    if (self.friendListVO.next) {
        currentUrl = self.friendListVO.next;
    }

    QWOperationParam *param = [QWInterface getWithUrl:currentUrl params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            FriendListVO *vo = [FriendListVO voWithDict:aResponseObject];
            if (self.friendListVO.results.count) {
                [self.friendListVO addResultsWithNewPage:vo];
            }
            else {
                self.friendListVO = vo;
            }

            if (aBlock) {
                aBlock(self.friendListVO, nil);
            }
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];

    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

- (void)unfollowFriendWithUrl:(NSString *)aUrl andCompleteBlock:(QWCompletionBlock)aBlock
{
    if (![QWGlobalValue sharedInstance].isLogin) {
        //如果为空，代表未登录，不需要获取个人信息
        [self showToastWithTitle:@"请重新登录" subtitle:nil type:ToastTypeAlert];
        return ;
    }

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;

    QWOperationParam *param = [QWInterface getWithUrl:aUrl params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aBlock) {
            aBlock(aResponseObject, anError);
        }
    }];

    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

- (void)followFriendWithUrl:(NSString *)aUrl andCompleteBlock:(QWCompletionBlock)aBlock
{
    if (![QWGlobalValue sharedInstance].isLogin) {
        //如果为空，代表未登录，不需要获取个人信息
        [self showToastWithTitle:@"请重新登录" subtitle:nil type:ToastTypeAlert];
        return ;
    }

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;

    QWOperationParam *param = [QWInterface getWithUrl:aUrl params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aBlock) {
            aBlock(aResponseObject, anError);
        }
    }];

    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

- (void)getFansWithUrl:(NSString *)aUrl andCompleteBlock:(QWCompletionBlock)aBlock
{
    if (![QWGlobalValue sharedInstance].isLogin) {
        //如果为空，代表未登录，不需要获取个人信息
        [self showToastWithTitle:@"请重新登录" subtitle:nil type:ToastTypeAlert];
        return ;
    }

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;

    NSString *currentUrl = aUrl;
    if (self.fanListVO.next) {
        currentUrl = self.fanListVO.next;
    }

    QWOperationParam *param = [QWInterface getWithUrl:currentUrl params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            FriendListVO *vo = [FriendListVO voWithDict:aResponseObject];
            if (self.fanListVO.results.count) {
                [self.fanListVO addResultsWithNewPage:vo];
            }
            else {
                self.fanListVO = vo;
            }

            if (aBlock) {
                aBlock(self.fanListVO, nil);
            }
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];

    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

@end
