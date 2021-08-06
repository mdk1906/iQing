//
//  QWDetailLogic.m
//  Qingwen
//
//  Created by Aimy on 7/6/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWDetailLogic.h"

#import "BookVO.h"
#import "QWInterface.h"
#import "ListVO.h"
#import "VolumeList.h"
#import "QWFileManager.h"

@implementation QWDetailLogic

- (void)getDetailWithBookName:(NSString *)bookName andCompleteBlock:(QWCompletionBlock)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;
    bookName = [bookName stringByReplacingOccurrencesOfString:@"《" withString:@""];
    bookName = [bookName stringByReplacingOccurrencesOfString:@"》" withString:@""];
    
    params[@"title"] = bookName;

    QWOperationParam *param = [QWInterface getWithDomainUrl:@"book/match/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
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

- (void)getDetailWithBookId:(NSString *)bookId andCompleteBlock:(QWCompletionBlock)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"id"] = bookId;

    QWOperationParam *param = [QWInterface getWithUrl:[QWOperationParam currentDomain] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
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

- (void)getDetailWithBookUrl:(NSString *)book_url andCompleteBlock:(QWCompletionBlock)aBlock
{
    QWOperationParam *param = [QWInterface getWithUrl:book_url andCompleteBlock:^(id aResponseObject, NSError *anError) {
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

- (void)getDirectoryWithUrl:(NSString *)url andCompleteBlock:(QWCompletionBlock)aBlock
{
    QWOperationParam *param = [QWInterface getWithUrl:url andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            VolumeList *listVO = [VolumeList voWithDict:aResponseObject];
            self.volumeList = listVO;
            if (aBlock) {
                aBlock(self.volumeList, nil);
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
-(void)getPaidInfoWithUrl:(NSString *)url CompleteBlock:(QWCompletionBlock)aBlock{
    QWOperationParam *param = [QWInterface getWithUrl:url andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            VolumeList *listVO = [VolumeList voWithDict:aResponseObject];
            self.volumeList = listVO;
            if (aBlock) {
                aBlock(self.volumeList, nil);
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
- (void)getHeavyChargeWithCompleteBlock:(QWCompletionBlock)aBlock
{
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@gold_merit_rank/", self.bookVO.url] andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            UserPageVO *vo = [UserPageVO voWithDict:aResponseObject];
            if (IS_IPHONE_DEVICE && vo.results.count > 3) {
                vo.results = (id)[vo.results subarrayWithRange:NSMakeRange(0, 3)];
            }
            self.heavyUserPageVO = vo;
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

    [self.operationManager requestWithParam:param];
}

- (void)getChargeWithCompleteBlock:(QWCompletionBlock)aBlock
{
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@merit_rank/", self.bookVO.url] andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            UserPageVO *vo = [UserPageVO voWithDict:aResponseObject];
            if (IS_IPHONE_DEVICE && vo.results.count > 5) {
                vo.results = (id)[vo.results subarrayWithRange:NSMakeRange(0, 5)];
            }
            self.userPageVO = vo;
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

    [self.operationManager requestWithParam:param];
}

- (void)doChargeToFavorite:(NSInteger)type amount:(NSInteger)amount andCompleteBlock:(QWCompletionBlock)aBlock
{
    if (! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return;
    }
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"amount"] = @(amount);//[QWGlobalValue sharedInstance].token;
    if(type == 0){
        params[@"currency"] = @"coin";
    }else{
        params[@"currency"] = @"gold";
    }
    
    
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/favorite/%@/reward/", [QWOperationParam currentFAVBooksDomain],self.favBooks.nid] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (!anError) {
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
    param.useV4 = YES;
    [self.operationManager requestWithParam:param];
}

- (void)doChargeWithCoin:(NSInteger)coin andCompleteBlock:(QWCompletionBlock)aBlock
{
    if (! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];

        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return;
    }

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"coin"] = @(coin);

    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@tip/", self.bookVO.url] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (!anError) {
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

- (void)doChargeWithGold:(NSInteger)gold andCompleteBlock:(QWCompletionBlock)aBlock
{
    if (! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];

        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return;
    }

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"gold"] = @(gold);

    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@award/", self.bookVO.url] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (!anError) {
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

- (void)doAttentionWithParams:(NSString*)s_url andCompleteBlock:(QWCompletionBlock)aBlock
{
    if (! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return;
    }
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    
    NSString *url = self.attention.boolValue ? self.bookVO.unsubscribe_url : self.bookVO.subscribe_url;
    
    if(s_url != nil){
        url = s_url;
    }
    
    QWOperationParam *param = [QWInterface getWithUrl:url params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if ([code isEqualToNumber:@0]) {
                if (self.attention.boolValue) {
                    self.attention = @0;
                    if (self.bookVO.follow_count.integerValue) {
                        self.bookVO.follow_count = @(self.bookVO.follow_count.integerValue - 1);
                    }
                    else {
                        self.bookVO.follow_count = @0;
                    }
                }
                else {
                    self.attention = @1;
                    self.bookVO.follow_count = @(self.bookVO.follow_count.integerValue + 1);
                }
            }
            
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

- (void)doAttentionWithCompleteBlock:(QWCompletionBlock)aBlock
{
    [self doAttentionWithParams:nil andCompleteBlock:aBlock];
}

- (void)getAttentionWithCompleteBlock:(QWCompletionBlock)aBlock
{
    if (! [QWGlobalValue sharedInstance].isLogin) {

        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return;
    }

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    NSLog(@"state_url = %@",self.bookVO.state_url);
    QWOperationParam *param = [QWInterface getWithUrl:self.bookVO.state_url params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            self.attention = aResponseObject[@"subscription"];
            if (aBlock) {
                aBlock(self.attention, nil);
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

- (void)getLikeWithCompleteBlock:(QWCompletionBlock)aBlock
{
    QWOperationParam *param = [QWInterface getWithUrl:self.bookVO.like_url andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            ListVO *listVO = [ListVO voWithDict:aResponseObject];
            self.likeList = listVO;

            if (aBlock) {
                aBlock(self.likeList, nil);
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

- (void)getDiscussLastCountWithCompleteBlock:(QWCompletionBlock)aBlock
{
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@last_count/", self.bookVO.bf_url] andCompleteBlock:^(id aResponseObject, NSError *anError) {
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

    [self.operationManager requestWithParam:param];
}

- (void)getVolumeWithCompleteBlock:(QWCompletionBlock)aBlock
{
    QWOperationParam *param = [QWInterface getWithUrl:self.bookVO.volume_url andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            VolumeList *listVO = [VolumeList voWithDict:aResponseObject];
            self.volumeList = listVO;
            if (aBlock) {
                aBlock(self.volumeList, nil);
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

- (void)getContributionVolumeWithCompleteBlock:(QWCompletionBlock)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"type"] = @1;

    QWOperationParam *param = [QWInterface getWithUrl:self.bookVO.volume_url params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            VolumeList *listVO = [VolumeList voWithDict: aResponseObject];
            self.volumeList = listVO;
            if (aBlock) {
                aBlock(self.volumeList, nil);
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

- (void)getChapterWithUrl:(NSString *)url andCompleteBlock:(QWCompletionBlock)aBlock
{
    QWOperationParam *param = [QWInterface getWithUrl:url andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            NSArray *chapters = [ChapterVO arrayOfModelsFromDictionaries:aResponseObject error:NULL];
            self.chapters = chapters;
            if (aBlock) {
                aBlock(self.chapters, nil);
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

- (void)getVolumeDownloadWithBookId:(NSString *)bookId volumeId:(NSString *)volumeId url:(NSString *)url andCompleteBlock:(QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return;
    }

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;

    QWOperationParam *param = [QWInterface getWithUrl:url params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
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
    param.filePath = [NSString stringWithFormat:@"%@/%@/%@", [QWFileManager qingwenPath], bookId, volumeId];
    [self.operationManager downloadFileWithParam:param];
}

//查询订阅动态
- (void)getSubscriberListWithCompleteBlock:(QWCompletionBlock)aBlock {
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"limit"] = @3;
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/subscriber/%@/book_new_feed/",[QWOperationParam currentDomain], self.bookVO.nid] params: params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            UserPageVO *listVO = [UserPageVO voWithDict: aResponseObject];
            self.subscriberPageVO = listVO;
            if (aBlock) {
                aBlock(self.subscriberPageVO, nil);
            }
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];
//    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}
//查询信仰殿堂
- (void)getFaithPageWithCompleteBlock:(QWCompletionBlock)aBlock {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"limit"] = @5;
    
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/book/%@/points/",[QWOperationParam currentDomain], self.bookVO.nid] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            UserPageVO *listVO = [UserPageVO voWithDict: aResponseObject];
            self.faithPageVO = listVO;
            if (aBlock) {
                aBlock(self.faithPageVO, nil);
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
//查询投石动态
- (void)getAwardDymicPageWithCompleteBlock:(QWCompletionBlock)aBlock {
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"limit"] = @3;
    
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/book/%@/award_new_feed/",[QWOperationParam currentDomain], self.bookVO.nid] params: params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            UserPageVO *listVO = [UserPageVO voWithDict: aResponseObject];
            self.awardDymicPageVO = listVO;
            if (aBlock) {
                aBlock(self.awardDymicPageVO, nil);
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
//查询全书订阅价格
- (void)getSubscriberInfoWithCompleteBlock:(QWCompletionBlock)aBlock {
    
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return;
    }
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/subscriber/%@/book_amount/",[QWOperationParam currentDomain], self.bookVO.nid] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
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

//查询投票活动详情
- (void)getVoteInfoWithCompleteBlock:(QWCompletionBlock)aBlock{
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"work_id"] = self.bookVO.nid;
    params[@"work_type"] = @"1";
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    
    QWOperationParam *param = [QWInterface postWithDomainUrl:[NSString stringWithFormat:@"vote/%@/item/",self.bookVO.extra[@"vote"]] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
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

//查询投票活动
-(void)getVoteActivityInfoWithCompleteBlock:(QWCompletionBlock)aBlock{
    
    NSMutableDictionary *params = @{}.mutableCopy;
    QWOperationParam *param = [QWInterface getWithDomainUrl:[NSString stringWithFormat:@"vote/%@/",self.bookVO.extra[@"vote"]] params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
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

- (BOOL)canRead{
    NSDictionary *dict = QWGlobalValue.sharedInstance.systemSwitchesDic;
    
    NSString *type = [dict[@"work"] stringValue];
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
