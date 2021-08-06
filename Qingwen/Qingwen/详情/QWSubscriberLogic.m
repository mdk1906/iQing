//
//  QWSubscriberLogic.m
//  Qingwen
//
//  Created by mumu on 16/10/8.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import "QWSubscriberLogic.h"
#import "QWJsonKit.h"

@implementation QWSubscriberLogic

//订阅全书
- (void)doSubscriberBookWithBook:(NSNumber *)bookId useVoucher:(NSNumber *)useVoucher andCompleteBlock:(QWCompletionBlock)aBlock;
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
    if (useVoucher.integerValue == 1) {
        params[@"currency"] = @"coin";
    }else{
        params[@"currency"] = @"gold";
    }
    params[@"async"] = @"1";
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/subscriber/%@/book_pay/",[QWOperationParam currentDomain], bookId] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
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
//查询单章价格
- (void)getSubscriberChapterCostWithChapterId:(NSNumber *)chapterId andCompleteBlock:(QWCompletionBlock)aBlock {
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return;
    }
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/subscriber/%@/chapter_amount/",[QWOperationParam currentDomain], chapterId] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
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
//订阅单章是否适用购书券
- (void)doSubscriberChaperWithChapterId:(NSNumber *)chapterId useVoucher:(NSNumber *)useVoucher andCompleteBlock:(QWCompletionBlock)aBlock {
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return;
    }
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    if (useVoucher.integerValue == 1) {
        params[@"currency"] = @"coin";
    }else{
        params[@"currency"] = @"gold";
    }
    if (self.autoPurechase.boolValue) {
        params[@"auto_purchase"] = self.autoPurechase;
    }
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/subscriber/%@/chapter_pay/",[QWOperationParam currentDomain], chapterId] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
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
//按卷购买
- (void)doSubscriberChaperWithVolumeId:(NSNumber *)volumeId useVoucher:(NSNumber *)useVoucher bookId:(NSNumber*)bookId andCompleteBlock:(QWCompletionBlock)aBlock {
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return;
    }
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
//    params[@"book"] = [NSString stringWithFormat:@"%@",bookId];
//    params[@"volume_id"] = [NSString stringWithFormat:@"%@",volumeId];
    if (useVoucher.integerValue == 1) {
        params[@"currency"] = @"coin";
    }else{
        params[@"currency"] = @"gold";
    }
    if (self.autoPurechase.boolValue) {
        params[@"auto_purchase"] = self.autoPurechase;
    }
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/subscriber/%@/volume_pay/",[QWOperationParam currentDomain], volumeId] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
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
//查询是否订阅书籍
- (void)getPurchaseListWithBookId:(NSNumber *)bookId andCompleteBlock:(QWCompletionBlock)aBlock {
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"book"] = bookId;
    
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/subscriber/auto_purchase_list/",[QWOperationParam currentDomain]] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
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

//登陆状态下查询订阅已订阅列表
- (void)getSubscriberChaptersWithBookId:(NSNumber *)bookId andCompleteBlock:(QWCompletionBlock)aBlock {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
//    params[@"limit"] = @1;
    
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/subscriber/%@/chapter_payed_list/?limit=99999",[QWOperationParam currentDomain], bookId] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            self.subscriberList = [SubscriberList voWithDict:aResponseObject];
            if (aBlock) {
                aBlock(self.subscriberList, nil);
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
//登录状态下查询多章购买价格
- (void)getSubscriberChaptersWithChapterList:(NSArray *)ChapterList andCompleteBlock:(QWCompletionBlock)aBlock {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    //    params[@"limit"] = @1;
    params[@"chapter_id_list"] = ChapterList;
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/subscriber/chapter_multi_amount/ ",[QWOperationParam currentDomain]] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            self.subscriberList = [SubscriberList voWithDict:aResponseObject];
            if (aBlock) {
                aBlock(self.subscriberList, nil);
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
- (void)doSubscriberMultipleChapterWithChapterIdList:(NSArray *)chapterIdList bookId:(NSNumber *)bookId  useVoucher:(NSNumber *)useVoucher andCompleteBlock:(QWCompletionBlock)aBlock{
    NSMutableDictionary *contents = @{}.mutableCopy;
    contents[@"token"] = [QWGlobalValue sharedInstance].token;
    contents[@"chapter_id_list"] = chapterIdList;
    contents[@"book"] = bookId;
    contents[@"async"] = @"1";
    if (useVoucher.integerValue == 1) {
        contents[@"currency"] = @"coin";
    }else{
        contents[@"currency"] = @"gold";
    }
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"data"] = [QWJsonKit stringFromDict:contents];
    
    
    QWOperationParam *param = [QWInterface getWithDomainUrl:@"subscriber/chapter_pay_multi/" params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (aResponseObject && !anError) {
            aBlock(aResponseObject, anError);
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
//查询是否购买成功
-(void)QueryWhetherBuySuccessWithKey:(NSString *)key andCompleteBlock:(QWCompletionBlock)aBlock{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return;
    }
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"key"] = key;
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/subscriber/check_chapter_pay_multi_process/",[QWOperationParam currentDomain]] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
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
//查询全书订阅价格
- (void)getSubscriberInfoWithBookId:(NSNumber *)bookId andCompleteBlock:(QWCompletionBlock)aBlock {
    
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return;
    }
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/subscriber/%@/book_amount/",[QWOperationParam currentDomain], bookId] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
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

#pragma mark - 演绘
- (void)getGameChapterWithChapterId:(NSString *)chapterId andCompleteBlocK:(QWCompletionBlock)aBlock {

}

- (void)doSubscriberGameChapterWithChapterId:(NSString *)chapterId gameId:(NSString *)gameId andCompleteBlock:(QWCompletionBlock)aBlock {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"chapter"] = chapterId;
    
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/game/%@/buy/",[QWOperationParam currentDomain], gameId] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
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
@end
