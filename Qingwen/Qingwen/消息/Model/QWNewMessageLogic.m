//
//  QWNewMessageLogic.m
//  Qingwen
//
//  Created by mumu on 17/3/3.
//  Copyright © 2017年 iQing. All rights reserved.
//


#import "QWNewMessageLogic.h"
#import "QWRandomGenerateTool.h"

static NSInteger start = 0;

static NSInteger end = 0;

static NSInteger limit = 0;

@implementation QWNewMessageLogic

/**
 * 获取对话列表
 */
- (void)getTalkListWithCompletBlock:(QWCompletionBlock)completeBlock {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [[QWGlobalValue sharedInstance] token];
    
    QWOperationParam *param = [QWInterface getWithDomainUrl:[NSString stringWithFormat:@"messages/message_interface/"] params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (!anError) {
            if (![self handleResponse:aResponseObject]) {
                completeBlock(nil, anError);
                return;

            }
            self.talkList = nil;
            self.talkList = [TalkListVO voWithDict:aResponseObject];
            if (completeBlock) {
                completeBlock(self.talkList, anError);
            }
        }
        else {
            if (completeBlock) {
                completeBlock(nil, anError);
            }
        }
    }];
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}
/**
 获取单个对话列表
 */
- (void)getSingelMessageListWithTargetId:(NSNumber *)targetId andCompletBlock:(QWCompletionBlock)completBlock {

    if (!targetId) {
        return;
    }
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"other_id"] = targetId;
    NSString *url = [NSString stringWithFormat:@"%@/messages/message_content/?",[QWOperationParam currentDomain]];
    if (self.messageList) {
        [self updateEndAndStart];
        params[@"end"] = @(end);
        params[@"start"] = @(start);
        url = [url stringByAppendingString: [NSString stringWithFormat:@"start=%ld&end=%ld",start, end]];
    }

    QWOperationParam *param = [QWInterface getWithUrl:url params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (!anError) {
            if (![self handleResponse:aResponseObject]) {
                completBlock(nil, anError);
                return;
            }
            NewMessageListVO *list = [NewMessageListVO voWithDict:aResponseObject];
            list = [self computeVisibleTime:list];
            if (completBlock && list) {
                if (!self.messageList) {
                    self.messageList = list;
                    start = list.all_count.intValue - list.count.integerValue;
                    end = list.all_count.integerValue;
                    limit = list.count.integerValue;
                    self.messageList.end = limit;
                }
                else {
                    [self.messageList addResultsWithNewPage:list];
                }
                completBlock(self.messageList, anError);
            }
            else {
                if (completBlock) {
                    completBlock(nil, anError);
                }
            }
        }
    }];
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

- (void)getUnreadMessageListWithStart:(NSInteger)startIndex end:(NSInteger)endIndex andTargetId:(NSNumber *)targetId andCompletBlock:(QWCompletionBlock)completBlock; {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"other_id"] = targetId;
     NSString *url = [NSString stringWithFormat:@"%@/messages/message_content/?start=%ld&end=%ld",[QWOperationParam currentDomain],startIndex,endIndex];
    QWOperationParam *param = [QWInterface getWithUrl:url params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (!anError) {
            if (![self handleResponse:aResponseObject]) {
                completBlock(nil, anError);
                return;
            }
            NewMessageListVO *list = [NewMessageListVO voWithDict:aResponseObject];
            list = [self computeVisibleTime:list];
            if (completBlock && list) {
                self.messageList = list;
                start = startIndex;
                end = endIndex;
                
                completBlock(self.messageList, anError);
            }
            else {
                if (completBlock) {
                    completBlock(nil, anError);
                }
            }
        }
    }];
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

- (void)updateEndAndStart{
    NSInteger preStart = start - limit;
    end = start;
    if (preStart < 0) {
        self.messageList.end = start;
        start = 0;
    }else {
        start = preStart;
        self.messageList.end = limit;
    }
}

- (BOOL)handleResponse:(id)aResponseObject {
    if (!aResponseObject) {
        return false;
    }
    if ([aResponseObject objectForKey:@"code"] != 0) {
        if ([aResponseObject objectForKey:@"msg" ]) {
            [self showToastWithTitle:(NSString *)[aResponseObject objectForKey:@"msg" ] subtitle:nil type:ToastTypeError];
            return false;
        }
    }
    return true;
}

-(NewMessageListVO *)computeVisibleTime:(NewMessageListVO *)messageList{
    NSMutableArray *copyList = messageList.message_list.copy;
    
    NSDate *lastCreated_time = [NSDate new];
    @autoreleasepool {
        for (int i = 0; i < copyList.count; i ++) {
            NewMessageVO *message = copyList[i];
            
            if (i == 0) {
                message.showDateTime = true;
                lastCreated_time = message.created_time;
            }
            else {
                if ([message.created_time minutesAfterDate:lastCreated_time] > 5) {
                    message.showDateTime = true;
                    lastCreated_time = message.created_time;
                    message.showDateTime = true;
                }
            }
        }
    }
    
    messageList.message_list = (NSArray <NewMessageVO> *)copyList;
    return messageList;
}

@end
