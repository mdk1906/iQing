//
//  YumiMediationDebugController.h
//  YumiMediationSDK-iOS
//
//  Created by ShunZhi Tang on 2017/7/17.
//  Copyright © 2017年 JiaDingYi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <YumiMediationSDK/YumiMediationConfiguration.h>

@interface YumiMediationDebugController : UIViewController

+ (instancetype)sharedInstance;

- (void)presentWithBannerPlacementID:(NSString *)bannerPlacementID
             interstitialPlacementID:(NSString *)interstitialPlacementID
                    videoPlacementID:(NSString *)videoPlacementID
                   nativePlacementID:(NSString *)nativePlacementID
                           channelID:(NSString *)channelID
                           versionID:(NSString *)versionID
                  rootViewController:(UIViewController *)rootViewController;
/// Consistent with your banner size
/// default:iPhone and iPod Touch ad size. Typically 320x50.
/// default: iPad ad size . Typically 728x90.
- (void)setupBannerSize:(YumiMediationAdViewBannerSize)bannerSize;

@end
