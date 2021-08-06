//
//  YumiMediationFetchAdConfig.h
//  Pods
//
//  Created by ShunZhi Tang on 2017/7/26.
//
//

#import "YumiMediationDemoConstants.h"
#import <Foundation/Foundation.h>
#import <YumiMediationSDK/YumiMediationConfiguration.h>

@interface YumiMediationFetchAdConfig : NSObject

+ (instancetype)sharedFetchAdConfig;

// get YumiMediationConfiguration from local or remote
- (void)getAdConfigWith:(YumiMediationAdType)adType
            placementID:(NSString *)placementID
              channelID:(NSString *)channelID
              versionID:(NSString *)versionID
                success:(void (^)(YumiMediationConfiguration *_Nonnull))success
                failure:(void (^)(NSError *_Nonnull))failure;
@end
