//
//  YumiMediationInterstitialProvider.h
//  Pods
//
//  Created by 魏晓磊 on 17/6/20.
//
//

#import "YumiLogger.h"
#import "YumiMediationConfiguration.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YumiMediationInterstitialProviderState) {
    YumiMediationInterstitialProviderStateInit,
    YumiMediationInterstitialProviderStateRequesting,
    YumiMediationInterstitialProviderStateReceivedAd,
    YumiMediationInterstitialProviderStatePresented,
    YumiMediationInterstitialProviderStateDismissed,
    YumiMediationInterstitialProviderStateClicked,
    YumiMediationInterstitialProviderStateTimeout,
    YumiMediationInterstitialProviderStateErrored,
};

@interface YumiMediationInterstitialProvider : NSObject

@property (nonatomic, readonly) YumiMediationProvider *data;
@property (nonatomic, assign, readonly) YumiMediationInterstitialProviderState state;
@property (nonatomic, readonly) YumiLogger *logger;
@property (nonatomic, readonly) NSString *roundUUID;
@property (nonatomic, readonly) NSString *providerUUID;
@property (nonatomic, readonly) YumiMediationConfiguration *configuration;

- (instancetype)initWithProvider:(YumiMediationProvider *)provider
                          logger:(YumiLogger *)logger
                       roundUUID:(NSString *)roundUUID
                    providerUUID:(NSString *)providerUUID
                   configuration:(YumiMediationConfiguration *)configuration;

- (BOOL)trySetState:(YumiMediationInterstitialProviderState)targetState;

@end
