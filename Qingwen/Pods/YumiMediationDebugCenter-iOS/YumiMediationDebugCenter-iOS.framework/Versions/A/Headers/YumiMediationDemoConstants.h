//
//  YumiMediationDemoConstants.h
//  Pods
//
//  Created by ShunZhi Tang on 2017/7/26.
//
//

#ifndef YumiMediationDemoConstants_h
#define YumiMediationDemoConstants_h

typedef NS_ENUM(NSUInteger, YumiMediationAdLogType) {
    YumiMediationAdLogTypeBanner,
    YumiMediationAdLogTypeInterstitial,
    YumiMediationAdLogTypeVideo,
    YumiMediationAdLogTypeSplash,
    YumiMediationAdLogTypeNative,
};

static NSString *const placementIdInfoKeys = @"YumiMediation_allPlacementID_channelID_versionID";
#define YumiMediationBannerViewSizeKey @"YumiMediationBannerViewSize_banner_key"

#endif /* YumiMediationDemoConstants_h */
