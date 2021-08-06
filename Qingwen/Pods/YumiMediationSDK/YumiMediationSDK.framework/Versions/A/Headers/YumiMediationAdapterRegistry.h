//
//  YumiMediationAdapterRegistry.h
//  Pods
//
//  Created by d on 28/5/2017.
//
//

#import "YumiMediationAdapterIDConstants.h"
#import "YumiMediationBannerAdapter.h"
#import "YumiMediationConstants.h"
#import "YumiMediationInterstitialAdapter.h"
#import "YumiMediationNativeAdapter.h"
#import "YumiMediationVideoAdapter.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiMediationAdapterConfig : NSObject

@property (nonatomic) NSString *providerID;
@property (nonatomic, assign) YumiMediationAdRequestType requestType;

+ (instancetype)configWithProviderID:(NSString *)providerID requestType:(YumiMediationAdRequestType)requestType;
- (NSString *)key;

@end

@interface YumiMediationAdapterRegistry : NSObject

@property (nonatomic, readonly) NSMutableArray<YumiMediationAdapterConfig *> *bannerAdapterConfigs;
@property (nonatomic, readonly) NSMutableArray<YumiMediationAdapterConfig *> *videoAdapterConfigs;
@property (nonatomic, readonly) NSMutableArray<YumiMediationAdapterConfig *> *interstitialAdapterConfigs;
@property (nonatomic, readonly) NSMutableArray<YumiMediationAdapterConfig *> *nativeAdapterConfig;
@property (nonatomic, nullable) NSSet *providerWhiteList;

+ (instancetype)registry;

#pragma mark - Banner
- (void)registerBannerAdapter:(Class<YumiMediationBannerAdapter>)adapterClass
                forProviderID:(NSString *)providerID
                  requestType:(YumiMediationAdRequestType)requestType;
- (id<YumiMediationBannerAdapter>)bannerAdapterForProvider:(YumiMediationBannerProvider *)provider
                                                  delegate:(id<YumiMediationBannerAdapterDelegate>)delegate;
#pragma mark - Intersititial
- (void)registerInterstitialAdapter:(Class<YumiMediationInterstitialAdapter>)adapterClass
                      forProviderID:(NSString *)providerID
                        requestType:(YumiMediationAdRequestType)requestType;
- (id<YumiMediationInterstitialAdapter>)interstitialAdapterForProvider:(YumiMediationInterstitialProvider *)provider
                                                              delegate:(id<YumiMediationInterstitialAdapterDelegate>)
                                                                           delegate;

#pragma mark - Video
- (void)registerVideoAdapter:(Class<YumiMediationVideoAdapter>)adapterClass
                 forProvider:(NSString *)providerID
                 requestType:(YumiMediationAdRequestType)requestType;
- (id<YumiMediationVideoAdapter>)videoAdapterForProvider:(YumiMediationVideoProvider *)provider
                                                delegate:(id<YumiMediationVideoAdapterDelegate>)delegate;

#pragma mark - Native
- (void)registerNativeAdapter:(Class<YumiMediationNativeAdapter>)adapterClass
                forProviderID:(NSString *)providerID
                  requestType:(YumiMediationAdRequestType)requestType;
- (id<YumiMediationNativeAdapter>)nativeAdapterForProvider:(YumiMediationNativeProvider *)provider
                                                  delegate:(id<YumiMediationNativeAdapterDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
