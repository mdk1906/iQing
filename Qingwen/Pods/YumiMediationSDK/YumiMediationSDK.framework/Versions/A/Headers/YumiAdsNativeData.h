//
//  YumiAdsNativeData.h
//  Pods
//
//  Created by ShunZhi Tang on 2017/9/19.
//
//

#import <Foundation/Foundation.h>

@interface YumiAdsNativeData : NSObject

@property (nonatomic, assign, readonly) NSUInteger nativeAdID;
///  Typed access to the ad title.
@property (nonatomic, copy, readonly, nullable) NSArray *titles;
///  Typed access to the ad description.
@property (nonatomic, copy, readonly, nullable) NSString *desc;
///  Typed access to the ad image.
@property (nonatomic, copy, readonly, nullable) NSArray *imgUrls;
/// Typed access to the ad icon.
@property (nonatomic, copy, readonly, nullable) NSString *iconUrl;
/// Typed access to the call to action phrase of the ad, for example "download".
@property (nonatomic, copy, readonly, nullable) NSString *callToAction;
///  Typed access to the ad other.
@property (nonatomic, copy, readonly, nullable) NSString *other;
///  Typed access to the app price, for example "free"
@property (nonatomic, copy, readonly, nullable) NSString *appPrice;

@end
