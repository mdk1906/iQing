//
//  QWSearchLogic.m
//  Qingwen
//
//  Created by Aimy on 7/30/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWSearchLogic.h"

#import "QWInterface.h"

@implementation QWSearchLogic


-(BOOL)isShow {
    return self.searchBookVO || self.searchGameVO;
}

- (void)getCountsWithKeywords:(NSString *)keywords andCompleteBlock:(QWCompletionBlock)aBlock {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"q"] = keywords;
    params[@"type"] = @"book,game,activity,topic,user,favorite";
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/kensaku/",[QWOperationParam currentDomain]] params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (aResponseObject && !anError) {
            NSMutableArray *counts = [SearchCount arrayOfModelsFromDictionaries:aResponseObject error:nil];
            self.searchCounts = counts.copy;
            if (aBlock) {
                aBlock(self.searchCounts,anError);
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

- (void)getSuggestWithKeywords:(NSString *)keywords andCompleteBlock:(QWCompletionBlock)aBlock {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"q"] = keywords;
    
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/kensaku/suggest/",[QWOperationParam currentDomain]] params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (aResponseObject && !anError) {
            NSMutableArray *suggest = [SuggestVO arrayOfModelsFromDictionaries:aResponseObject error:nil];
            self.suggests = suggest.copy;
            if (aBlock) {
                aBlock(self.suggests,anError);
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



- (void)getCategoryWithCompleteBlock:(QWCompletionBlock)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;
    
    QWOperationParam *param = [QWInterface getCategoryWithParams:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }
            else {
                CategoryVO *vo = [CategoryVO voWithDict:aResponseObject];
                NSMutableArray *temp = vo.results.mutableCopy;
                NSMutableArray *titles = @[].mutableCopy;
                [temp.copy enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    CategoryItemVO *item = obj;
                    [titles addObject:item.name];
                }];
                vo.results = temp.copy;
                [titles insertObject:@"全部" atIndex:0];
                self.categoryStrings = titles;
                self.categoryVO = vo;
                
                if (aBlock) {
                    aBlock(aResponseObject, nil);
                }
            }
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];
    param.printLog = false;
    [self.operationManager requestWithParam:param];
}

//搜书
- (void)searchBookWithKeywords:(NSString *_Nullable)keywords andCompleteBlock:(QWCompletionBlock _Nullable)aBlock {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"q"] = keywords ? keywords : @"";
    params[@"type"] = @"book";
    params[@"fields"] = @"id,author,cover,url,count,belief,combat,title,author_name,is_vip";
    if (self.order) {
        params[@"order"] = self.order;
    }
    if (self.locate) { //分区
        params[@"channel"] = self.locate;
    }
    if (self.category_id) {
        params[@"categories"] = self.category_id;
    }
    if (self.categories) {
        CategoryItemVO *item = self.categoryVO.results[self.categories.integerValue];
        
        params[@"categories"] = item.nid;
    }
    if (self.rank) { //等级
        params[@"rank"] = self.rank;
    }
    if (self.end) {
        params[@"end"] = self.end;
    }
    
    NSString *currentUrl = [NSString stringWithFormat:@"%@/kensaku/", [QWOperationParam currentDomain]];
    if (self.searchBookVO.next) {
        currentUrl = self.searchBookVO.next;
    }
    
    WEAK_SELF;
    QWOperationParam *param = [QWInterface getWithUrl:currentUrl params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        if (aResponseObject && !anError) {
            ListVO *vo = [ListVO voWithDict:aResponseObject];

            
            if (self.searchBookVO.results.count) {
                [self.searchBookVO addResultsWithNewPage:vo];
            }
            else {
                self.searchBookVO = vo;
            }
            
            if (aBlock) {
                aBlock(self.searchBookVO, nil);
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
//搜演绘
- (void)searchGameWithKeywords:(NSString *_Nullable)keywords andCompleteBlock:(QWCompletionBlock _Nullable)aBlock {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"q"] = keywords ? keywords : @"";
    params[@"type"] = @"game";
    params[@"fields"] = @"id,author,cover,url,scene_count,belief,combat,title,author_name,is_vip";
    if (self.order.integerValue > 0) {
        params[@"order"] = self.order;
    }
    NSString *currentUrl = [NSString stringWithFormat:@"%@/kensaku/", [QWOperationParam currentDomain]];
    if (self.searchGameVO.next) {
        currentUrl = self.searchGameVO.next;
    }
    
    WEAK_SELF;
    QWOperationParam *param = [QWInterface getWithUrl:currentUrl params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        if (aResponseObject && !anError) {
            ListVO *vo = [ListVO voWithDict:aResponseObject];
            
            
            if (self.searchGameVO.results.count) {
                [self.searchGameVO addResultsWithNewPage:vo];
            }
            else {
                self.searchGameVO = vo;
            }
            
            if (aBlock) {
                aBlock(self.searchGameVO, nil);
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
//搜活动/专题 topic=true 专题
- (void)searchActivityWithKeywords:(NSString *_Nullable)keywords topic:(BOOL)topic andCompleteBlock:(QWCompletionBlock _Nullable)aBlock {
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"q"] = keywords;
    if (topic) {
        params[@"type"] = @"topic";
    }
    else {
        params[@"type"] = @"activity";
    }
    params[@"fields"] = @"id,title,cover,order,started_time,ended_time,bf_url,eve_url,url,work_count,bf_count,bf_enable,works_display,submit_enable,status";
    if (self.order.integerValue > 0) {
        params[@"order"] = self.order;
    }
    NSString *currentUrl = [NSString stringWithFormat:@"%@/kensaku/", [QWOperationParam currentDomain]];
    if (self.searchActivityListVO.next) {
        currentUrl = self.searchActivityListVO.next;
    }
    
    WEAK_SELF;
    QWOperationParam *param = [QWInterface getWithUrl:currentUrl params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        if (aResponseObject && !anError) {
            ActivityListVO *vo = [ActivityListVO voWithDict:aResponseObject];
            
            if (self.searchActivityListVO.results.count) {
                [self.searchActivityListVO addResultsWithNewPage:vo];
            }
            else {
                self.searchActivityListVO = vo;
            }
            
            if (aBlock) {
                aBlock(self.searchActivityListVO, nil);
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

//搜用户
- (void)searchUserWithKeywords:(NSString * _Nullable)keywords andCompleteBlock:(QWCompletionBlock _Nullable)aBlock {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"q"] = keywords;
    params[@"type"] = @"user";

    params[@"fields"] = @"id,fans_count,follow_count,avatar,username,signature,sex,profile_url";
    if (self.order.integerValue > 0) {
        params[@"order"] = self.order;
    }
    NSString *currentUrl = [NSString stringWithFormat:@"%@/kensaku/", [QWOperationParam currentDomain]];
    if (self.searchUserListVO.next) {
        currentUrl = self.searchUserListVO.next;
    }
    
    WEAK_SELF;
    QWOperationParam *param = [QWInterface getWithUrl:currentUrl params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        if (aResponseObject && !anError) {
            UserPageVO *vo = [UserPageVO voWithDict:aResponseObject];
            
            
            if (self.searchUserListVO.results.count) {
                [self.searchUserListVO addResultsWithNewPage:vo];
            }
            else {
                self.searchUserListVO = vo;
            }
            
            if (aBlock) {
                aBlock(self.searchUserListVO, nil);
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


//搜书单
- (void)searchFavoriteWithKeywords:(NSString * _Nullable)keywords andCompleteBlock:(QWCompletionBlock _Nullable)aBlock {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"q"] = keywords;
    params[@"type"] = @"favorite";
    
    params[@"fields"] = @"id,title,intro,cover,user,work_count,belief,combat,views";
    if (self.order.integerValue > 0) {
        params[@"order"] = self.order;
    }
    NSString *currentUrl = [NSString stringWithFormat:@"%@/kensaku/", [QWOperationParam currentDomain]];
    if (self.searchFavorite.next) {
        currentUrl = self.searchFavorite.next;
    }
    
    WEAK_SELF;
    QWOperationParam *param = [QWInterface getWithUrl:currentUrl params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        if (aResponseObject && !anError) {
            FavoriteBooksListVO *vo = [FavoriteBooksListVO voWithDict:aResponseObject];
            
            
            if (self.searchFavorite.results.count) {
                [self.searchFavorite addResultsWithNewPage:vo];
            }
            else {
                self.searchFavorite = vo;
            }
            
            if (aBlock) {
                aBlock(self.searchFavorite, nil);
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
