//
//  YumiMediationBannerView.h
//  Pods
//
//  Created by d on 29/5/2017.
//
//

#import "YumiMediationError.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/// The vertical position relative to the banner's superview.
typedef NS_ENUM(NSUInteger, YumiMediationBannerPosition) {
    YumiMediationBannerPositionTop,
    YumiMediationBannerPositionBottom,
};

@class YumiMediationBannerView;

NS_ASSUME_NONNULL_BEGIN

/// Delegate methods for receiving YumiMediationBannerView state change messages.
@protocol YumiMediationBannerViewDelegate <NSObject>

@optional

/// Tells the delegate that an ad has been successfully loaded.
- (void)yumiMediationBannerViewDidLoad:(YumiMediationBannerView *)adView;

/// Tells the delegate that a request failed.
- (void)yumiMediationBannerView:(YumiMediationBannerView *)adView didFailWithError:(YumiMediationError *)error;

/// Tells the delegate that the banner view has been clicked.
- (void)yumiMediationBannerViewDidClick:(YumiMediationBannerView *)adView;

@end

/// The view that displays banner ads.
@interface YumiMediationBannerView : UIView

/// Required to set this banner view to a proper size. Use one of the predefined standard ad sizes (such as
/// kYumiMediationAdViewBanner320x50) If you want to specify the ad size you need to set it before calling loadAd:
/// default: iPhone and iPod Touch ad size. Typically 320x50.
/// default: iPad ad size. Typically 728x90.
@property (nonatomic, assign) YumiMediationAdViewBannerSize bannerSize;

/// Optional delegate object that receives state change notifications.
@property (nonatomic, weak, nullable) id<YumiMediationBannerViewDelegate> delegate;

+ (instancetype) new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (void)setFrame:(CGRect)frame NS_UNAVAILABLE;

/// Initializes and returns a banner view with the position relative to the banner's superview.
- (instancetype)initWithPlacementID:(NSString *)placementID
                          channelID:(NSString *)channelID
                          versionID:(NSString *)versionID
                           position:(YumiMediationBannerPosition)position
                 rootViewController:(UIViewController *)rootViewController;

/// Disable auto refresh for the YumiMediationBannerView instance.
- (void)disableAutoRefresh;

/// Begins loading the YumiMediationBannerView content.
/// If isSmart is set to YES, it will render screen-width banner ads on any screen size across different devices in
/// either orientation.
- (void)loadAd:(BOOL)isSmartBanner;

/// Fetch banner ad size
- (CGSize)fetchBannerAdSize;

@end

NS_ASSUME_NONNULL_END
