//
//  YumiMediationUtils.h
//  Pods
//
//  Created by d on 29/5/2017.
//
//

#import "YumiMediationConfiguration.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiMediationUtils : NSObject

+ (NSArray<YumiMediationProvider *> *)sortedProviders:(NSArray<YumiMediationProvider *> *)providers;
+ (NSString *)providerNameFromID:(NSString *)providerID;
+ (NSString *)realProviderID:(NSString *)providerID;
+ (NSString *)descriptionOfRequestType:(YumiMediationAdRequestType)requestType;
+ (NSString *)uuid;

+ (NSString *)descriptionOfAdType:(YumiMediationAdType)adType;

@end

NS_ASSUME_NONNULL_END
