//
//  QWNetworkManager.h
//  Qingwen
//
//  Created by Aimy on 15/4/7.
//  Copyright (c) 2015年 Qingwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QWOperationManager;

@interface QWNetworkManager : NSObject

+ (QWNetworkManager * __nonnull)sharedInstance;

/**
 *  功能:产生一个operation manager,当owner销毁的时候一并销毁QWNetworkManager
 */
- (QWOperationManager * __nonnull)generateoperationManagerWithOwner:(id __nullable)owner;

/**
 *  功能:移除operation manager
 */
- (void)removeoperationManager:(QWOperationManager * __nonnull)aOperationManager;

@end
