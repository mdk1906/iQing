//
//  YumiMediationBannerAdapter.h
//  Pods
//
//  Created by d on 28/5/2017.
//
//

#import "YumiMediationBannerProvider.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YumiMediationBannerAdapterDelegate;

@protocol YumiMediationBannerAdapter <NSObject>

@property (nonatomic, readonly) YumiMediationBannerProvider *provider;

+ (instancetype)alloc;
- (id<YumiMediationBannerAdapter>)initWithProvider:(YumiMediationBannerProvider *)provider
                                          delegate:(id<YumiMediationBannerAdapterDelegate>)delegate;

- (void)requestAdWithIsPortrait:(BOOL)isPortrait isiPad:(BOOL)isiPad;
- (void)setBannerSizeWith:(YumiMediationAdViewBannerSize)adSize smartBanner:(BOOL)isSmart;

@end

@protocol YumiMediationBannerAdapterDelegate <NSObject>

- (UIViewController *)rootViewControllerForPresentingModalView;

- (void)adapter:(id<YumiMediationBannerAdapter>)adapter didReceiveAd:(UIView *)bannerView;
- (void)adapter:(id<YumiMediationBannerAdapter>)adapter
      didReceiveAd:(UIView *)bannerView
    withTemplateID:(int)templateID;
- (void)adapter:(id<YumiMediationBannerAdapter>)adapter didFailToReceiveAd:(NSString *)error;
- (void)adapter:(id<YumiMediationBannerAdapter>)adapter didClick:(UIView *)bannerView;
- (void)adapter:(id<YumiMediationBannerAdapter>)adapter didClick:(UIView *)bannerView on:(CGPoint)point;
- (void)adapter:(id<YumiMediationBannerAdapter>)adapter
          didClick:(UIView *)bannerView
                on:(CGPoint)point
    withTemplateID:(int)templateID;

/// Pop up full screen ad page after clicking on the ad
- (void)adapter:(id<YumiMediationBannerAdapter>)adapter didPresentInternalBrowser:(UIView *)bannerView;
- (void)adapter:(id<YumiMediationBannerAdapter>)adapter didDissmissInternalBrowser:(UIView *)bannerView;

@end

NS_ASSUME_NONNULL_END
