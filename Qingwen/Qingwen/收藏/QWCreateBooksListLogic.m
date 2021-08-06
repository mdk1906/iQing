//
//  QWCreateBooksListLogic.m
//  Qingwen
//
//  Created by wei lu on 16/12/17.
//  Copyright © 2017 iQing. All rights reserved.
//

#import "QWCreateBooksListLogic.h"
#import "QWInterface.h"

//@implementation QWCreateBooksListLogic
//-(void)postNewBooksListWithCompleteBlock:(id)title :(NSString *)bookTitle intro:(NSString *)intro WithCompleteBlock:(QWCompletionBlock)aBlock
//{
//    NSMutableDictionary *params = @{}.mutableCopy;
//    params[@"title"] = title;
//    params[@"intro"] = intro;
//    
//    NSString *currentUrl = [NSString stringWithFormat:@"%@/favorite/", [QWOperationParam currentFAVBooksDomain]];
//    QWOperationParam *param = [QWInterface getWithUrl:currentUrl params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
//        if (aResponseObject && !anError) {
//            aBlock(aResponseObject,anError);
//        }
//        else {
//            if (aBlock) {
//                aBlock(nil, anError);
//            }
//        }
//    }];
//    param.useV4 = true;
//    param.requestType = QWRequestTypePost;
//    [self.operationManager requestWithParam:param];
//    
//    
//}
//
//@end

