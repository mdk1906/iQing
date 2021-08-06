//
//  YumiMediationNativeAd.h
//  Pods
//
//  Created by 王泽永 on 2017/9/14.
//
//

#import "YumiMediationError.h"
#import "YumiMediationNativeModel.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class YumiMediationNativeAd;

NS_ASSUME_NONNULL_BEGIN

/// Delegate methods for receiving YumiMediationNativeAd state change messages.
@protocol YumiMediationNativeAdDelegate <NSObject>

@optional

/// Tells the delegate that an ad has been successfully loaded.
- (void)yumiMediationNativeAdDidLoad:(NSArray<YumiMediationNativeModel *> *)nativeAdArray;

/// Tells the delegate that a request failed.
- (void)yumiMediationNativeAd:(YumiMediationNativeAd *)nativeAd didFailWithError:(YumiMediationError *)error;

/// Tells the delegate that the Native view has been clicked.
- (void)yumiMediationNativeAdDidClick:(YumiMediationNativeModel *)nativeAd;

@end

/// The NSObject that explains Native ads.
@interface YumiMediationNativeAd : NSObject

/// Optional delegate object that receives state change notifications.
@property (nonatomic, weak, nullable) id<YumiMediationNativeAdDelegate> delegate;

+ (instancetype) new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/// Initializes and returns a Native object.
- (instancetype)initWithPlacementID:(NSString *)placementID
                          channelID:(NSString *)channelID
                          versionID:(NSString *)versionID;

/**
 This is a method to associate a YumiNativeAd with the UIView you will use to display the native ads.
 - Parameter view: The UIView you created to render all the native ads data elements.
 - Parameter viewController: The UIViewController that will be used to present SKStoreProductViewController
 (iTunes Store product information) or the in-app browser. If nil is passed, the top view controller currently shown
 will be used.
 The whole area of the UIView will be clickable.
 */
- (void)registerViewForInteraction:(UIView *)view
                withViewController:(nullable UIViewController *)viewController
                          nativeAd:(YumiMediationNativeModel *)nativeAd;

/**
 report impression when display the native ad.
 - Parameter nativeAd: the ad you want to display.
 - Parameter view: view you display the ad.
*/
- (void)reportImpression:(YumiMediationNativeModel *)nativeAd view:(UIView *)view;

/// Begins loading the YumiMediationNativeAd with the count you wanted.
- (void)loadAd:(NSUInteger)adCount;

@end

NS_ASSUME_NONNULL_END
