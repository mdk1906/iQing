//
//  QWBaseLogic.m
//  Qingwen
//
//  Created by Aimy on 7/3/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBaseLogic.h"

#import "QWInterface.h"

@interface QWBaseLogic ()

@property (nonatomic, strong) QWOperationManager *operationManager;

@end

@implementation QWBaseLogic

+ (instancetype)logicWithOperationManager:(QWOperationManager *)aoperationManager;
{
    QWBaseLogic *logic = [[self alloc] init];
    logic.operationManager = aoperationManager;
    logic.loading = NO;
    return logic;
}

- (void)dealloc
{

}

- (void)getWithUrl:(NSString *)aUrl useOrigin:(BOOL)useOrigin andCompleteBlock:(QWCompletionBlock)aBlock
{
    QWOperationParam *param = [QWInterface getWithUrl:aUrl andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aBlock) {
            aBlock(aResponseObject, anError);
        }
    }];

    param.useOrigin = useOrigin;
    [self.operationManager requestWithParam:param];
}

- (void)handleResponseObjectV4:(id)aResponseObject dataBlock:(QWDataBlock)block{
    int code = [[aResponseObject objectForKey:@"code"] intValue];
    
    if (code == 0) { //成功
        NSMutableDictionary *data = [aResponseObject objectForKey:@"data"];
        if (!data) {
            data[@"data"] = @"成功.无数据返回";
        }
        if (block) {
            block(data);
        }
    }
    else if (code >= 200 && code < 300) {
        NSMutableDictionary *data = [aResponseObject objectForKey:@"data"];
        if (!data) {
            data[@"data"] = @"成功.无数据返回";
        }
        if (block) {
            block(data);
        }
    }
    else { //脏数据不返回
        NSString *msg = [aResponseObject objectForKey:@"msg"];
        [self showToastWithTitle:msg subtitle:nil type:ToastTypeError];
        if (block) {
            block(nil);
        }
    }
}
-(void)getAchievementInfoWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    QWOperationParam *param = [QWInterface getWithDomainUrl:@"task/show/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            NSDictionary *data = aResponseObject;
            NSArray *dataArr = data[@"data"];
            if (dataArr.count != 0) {
                for (int i = 0; i<dataArr.count; i++) {
                    NSDictionary *dict = dataArr[i];
                    QWAchievementBounced *alert = [[QWAchievementBounced alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_WIDTH, UISCREEN_HEIGHT) dict:dict];
                    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
                    [keyWindow addSubview:alert];
                }
            }
            
        }
        else {
            
        }
        
    }];
    
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
    
    
}
@end
