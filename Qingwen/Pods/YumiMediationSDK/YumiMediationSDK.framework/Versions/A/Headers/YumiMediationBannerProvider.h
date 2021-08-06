//
//  YumiMediationBannerProvider.h
//  Pods
//
//  Created by d on 29/5/2017.
//
//

#import "YumiLogger.h"
#import "YumiMediationConfiguration.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YumiMediationBannerProviderState) {
    YumiMediationBannerProviderStateInit,
    YumiMediationBannerProviderStateRequesting,
    YumiMediationBannerProviderStateReceivedAd,
    YumiMediationBannerProviderStatePresented,
    YumiMediationBannerProviderStateClicked,
    YumiMediationBannerProviderStateTimeout,
    YumiMediationBannerProviderStateErrored,
};

NS_ASSUME_NONNULL_BEGIN

@interface YumiMediationBannerProvider : NSObject

@property (nonatomic, readonly) YumiMediationProvider *data;
@property (nonatomic, assign, readonly) YumiMediationBannerProviderState state;
@property (nonatomic, readonly) YumiLogger *logger;
@property (nonatomic, readonly) NSString *roundUUID;
@property (nonatomic, readonly) NSString *providerUUID;
@property (nonatomic, readonly) YumiMediationConfiguration *configuration;

- (instancetype)initWithProvider:(YumiMediationProvider *)provider
                          logger:(YumiLogger *)logger
                       roundUUID:(NSString *)roundUUID
                    providerUUID:(NSString *)providerUUID
                   configuration:(YumiMediationConfiguration *)configuration;

- (BOOL)trySetState:(YumiMediationBannerProviderState)targetState;

@end

NS_ASSUME_NONNULL_END
