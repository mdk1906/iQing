//
//  QWReachability.h
//  Qingwen
//
//  Created by Aimy on 7/9/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  网络状态更新
 */
UIKIT_EXTERN NSString *const __nonnull NotificationNetworkStatusChange;

/**
 *  有网络
 */
UIKIT_EXTERN NSString *const __nonnull NotificationNetworkStatusReachable;

typedef NS_ENUM(NSInteger, QWNetWorkStatus) {
    QWConnectToNull = 0,
    QWConnectTo2G   = 1 << 0,
    QWConnectTo3G   = 1 << 1,
    QWConnectTo4G   = 1 << 2,
    QWConnectToWWAN = 1 << 3,
    QWConnectToWifi = 1 << 4,
    /**
     *  联网了
     */
    QWConnectToAny  = (QWConnectTo2G | QWConnectTo3G | QWConnectTo4G | QWConnectToWWAN | QWConnectToWifi)
};

@interface QWReachability : NSObject

+ (QWReachability * __nonnull)sharedInstance;

@property (nonatomic, assign) QWNetWorkStatus currentNetStatus;
@property (nonatomic, copy, nullable) NSString *currentNetStatusForDisplay;
/**
 *  是否联网了
 */
@property (nonatomic, getter=isConnectedToNet, readonly) BOOL connectedToNet;

/**
 *  功能:获取网络连接状况
 */
- (void)generateNetStatus;

@end