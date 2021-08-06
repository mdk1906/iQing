//
//  QWNetworkManager.m
//  Qingwen
//
//  Created by Aimy on 15/4/7.
//  Copyright (c) 2015年 Qingwen. All rights reserved.
//

#import "QWNetworkManager.h"
#import "QWOperationManager.h"

@interface QWNetworkManager ()

@property(nonatomic, strong) NSMutableArray *operationManagers;

@end

@implementation QWNetworkManager

DEF_SINGLETON(QWNetworkManager);

- (NSMutableArray *)operationManagers
{
    if (_operationManagers == nil) {
        _operationManagers = [NSMutableArray array];
    }
    
    return _operationManagers;
}

/**
 *  功能:产生一个operation manager
 */
- (QWOperationManager *)generateoperationManagerWithOwner:(id)owner
{
    QWOperationManager *operationManager = [QWOperationManager managerWithOwner:owner];
    [self.operationManagers safeAddObject:operationManager];

    return operationManager;
}

/**
 *  功能:移除operation manager
 */
- (void)removeoperationManager:(QWOperationManager *)aOperationManager
{
    [self.operationManagers removeObject:aOperationManager];
}

/**
 *  功能:取消所有operation
 */
- (void)cancelAllOperations
{
    NSArray *copyArray = self.operationManagers.copy;
    for (QWOperationManager *operationManager in copyArray) {
        [operationManager.tasks makeObjectsPerformSelector:@selector(cancel)];
        [self.operationManagers removeObject:operationManager];
    }
}

@end
