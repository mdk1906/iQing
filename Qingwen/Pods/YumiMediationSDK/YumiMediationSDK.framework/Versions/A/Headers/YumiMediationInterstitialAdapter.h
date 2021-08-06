//
//  YumiMediationInterstitialAdapter.h
//  Pods
//
//  Created by 魏晓磊 on 17/6/20.
//
//

#import "YumiMediationInterstitialProvider.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YumiMediationInterstitialAdapterDelegate;

@protocol YumiMediationInterstitialAdapter <NSObject>

@property (nonatomic, readonly) YumiMediationInterstitialProvider *provider;

+ (instancetype)alloc;
- (id<YumiMediationInterstitialAdapter>)initWithProvider:(YumiMediationInterstitialProvider *)provider
                                                delegate:(id<YumiMediationInterstitialAdapterDelegate>)delegate;

- (void)requestAd;
- (BOOL)isReady;
- (void)present;

@end

@protocol YumiMediationInterstitialAdapterDelegate <NSObject>
// return rootViewController
- (UIViewController *)rootViewControllerForPresentingModalView;
// didReceiveInterstitialAd
- (void)adapter:(id<YumiMediationInterstitialAdapter>)adapter
    didReceiveInterstitialAd:(_Nullable id)ad
                  instanceId:(NSString *)instanceId;
- (void)adapter:(id<YumiMediationInterstitialAdapter>)adapter didReceiveInterstitialAd:(_Nullable id)ad;
- (void)adapter:(id<YumiMediationInterstitialAdapter>)adapter
    didReceiveInterstitialAd:(_Nullable id)ad
           interstitialFrame:(CGRect)interstitialFrame;
- (void)adapter:(id<YumiMediationInterstitialAdapter>)adapter
    didReceiveInterstitialAd:(_Nullable id)ad
           interstitialFrame:(CGRect)interstitialFrame
              withTemplateID:(int)templateID;
// didFailToReceive
- (void)adapter:(id<YumiMediationInterstitialAdapter>)adapter
      interstitialAd:(_Nullable id)ad
    didFailToReceive:(NSString *)error
          instanceId:(NSString *)instanceId;
- (void)adapter:(id<YumiMediationInterstitialAdapter>)adapter
      interstitialAd:(_Nullable id)ad
    didFailToReceive:(NSString *)error;
// willPresentScreen
- (void)adapter:(id<YumiMediationInterstitialAdapter>)adapter willPresentScreen:(_Nullable id)ad;
// willDismissScreen
- (void)adapter:(id<YumiMediationInterstitialAdapter>)adapter willDismissScreen:(_Nullable id)ad;
- (void)adapter:(id<YumiMediationInterstitialAdapter>)adapter
    willDismissScreen:(_Nullable id)ad
           instanceId:(NSString *)instanceId;
// didClickInterstitialAd
- (void)adapter:(id<YumiMediationInterstitialAdapter>)adapter
    didClickInterstitialAd:(_Nullable id)ad
                instanceId:(NSString *)instanceId;
- (void)adapter:(id<YumiMediationInterstitialAdapter>)adapter didClickInterstitialAd:(_Nullable id)ad;
- (void)adapter:(id<YumiMediationInterstitialAdapter>)adapter didClickInterstitialAd:(_Nullable id)ad on:(CGPoint)point;
- (void)adapter:(id<YumiMediationInterstitialAdapter>)adapter
    didClickInterstitialAd:(_Nullable id)ad
                        on:(CGPoint)point
            withTemplateID:(int)templateID;

@end

NS_ASSUME_NONNULL_END
