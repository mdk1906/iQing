//
//  QWDiscussLogic.m
//  Qingwen
//
//  Created by Aimy on 8/11/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWDiscussLogic.h"
#import "QWBlacListManager.h"
#import "QWInterface.h"
#import "DiscussVO.h"
#import "QWJsonKit.h"

@implementation QWDiscussLogic

- (void)getBrandWithUrl:(NSString * __nonnull)aUrl andCompleteBlock:(__nullable QWCompletionBlock)aBlock {
    QWOperationParam *param = [QWInterface getWithUrl:aUrl andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (aResponseObject && !anError) {
            if (aBlock) {
                aBlock(aResponseObject, nil);
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

- (void)getAuthorWithUrl:(NSString * __nonnull)aUrl andCompleteBlock:(__nullable QWCompletionBlock)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;

    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@is_author/", aUrl] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            self.own = aResponseObject[@"author"];

            if (aBlock) {
                aBlock(nil, nil);
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

//0设置,1取消设置
- (void)setTopWithUrl:(NSString * __nonnull)aUrl type:(BOOL)type andCompleteBlock:(__nullable QWCompletionBlock)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;

    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@%@/", aUrl, type ? @"cancel_top" : @"set_top"] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            if (aBlock) {
                aBlock(aResponseObject, nil);
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
//0设置,1取消设置
- (void)setDiggestWithUrl:(NSString * __nonnull)aUrl type:(BOOL)type andCompleteBlock:(__nullable QWCompletionBlock)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;

    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@%@/", aUrl, type ? @"cancel_diggest" : @"set_diggest"] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            if (aBlock) {
                aBlock(aResponseObject, nil);
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
//0帖子,1回复
- (void)submitReportWithId:(NSString * __nonnull)nid type:(BOOL)type content:(NSString *)content andCompleteBlock:(__nullable QWCompletionBlock)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"uuid"] = nid;
    if (content) {
        params[@"content"] = content;
    }
    if (type) {
        params[@"type"] = @1;
    }
    else {
        params[@"type"] = @2;
    }

    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/brand/report/",[QWOperationParam currentBfDomain]] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            if (aBlock) {
                aBlock(aResponseObject, nil);
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

- (void)deleteDiscussWithId:(NSString * __nonnull)nid type:(BOOL)type andCompleteBlock:(__nullable QWCompletionBlock)aBlock {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"uuid"] = nid;
    if (type) {
        params[@"type"] = @1;
    }
    else {
        params[@"type"] = @2;
    }
    
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/brand/delete/",[QWOperationParam currentBfDomain]] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            if (aBlock) {
                aBlock(aResponseObject, nil);
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

- (void)getDiscussDetailWithID:(NSString *)nid andCompleteBlock:(QWCompletionBlock)aBlock
{

    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/post/%@/", [QWOperationParam currentBfDomain],nid] andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            DiscussItemVO *vo = [DiscussItemVO voWithDict:aResponseObject];
            if (aBlock) {
                aBlock(vo, nil);
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

- (void)getDiscussLastCountWithUrl:(NSString *)url andCompleteBlock:(QWCompletionBlock)aBlock
{
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@last_count/", url] andCompleteBlock:^(id aResponseObject, NSError *anError) {
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

- (void)getBestDiscussWithUrl:(NSString *)aUrl andCompleteBlock:(QWCompletionBlock)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;

    NSString *currentUrl = [NSString stringWithFormat:@"%@digest/",aUrl];
    if (self.bestDiscussVO.next.length) {
        currentUrl = self.bestDiscussVO.next;
    }

    QWOperationParam *param = [QWInterface getWithUrl:currentUrl params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            DiscussVO *vo = [DiscussVO voWithDict:aResponseObject];

            if (self.bestDiscussVO.results.count) {
                [self.bestDiscussVO addResultsWithNewPage:[[QWBlacListManager sharedInstance] shieldBlackDiscuss:vo]];
            }
            else {
                self.bestDiscussVO = [[QWBlacListManager sharedInstance] shieldBlackDiscuss:vo];
            }

            if (aBlock) {
                aBlock(self.bestDiscussVO, nil);
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

- (void)getDiscussWithUrl:(NSString *)aUrl andCompleteBlock:(QWCompletionBlock)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;

    NSString *currentUrl = [NSString stringWithFormat:@"%@post_list/?%f",aUrl,[[NSDate date] timeIntervalSince1970]];
    if (self.discussVO.next.length) {
        currentUrl = self.discussVO.next;
    }

    QWOperationParam *param = [QWInterface getWithUrl:currentUrl params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            DiscussVO *vo = [DiscussVO voWithDict:aResponseObject];

            if (self.discussVO.results.count) {
                [self.discussVO addResultsWithNewPage:[[QWBlacListManager sharedInstance] shieldBlackDiscuss:vo]];
            }
            else {
                self.discussVO = [[QWBlacListManager sharedInstance] shieldBlackDiscuss:vo];
            }

            if (aBlock) {
                aBlock(self.discussVO, nil);
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

- (void)getDiscussDetailWithUrl:(NSString *)aDiscussUrl andCompleteBlock:(QWCompletionBlock)aBlock
{

    QWOperationParam *param = [QWInterface getWithUrl:aDiscussUrl andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            DiscussItemVO *vo = [DiscussItemVO voWithDict:aResponseObject];
            if (aBlock) {
                aBlock(vo, nil);
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

- (void)getTopDiscussWithUrl:(NSString *)aUrl andCompleteBlock:(QWCompletionBlock)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;
    
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@top/?%f",aUrl,[[NSDate date] timeIntervalSince1970]] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            DiscussVO *vo = [DiscussVO voWithDict:aResponseObject];
            self.topDiscussVO = [[QWBlacListManager sharedInstance] shieldBlackDiscuss:vo];
            
            if (aBlock) {
                aBlock(self.topDiscussVO, nil);
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

- (void)getCommentWithUrl:(NSString *)aUrl lonely:(BOOL)lonely andCompleteBlock:(QWCompletionBlock)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;

    NSString *url = nil;
    if (lonely) {
        url = [NSString stringWithFormat:@"%@lonely/?%f",aUrl,[[NSDate date] timeIntervalSince1970]];
    }
    else {
        url = [NSString stringWithFormat:@"%@thread/?%f",aUrl,[[NSDate date] timeIntervalSince1970]];
    }

    NSString *currentUrl = url;
    if (self.commentVO.next.length) {
        currentUrl = self.commentVO.next;
    }

    QWOperationParam *param = [QWInterface getWithUrl:currentUrl params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            DiscussVO *vo = [DiscussVO voWithDict:aResponseObject];

            if (self.commentVO.results.count) {
                [self.commentVO addResultsWithNewPage:[[QWBlacListManager sharedInstance] shieldBlackDiscuss:vo]];
            }
            else {
                self.commentVO = [[QWBlacListManager sharedInstance] shieldBlackDiscuss:vo];
            }

            if (aBlock) {
                aBlock(self.commentVO, nil);
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

-(void) getPostCommentsWithID:(NSString * __nonnull)nid andCompleteBlock:(__nullable QWCompletionBlock)aBlock{
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/v3/post/%@/send_log/?refer=1", [QWOperationParam currentBfDomain],nid] andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
//            DiscussItemVO *vo = [DiscussItemVO voWithDict:aResponseObject];
//            if (aBlock) {
//                aBlock(vo, nil);
//            }
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
- (void)createDiscussWithUrl:(NSString *)aUrl content:(NSString *)content paths:(NSArray * __nullable)paths andCompleteBlock:(QWCompletionBlock)aBlock
{
    NSMutableDictionary *contents = @{}.mutableCopy;
    contents[@"token"] = [QWGlobalValue sharedInstance].token;
    contents[@"title"] = @" ";
    contents[@"content"] = content;
    contents[@"illustration"] = paths;
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"data"] = [QWJsonKit stringFromDict:contents];

    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@add_post/",aUrl] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            if (aBlock) {
                aBlock(aResponseObject, nil);
            }
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];

    param.requestType = QWRequestTypePost;
    param.paramsUseData = YES;
    [self.operationManager requestWithParam:param];
}

- (void)createCommentWithUrl:(NSString *)aUrl content:(NSString *)content refer:(NSNumber *)order paths:(NSArray * __nullable)paths andCompleteBlock:(QWCompletionBlock)aBlock
{
    NSMutableDictionary *contents = @{}.mutableCopy;
    contents[@"token"] = [QWGlobalValue sharedInstance].token;
    contents[@"content"] = content;
    if (order) {
        contents[@"refer"] = order;
    }
    contents[@"illustration"] = paths;
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"data"] = [QWJsonKit stringFromDict:contents];

    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@add_thread/",aUrl] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            if (aBlock) {
                aBlock(aResponseObject, nil);
            }
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];

    param.paramsUseData = YES;
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

- (BOOL)isPureExpression:(NSString *)content
{
    __block NSInteger length = 0;
    content = [content stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[QWExpressionManager sharedManager].pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> *result = [regex matchesInString:content options:0 range:NSMakeRange(0, content.length)];
    [result enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        length += obj.range.length;
    }];

    return length == content.length;
}

@end
