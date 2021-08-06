//
//  YumiMediationProviderInfo.h
//  YumiMediationSDK-iOS
//
//  Created by ShunZhi Tang on 2017/7/18.
//  Copyright © 2017年 JiaDingYi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YumiMediationProviderInfo : NSObject

@property (nonatomic) NSString *providerName;
@property (nonatomic) NSArray *adTypes;
@property (nonatomic, assign) BOOL isConfig;
@property (nonatomic) NSString *providerID;

@end
