//
//  YumiMediationNativeProvider.h
//  Pods
//
//  Created by 王泽永 on 2017/9/14.
//
//

#import "YumiLogger.h"
#import "YumiMediationConfiguration.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YumiMediationNativeProviderState) {
    YumiMediationNativeProviderStateInit,
    YumiMediationNativeProviderStateRequesting,
    YumiMediationNativeProviderStateReceivedAd,
    YumiMediationNativeProviderStatePresented,
    YumiMediationNativeProviderStateClicked,
    YumiMediationNativeProviderStateTimeout,
    YumiMediationNativeProviderStateErrored,
};

NS_ASSUME_NONNULL_BEGIN

@interface YumiMediationNativeProvider : NSObject

@property (nonatomic, readonly) YumiMediationProvider *data;
@property (nonatomic, assign, readonly) YumiMediationNativeProviderState state;
@property (nonatomic, readonly) YumiLogger *logger;
@property (nonatomic, readonly) NSString *roundUUID;
@property (nonatomic, readonly) NSString *providerUUID;
@property (nonatomic, readonly) YumiMediationConfiguration *configuration;

- (instancetype)initWithProvider:(YumiMediationProvider *)provider
                          logger:(YumiLogger *)logger
                       roundUUID:(NSString *)roundUUID
                    providerUUID:(NSString *)providerUUID
                   configuration:(YumiMediationConfiguration *)configuration;

- (BOOL)trySetState:(YumiMediationNativeProviderState)targetState;

@end

NS_ASSUME_NONNULL_END
