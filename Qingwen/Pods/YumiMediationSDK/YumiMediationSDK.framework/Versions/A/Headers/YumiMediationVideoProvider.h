//
//  YumiMediationVideoProvider.h
//  Pods
//
//  Created by d on 20/6/2017.
//
//

#import "YumiLogger.h"
#import "YumiMediationConfiguration.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiMediationVideoProvider : NSObject

@property (nonatomic, readonly) YumiMediationProvider *data;
@property (nonatomic, readonly) YumiLogger *logger;
@property (nonatomic, readonly) NSString *providerUUID;
@property (nonatomic, readonly) YumiMediationConfiguration *configuration;

- (instancetype)initWithProvider:(YumiMediationProvider *)provider
                          logger:(YumiLogger *)logger
                    providerUUID:(NSString *)providerUUID
                   configuration:(YumiMediationConfiguration *)configuration;

@end

NS_ASSUME_NONNULL_END
