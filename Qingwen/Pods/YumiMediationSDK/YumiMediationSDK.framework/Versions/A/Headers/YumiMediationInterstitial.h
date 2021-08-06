//
//  YumiMediationInterstitial.h
//  Pods
//
//  Created by 魏晓磊 on 17/6/20.
//
//

#import "YumiMediationError.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YumiMediationInterstitial;

/// Delegate for receiving state change messages from a YumiMediationInterstitial.
@protocol YumiMediationInterstitialDelegate <NSObject>

@optional

/// Tells the delegate that the interstitial ad request succeeded.
- (void)yumiMediationInterstitialDidReceiveAd:(YumiMediationInterstitial *)interstitial;

/// Tells the delegate that the interstitial ad request failed.
- (void)yumiMediationInterstitial:(YumiMediationInterstitial *)interstitial
                 didFailWithError:(YumiMediationError *)error;

/// Tells the delegate that the interstitial is to be animated off the screen.
- (void)yumiMediationInterstitialWillDismissScreen:(YumiMediationInterstitial *)interstitial;

/// Tells the delegate that the interstitial ad has been clicked.
- (void)yumiMediationInterstitialDidClick:(YumiMediationInterstitial *)interstitial;

@end

/// An interstitial ad. This is a full-screen advertisement shown at natural transition points in
/// your application such as between game levels or news stories.
@interface YumiMediationInterstitial : NSObject

/// Optional delegate object that receives state change notifications.
@property (nonatomic, weak, nullable) id<YumiMediationInterstitialDelegate> delegate;

+ (instancetype) new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/// Initializes an interstitial ad.
- (instancetype)initWithPlacementID:(NSString *)placementID
                          channelID:(NSString *)channelID
                          versionID:(NSString *)versionID
                 rootViewController:(UIViewController *)rootViewController;

/// Returns YES if the interstitial is ready to be displayed.
- (BOOL)isReady;

/// Presents the interstitial ad from the view controller passed in in initialization method.
- (void)present;

@end

NS_ASSUME_NONNULL_END
