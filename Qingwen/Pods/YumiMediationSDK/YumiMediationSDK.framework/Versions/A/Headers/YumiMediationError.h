//
//  YumiMediationError.h
//  Pods
//
//  Created by d on 2/6/2017.
//
//

#import "YumiMediationConstants.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiMediationError : NSError

- (instancetype)initWithAdType:(YumiMediationAdType)adType
                   placementID:(NSString *)placementID
                     channelID:(NSString *)channelID
                     versionID:(NSString *)versionID
                     roundUUID:(NSString *)roundUUID;

- (void)appendError:(NSString *)error;

- (void)appendError:(NSString *)error
         providerID:(NSString *)providerID
        requestType:(YumiMediationAdRequestType)requestType;

@end

NS_ASSUME_NONNULL_END
