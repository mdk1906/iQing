//
//  YumiMediationConstants.h
//  Pods
//
//  Created by d on 4/5/2017.
//
//

#import <Foundation/Foundation.h>

#ifndef YumiMediationConstants_h
#define YumiMediationConstants_h

#define YumiCommonBannerProviderDetail @"YumiCommonBanner_providerDetail"
#define YumiCommonInterstitialProviderDetail @"YumiCommonInterstitial_providerDetail"
#define YumiCommonVideoProviderDetail @"YumiCommonVideo_providerDetail"
#define YumiCommonNativeProviderDetail @"YumiCommonNative_providerDetail"

#define YumiCommonBannerChannel @"YumiCommonBanner_Channel"
#define YumiCommonInterstitialChannel @"YumiCommonInterstitial_Channel"
#define YumiCommonVideoChannel @"YumiCommonVideo_Channel"
#define YumiCommonNativeChannel @"YumiCommonNative_Channel"
#define YumiAdsVideoRequestUniqueIdentifier @"YumiAdsVideoRequest_UniqueIdentifier"

#define YumiMediationHeaderBiddingToken @"YumiMediation_HeaderBidding_Token"

#define SYSTEM_VERSION_LESS_THAN(v)                                                                                    \
    ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define YumiMediationFetchConfigurationErrorDomain @"com.YumiMediationFetchConfigurationError.Domain"

typedef enum : NSUInteger {
    YumiMediationAdTypeRecommendedWall = 1, // 推荐墙
    YumiMediationAdTypeBanner = 2,          // 横幅
    YumiMediationAdTypeInterstitial = 3,    // 插屏
    YumiMediationAdTypeFullScreen = 4,      // 全屏
    YumiMediationAdTypeVideo = 5,           // 视频
    YumiMediationAdTypeSplash = 6,          // 开屏
    YumiMediationAdTypeOfferWall = 7,       // 积分墙
    YumiMediationAdTypeNative = 8           // 信息流

} YumiMediationAdType;

typedef enum : NSUInteger {
    YumiErrorNoFill = 5,
    YumiErrorRequestTimeout = 8,
    YumiErrorLoadTimeout,
    YumiErrorSetStateFail,
    YumiErrorResponseFail,
    YumiErrorOther
} YumiErrorCode;

#define YumiError(YumiAdErrorCode, localizedFailureReasonError, localizedRecoverySuggestionError)                      \
    [NSError errorWithDomain:@"com.yumi.ads"                                                                           \
                        code:YumiAdErrorCode                                                                           \
                    userInfo:[NSDictionary dictionaryWithObjectsAndKeys:localizedFailureReasonError,                   \
                                                                        NSLocalizedFailureReasonErrorKey,              \
                                                                        localizedRecoverySuggestionError,              \
                                                                        NSLocalizedRecoverySuggestionErrorKey, nil]]

#endif /* YumiMediationConstants_h */

typedef NS_ENUM(NSUInteger, YumiMediationCloseButtonPostion) {
    YumiMediationCloseButtonTopLeft = 1,
    YumiMediationCloseButtonTopRight = 2,
    YumiMediationCloseButtonBottomRight = 3,
    YumiMediationCloseButtonBottomLeft = 4,
};

typedef NS_ENUM(NSUInteger, YumiMediationBrowserType) {
    YumiMediationSystemBrowser = 0,
    YumiMediationWebview = 1,
};

typedef NS_ENUM(NSUInteger, YumiMediationAdRequestType) {
    YumiMediationSDKAdRequest = 1,
    YumiMediationAPIAdRequest = 2,
};

typedef NS_ENUM(NSInteger, YumiMediationAdResponseResultCode) {
    YumiMediationAdResponseNoNetwork = -1,
    YumiMediationAdResponseFail = 0,
    YumiMediationAdResponseSuccess = 1,
    YumiMediationAdResponseInternalError = 3,
    YumiMediationAdResponseNetworkError = 4,
    YumiMediationAdResponseNoFill = 5,
    YumiMediationAdResponseInvalidRequest = 6,
    YumiMediationAdResponseTimeout = 8,
    YumiMediationAdResponseRequestError = 9,
};

typedef NS_ENUM(NSUInteger, YumiMediationStatisticsEventResult) {
    YumiMediationStatisticsEventResultFailed = 0,
    YumiMediationStatisticsEventResultSuccessful = 1,
    YumiMediationStatisticsEventResultInternalInconsistencyError = 3,
    YumiMediationStatisticsEventResultNetworkError = 4,
    YumiMediationStatisticsEventResultNoFill = 5,
    YumiMediationStatisticsEventResultBadRequest = 6,
    YumiMediationStatisticsEventResultNoInternetConnection = 7,
    YumiMediationStatisticsEventResultRequestTimeout = 8,
    YumiMediationStatisticsEventResultRateLimitRequestError = 9,
};

typedef NS_ENUM(NSUInteger, YumiMediationConfigType) {
    YumiMediationConfigUnkown,
    YumiMediationConfigAdSlot,
    YumiMediationConfigClassification,
    YumiMediationConfigTest,
};

/// Represents the fixed banner ad size
typedef NS_ENUM(NSUInteger, YumiMediationAdViewBannerSize) {
    /// iPhone and iPod Touch ad size. Typically 320x50.
    kYumiMediationAdViewBanner320x50 = 1 << 0,
    // Leaderboard size for the iPad. Typically 728x90.
    kYumiMediationAdViewBanner728x90 = 1 << 1,
    // Represents the fixed banner ad size - 300pt by 250pt.
    kYumiMediationAdViewBanner300x250 = 1 << 2
};
