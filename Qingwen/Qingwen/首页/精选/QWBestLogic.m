//
//  QWBestLogic.m
//  Qingwen
//
//  Created by Aimy on 7/3/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBestLogic.h"

#import "QWInterface.h"
#import "CategoryDiscussVO.h"
#import "QWWebView.h"

@interface QWBestLogic ()

@end

@implementation QWBestLogic

- (void)getSlideWithCompleteBlock:(QWCompletionBlock)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"type"] = @2;
    params[@"channel"] = @1;
    
    QWOperationParam *param = [QWInterface getRecommendWithParams:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
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
    params[@"channel"] = @1;

    QWOperationParam *param = [QWInterface getRecommendWithParams:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
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

//小编推荐
- (void)getSmallBestVOWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"type"] = @10;
    params[@"channel"] = @1;

    QWOperationParam *param = [QWInterface getRecommendWithParams:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            BestVO *vo = [BestVO voWithDict:aResponseObject];
            
            if (IS_IPHONE_DEVICE && vo.results.count > 8) {
                vo.results = (id)[vo.results subarrayWithRange:NSMakeRange(0, 8)];
            }
            
            self.smallBestVO = vo;
            
            if (aBlock) {
                aBlock(self.smallBestVO, nil);
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
//签约新秀
- (void)getNewlyWorkVOWithCompleteBlock:(QWCompletionBlock)aBlock {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"type"] = @8;
    params[@"channel"] = @1;

    QWOperationParam *param = [QWInterface getRecommendWithParams:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            BestVO *vo = [BestVO voWithDict:aResponseObject];
            
            if (IS_IPHONE_DEVICE && vo.results.count > 2) {
                vo.results = (id)[vo.results subarrayWithRange:NSMakeRange(0, 2)];
            }
            
            self.newlyWorkVO = vo;
            
            if (aBlock) {
                aBlock(self.newlyWorkVO, nil);
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
//热门作品
- (void)getHotWorkVOWithCompleteBlock:(QWCompletionBlock)aBlock {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"type"] = @7;
    params[@"channel"] = @1;

    QWOperationParam *param = [QWInterface getRecommendWithParams:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            BestVO *vo = [BestVO voWithDict:aResponseObject];
            
            if (IS_IPHONE_DEVICE && vo.results.count > 2) {
                vo.results = (id)[vo.results subarrayWithRange:NSMakeRange(0, 2)];
            }
            
            self.hotWorkVO = vo;
            
            if (aBlock) {
                aBlock(self.hotWorkVO, nil);
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
//限时优惠
- (void)getDicountWorkVOWithCompleteBlock:(QWCompletionBlock)aBlock {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"type"] = @9;
    params[@"channel"] = @1;
    params[@"limit"]= @4;
//    params[@"asdas"]= @11212;

    QWOperationParam *param = [QWInterface getRecommendWithParams:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            BestVO *vo = [BestVO voWithDict:aResponseObject];
            
            if (IS_IPHONE_DEVICE && vo.results.count > 4) {
                vo.results = (id)[vo.results subarrayWithRange:NSMakeRange(0, 4)];
            }
            self.dicountWorkVO = vo;
            
            if (aBlock) {
                aBlock(self.dicountWorkVO, nil);
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
//分区推荐
- (void)getZoneRecommendVOWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"type"] = @11;
    params[@"channel"] = @1;
    params[@"limit"] = @16;
    
    QWOperationParam *param = [QWInterface getRecommendWithParams:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            BestVO *vo = [BestVO voWithDict:aResponseObject];
            
            if (IS_IPHONE_DEVICE && vo.results.count > 16) {
                vo.results = (id)[vo.results subarrayWithRange:NSMakeRange(0, 16)];
            }
            self.zoneRecommendVO = vo;
            
            if (aBlock) {
                aBlock(self.zoneRecommendVO, nil);
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

//最近更新
- (void)getUpdateListVOWithCompleteBlock:(QWCompletionBlock)aBlock {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"channel"] = @0;
    params[@"order"] = @"update";
    params[@"works"] = @"all";
    NSString *url = [NSString stringWithFormat:@"%@/book/all_works/",[QWOperationParam currentDomain]];
    if (self.updateListVO.next) {
        url = self.updateListVO.next;
    }
    QWOperationParam *param = [QWInterface getWithUrl:url params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            ListVO *vo = [ListVO voWithDict:aResponseObject];
            if (self.updateListVO.results.count) {
                [self.updateListVO addResultsWithNewPage:vo];
            }
            else {
                self.updateListVO = vo;
            }
            
            if (aBlock) {
                aBlock(self.updateListVO, nil);
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

- (void)getOngoingActivityListWithCompleteBlock:(QWCompletionBlock)aBlock {
    
    NSMutableDictionary *params = @{}.mutableCopy;
    QWOperationParam *param = [QWInterface getWithDomainUrl:@"/activity/active/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            ActivityListVO *vo = [ActivityListVO voWithDict:aResponseObject];
            if (vo.results) {
                self.showActivityPageNumber = false;
                [vo.results enumerateObjectsUsingBlock:^(ActivityVO*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    ActivityVO *activity = obj;
                    NSString *activityKey = [NSString stringWithFormat:@"activity_%@",activity.nid];
                    NSDate *scanDate = [QWUserDefaults sharedInstance][activityKey];
                    if (!scanDate) {
                        self.showActivityPageNumber = true;
                    }
                    *stop = YES;
                }];
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
    return self.slideVO && self.bestVO;
}

- (void)getPromotionCookiesWithUrl:(NSString *)url andCompleteBlock:(QWCompletionBlock _Nullable)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;
    if ([QWGlobalValue sharedInstance].isLogin) {
        params[@"token"] = [QWGlobalValue sharedInstance].token;
    }

    params[@"url"] = url;

    QWOperationParam *param = [QWInterface getWithDomainUrl:@"gateway/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            NSDictionary *cookie = aResponseObject[@"cookie"];
            if ([cookie isKindOfClass:[NSDictionary class]]) {
                NSString *key = cookie[@"key"];
                NSString *domain = cookie[@"domain"];
                NSString *value = cookie[@"value"];
                __unused NSNumber *httponly = cookie[@"httponly"];
                NSNumber *secure = cookie[@"secure"];

                NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
                cookieProperties[NSHTTPCookieDomain] = domain;
                cookieProperties[NSHTTPCookieName] = key;
                cookieProperties[NSHTTPCookieValue] = value;
                cookieProperties[NSHTTPCookieSecure] = secure;
                cookieProperties[NSHTTPCookiePath] = @"/";
                cookieProperties[NSHTTPCookieVersion] = @"0";

                NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];

            }
            if (aBlock) {
                aBlock(aResponseObject, anError);
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
