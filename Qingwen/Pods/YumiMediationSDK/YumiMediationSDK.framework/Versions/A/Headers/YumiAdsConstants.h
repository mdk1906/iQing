//
//  YumiAdsConstants.h
//  Pods
//
//  Created by 甲丁乙_ on 2017/6/23.
//
//
#import <Foundation/Foundation.h>

#ifndef YumiAdsConstants_h
#define YumiAdsConstants_h

#define DefaultCloseBtnWidth 30
#define DefaultCloseBtnHeight 30
#define DefaultCloseBtnSpace 4

typedef enum {
    YumiAdsFailureReasonParseFail = 0,
    YumiAdsFailureReasonLoadTimeout = 1,
    YumiAdsFailureReasonRequestTimeout = 2,
    YumiAdsFailureReasonNone = 3
} YumiAdsFailureReason;

typedef enum {
    YumiAdsTypeBanner = 2,
    YumiAdsTypeInterstitial = 3,
    YumiAdsTypeFullScreen = 4,
    YumiAdsTypeRewardVideo = 5,
    YumiAdsTypeSplash = 6,
    YumiAdsTypeWall = 7,
    YumiAdsTypeNative = 8
} YumiAdsRequestType;

typedef enum : NSUInteger {
    YumiAdsClickTypeDownload = 1,
    YumiAdsClickTypeOpenWebBrowser = 2,
    YumiAdsClickTypeOpenSystem = 3
} YumiAdsClickType;

typedef enum {
    YumiAdsPositionNativeAd = 0,
    YumiAdsPositionTop = 4,
    YumiAdsPositionBottom = 5,
    YumiAdsPositionSidebar = 6,
    YumiAdsPositionFullScreen = 7,
    YumiAdsPositionUnknow = 8
} YumiAdsPosition;

typedef enum {
    YumiAdsCloseBtnTopLeft = 1,
    YumiAdsCloseBtnTopRight = 2,
    YumiAdsCloseBtnRightBottom = 3,
    YumiAdsCloseBtnLeftBottom = 4
} YumiAdsCloseBtnPosition;

typedef enum {
    YumiAdsRewardVideo = 1,
    YumiAdsPlayabilityAd = 2,
    YumiAdsStyleOptimization = 8,
    YumiAdsMRAID = 9
} YumiAdsType;

typedef enum {
    // yumi
    YumiAdsLogoDefault = 1,
    // other
    YumiAdsLogoCommon = 2,
    YumiAdsLogoGDT = 3,
    YumiAdsLogoBaidu = 4,
} YumiAdsLogoType;

typedef enum {
    YumiAdsNativeBigImage = 1,
    YumiAdsNativeIcon = 2,
} YumiAdsNativeImageType;

typedef enum {
    YumiAdsNativeDescription = 1,
    YumiAdsNativeAppPrice = 2,
    YumiAdsNativeCallToAction = 3,
    YumiAdsNativeOther = 4
} YumiAdsNativeDataType;

#endif /* YumiAdsConstants_h */
