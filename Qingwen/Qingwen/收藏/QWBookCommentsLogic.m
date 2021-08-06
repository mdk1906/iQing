//
//  QWBookCommentsLogic.m
//  Qingwen
//
//  Created by wei lu on 5/01/18.
//  Copyright © 2018 iQing. All rights reserved.
//
#import "QWBookCommentsLogic.h"
@implementation QWBookCommentsLogic
- (void)getCommentsWithCompleteBlock:(NSNumber *)workId workType:(NSNumber *)type andCompleteBlock:(QWCompletionBlock)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"work_type"] = type;
    params[@"work_id"] = workId;
   
    NSString *currentUrl = [NSString stringWithFormat:@"%@/favorite/item/recommend/",[QWOperationParam currentFAVBooksDomain]];
    if (self.commentsVO.next.length) {
        currentUrl = self.commentsVO.next;
    }
    
    QWOperationParam *param = [QWInterface getWithUrl:currentUrl params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            [self handleResponseObjectV4:aResponseObject dataBlock:^(id aResponseObject) {
                BookCommentsListVO *vo = [BookCommentsListVO voWithDict:aResponseObject];
                if (self.commentsVO.results.count > 0) {
                    [self.commentsVO addResultsWithNewPage:vo];
                }
                else {
                    self.commentsVO = vo;
                }
                
                if (aBlock) {
                    aBlock(self.commentsVO, nil);
                }
            }];
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];
    param.useV4 = YES;
    [self.operationManager requestWithParam:param];
}

- (void)getRelativeFavoriteWithCompleteBlock:(NSNumber *)workId workType:(NSNumber *)type andCompleteBlock:(QWCompletionBlock)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"work_type"] = type;
    params[@"work_id"] = workId;
    
    NSString *currentUrl = [NSString stringWithFormat:@"%@/favorite/like/",[QWOperationParam currentFAVBooksDomain]];
    if (self.relatetiveFavoritesVO.next.length) {
        currentUrl = self.relatetiveFavoritesVO.next;
    }
    
    QWOperationParam *param = [QWInterface getWithUrl:currentUrl params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            [self handleResponseObjectV4:aResponseObject dataBlock:^(id aResponseObject) {
                FavoriteBooksListVO *vo = [FavoriteBooksListVO voWithDict:aResponseObject];
                if (self.relatetiveFavoritesVO.results.count > 0) {
                    [self.relatetiveFavoritesVO addResultsWithNewPage:vo];
                }
                else {
                    self.relatetiveFavoritesVO = vo;
                }
                
                if (aBlock) {
                    aBlock(self.relatetiveFavoritesVO, nil);
                }
            }];
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];
    param.useV4 = YES;
    [self.operationManager requestWithParam:param];
}
@end
