//
//  QWReachability.m
//  Qingwen
//
//  Created by Aimy on 7/9/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWReachability.h"

#import "QWOperationParam.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

/**
 *  网络状态更新
 */
NSString *const NotificationNetworkStatusChange = @"NotificationNetworkStatusChange";
/**
 *  有网络
 */
NSString *const NotificationNetworkStatusReachable = @"NotificationNetworkStatusReachable";

@interface QWReachability()

@property (nonatomic, strong) AFNetworkReachabilityManager *manager;
@property (nonatomic) QWNetWorkStatus lastNetStatus;
@property (nonatomic) BOOL lastReachability;

@end

@implementation QWReachability
DEF_SINGLETON(QWReachability)

- (instancetype)init
{
    if (self = [super init]) {

        self.lastNetStatus = QWConnectToAny;
        self.lastReachability = YES;

        WEAK_SELF;
        [self observeNotification:CTRadioAccessTechnologyDidChangeNotification withBlock:^(__weak id self, NSNotification *notification) {
            if (!notification) {
                return ;
            }

            KVO_STRONG_SELF;
            NSString *state = notification.object;
            [kvoSelf dealWithCT:state];
        }];

        [self observeNotification:AFNetworkingReachabilityDidChangeNotification withBlock:^(__weak id self, NSNotification *notification) {
            if (!notification) {
                return ;
            }

            KVO_STRONG_SELF;
            [kvoSelf generateNetStatus];
        }];

        _manager = [AFNetworkReachabilityManager sharedManager];
        [_manager startMonitoring];

        [self observeNotification:UIApplicationDidBecomeActiveNotification withBlock:^(__weak id self, NSNotification *notification) {
            if (!notification) {
                return ;
            }
            
            KVO_STRONG_SELF;
            [kvoSelf generateNetStatus];
        }];
    }
    return self;
}

- (void)dealloc
{
    [_manager stopMonitoring];
}

- (void)generateNetStatus
{
    //new telephonyInfo will post a notification CTRadioAccessTechnologyDidChangeNotification
    CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
    [self dealWithCT:telephonyInfo.currentRadioAccessTechnology];
}

- (void)dealWithCT:(NSString *)status
{
    NSLog(@"New Radio Access Technology: %@", status);
    //2g,2.5g
    if ([status isEqualToString:CTRadioAccessTechnologyGPRS] ||
        [status isEqualToString:CTRadioAccessTechnologyEdge]) {
        self.currentNetStatus = QWConnectTo2G;
        self.currentNetStatusForDisplay = @"2G";
    }
    //3g
    else if ([status isEqualToString:CTRadioAccessTechnologyWCDMA] ||
             [status isEqualToString:CTRadioAccessTechnologyHSDPA] ||
             [status isEqualToString:CTRadioAccessTechnologyHSUPA] ||
             [status isEqualToString:CTRadioAccessTechnologyCDMA1x] ||
             [status isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||
             [status isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] ||
             [status isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] ||
             [status isEqualToString:CTRadioAccessTechnologyeHRPD]) {
        self.currentNetStatus = QWConnectTo3G;
        self.currentNetStatusForDisplay = @"3G";
    }
    //4g
    else if ([status isEqualToString:CTRadioAccessTechnologyLTE]){
        self.currentNetStatus = QWConnectTo4G;
        self.currentNetStatusForDisplay = @"4G";
    }

    [self dealWithReachabilityStatus:self.manager.networkReachabilityStatus];
}

- (void)dealWithReachabilityStatus:(AFNetworkReachabilityStatus)status
{
    switch (status) {
        case AFNetworkReachabilityStatusReachableViaWWAN:
            break;
        case AFNetworkReachabilityStatusNotReachable:
            self.currentNetStatus = QWConnectToNull;
            self.currentNetStatusForDisplay = @"无网络";
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            self.currentNetStatus = QWConnectToWifi;
            self.currentNetStatusForDisplay = @"WiFi";
            break;
        default: {
            self.currentNetStatus = QWConnectToAny;
            self.currentNetStatusForDisplay = @"有网络";
            break;
        }
    }

    if ((self.lastNetStatus != self.currentNetStatus)) {
        NSLog(@"network type is %@ now", self.currentNetStatusForDisplay);

        self.lastNetStatus = self.currentNetStatus;
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNetworkStatusChange object:self];
    }

    if (self.lastReachability != self.isConnectedToNet && self.lastNetStatus != QWConnectToAny) {
        self.lastReachability = self.isConnectedToNet;
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNetworkStatusReachable object:self userInfo:@{@"reachability": @(self.isConnectedToNet)}];
    }
}

- (BOOL)isConnectedToNet
{
    return (self.currentNetStatus & QWConnectToAny);
}

@end
