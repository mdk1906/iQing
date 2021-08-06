//
//  YumiMediationConfigurationManager.h
//  Pods
//
//  Created by d on 5/5/2017.
//
//

#import "YumiMediationConfiguration.h"
#import "YumiMediationConstants.h"
#import <Foundation/Foundation.h>

static const NSTimeInterval kConfigurationCacheDuration = 300; // default time: cache configuration for five minutes

NS_ASSUME_NONNULL_BEGIN

@interface YumiMediationConfigurationManager : NSObject

- (instancetype)initWithPlacementID:(NSString *)placementID
                             adType:(YumiMediationAdType)adType
                          channelID:(NSString *)channelID
                          versionID:(NSString *)versionID;

- (void)forceUpdatedConfigurationSuccess:(void (^_Nonnull)(YumiMediationConfiguration *_Nonnull config,
                                                           BOOL isReadFromLocalStorage))success
                                 failure:(void (^_Nonnull)(NSError *_Nonnull error))failure;

@end

NS_ASSUME_NONNULL_END
