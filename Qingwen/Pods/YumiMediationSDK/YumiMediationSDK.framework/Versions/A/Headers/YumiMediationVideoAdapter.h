//
//  YumiMediationVideoAdapter.h
//  Pods
//
//  Created by d on 20/6/2017.
//
//

#import "YumiMediationVideoProvider.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YumiMediationVideoAdapter;

@protocol YumiMediationVideoAdapterDelegate <NSObject>
// didReceiveVideoAd
- (void)adapter:(id<YumiMediationVideoAdapter>)adapter didReceiveVideoAd:(_Nullable id)ad;
- (void)adapter:(id<YumiMediationVideoAdapter>)adapter
    didReceiveVideoAd:(_Nullable id)ad
           instanceId:(NSString *)instanceId;

// didFailToLoad
- (void)adapter:(id<YumiMediationVideoAdapter>)adapter videoAd:(_Nullable id)ad didFailToLoad:(NSString *)error;
- (void)adapter:(id<YumiMediationVideoAdapter>)adapter
          videoAd:(_Nullable id)ad
    didFailToLoad:(NSString *)error
          isRetry:(BOOL)isRetry;

// didOpenVideoAd
- (void)adapter:(id<YumiMediationVideoAdapter>)adapter didOpenVideoAd:(_Nullable id)ad;

// didStartPlayingVideoAd
- (void)adapter:(id<YumiMediationVideoAdapter>)adapter didStartPlayingVideoAd:(_Nullable id)ad;

// didCloseVideoAd
- (void)adapter:(id<YumiMediationVideoAdapter>)adapter didCloseVideoAd:(_Nullable id)ad;
- (void)adapter:(id<YumiMediationVideoAdapter>)adapter
    didCloseVideoAd:(_Nullable id)ad
         instanceId:(NSString *)instanceId;

// didReward
- (void)adapter:(id<YumiMediationVideoAdapter>)adapter videoAd:(_Nullable id)ad didReward:(_Nullable id)reward;
- (void)adapter:(id<YumiMediationVideoAdapter>)adapter
        videoAd:(_Nullable id)ad
      didReward:(_Nullable id)reward
     instanceId:(NSString *)instanceId;
@end

@protocol YumiMediationVideoAdapter <NSObject>

@property (nonatomic, readonly) YumiMediationVideoProvider *provider;

+ (instancetype)alloc;
- (id<YumiMediationVideoAdapter>)initWithProvider:(YumiMediationVideoProvider *)provider
                                         delegate:(id<YumiMediationVideoAdapterDelegate>)delegate;

- (void)requestAd;
- (BOOL)isReady;
- (void)presentFromRootViewController:(UIViewController *)rootViewController;

@end

NS_ASSUME_NONNULL_END
