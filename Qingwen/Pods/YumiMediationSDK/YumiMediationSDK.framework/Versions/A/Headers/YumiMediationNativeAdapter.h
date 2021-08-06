//
//  YumiMediationNativeAdapter.h
//  Pods
//
//  Created by 王泽永 on 2017/9/14.
//
//

#import "YumiMediationNativeModel.h"
#import "YumiMediationNativeProvider.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class YumiMediationNativeModel;
@protocol YumiMediationNativeAdapterDelegate;

@protocol YumiMediationNativeAdapter <NSObject>

@property (nonatomic, readonly) YumiMediationNativeProvider *provider;

+ (instancetype)alloc;
- (id<YumiMediationNativeAdapter>)initWithProvider:(YumiMediationNativeProvider *)provider
                                          delegate:(id<YumiMediationNativeAdapterDelegate>)delegate;

- (void)requestAd:(NSUInteger)adCount;
- (void)registerViewForNativeAdapterWith:(UIView *)view
                          viewController:(nullable UIViewController *)viewController
                                nativeAd:(YumiMediationNativeModel *)nativeAd;

/// report impression when display the native ad.
- (void)reportImpressionForNativeAdapter:(YumiMediationNativeModel *)nativeAd view:(UIView *)view;
- (void)clickAd:(YumiMediationNativeModel *)nativeAd;
@end

@protocol YumiMediationNativeAdapterDelegate <NSObject>
- (void)adapter:(id<YumiMediationNativeAdapter>)adapter
    didReceiveAd:(NSArray<YumiMediationNativeModel *> *)nativeAdArray;
- (void)adapter:(id<YumiMediationNativeAdapter>)adapter didFailToReceiveAd:(NSString *)error;
- (void)adapter:(id<YumiMediationNativeAdapter>)adapter didClick:(nullable id)nativeAd;
- (void)adapter:(id<YumiMediationNativeAdapter>)adapter didClick:(nullable id)nativeAd on:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
