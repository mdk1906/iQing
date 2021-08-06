//
//  YumiMediationNativeModel.h
//  Pods
//
//  Created by 王泽永 on 2017/9/20.
//
//

#import "YumiMediationNativeAdapter.h"
#import <Foundation/Foundation.h>

@protocol YumiMediationNativeAdapter;

@interface YumiMediationNativeModel : NSObject

/// title
@property (nonatomic, copy, readonly, nullable) NSString *title;
/// description
@property (nonatomic, copy, readonly, nullable) NSString *desc;
/// icon url
@property (nonatomic, copy, readonly, nullable) NSString *iconURL;
/// cover image url
@property (nonatomic, copy, readonly, nullable) NSString *coverImageURL;
/// app price, for example "free"
@property (nonatomic, copy, readonly, nullable) NSString *appPrice;
///
@property (nonatomic, copy, readonly, nullable) NSString *appRating;
/// call to action phrase of the ad, for example "download".
@property (nonatomic, copy, readonly, nullable) NSString *callToAction;

/// thirdparty data
@property (nonatomic, strong, readonly, nullable) id data;
/// other data
@property (nonatomic, strong, readonly, nullable) NSString *other;
/// adapter
@property (nonatomic, strong, readonly, nonnull) id<YumiMediationNativeAdapter> thirdparty;
@end
