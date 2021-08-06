//
//  YumiMediationConfiguration.h
//  Pods
//
//  Created by d on 4/5/2017.
//
//

#import "YumiMediationConstants.h"
#import <UIKit/UIKit.h>

@interface YumiMediationNativeTemplate : NSObject <NSCoding>

@property (nonatomic, nonnull) NSString *screenMode;
@property (nonatomic, assign) int templateID;
@property (nonatomic, assign) int generatedAt;
@property (nonatomic, nonnull) NSString *html;

@end

@interface YumiMediationCloseButton : NSObject <NSCoding>

@property (nonatomic, assign) YumiMediationCloseButtonPostion position;
@property (nonatomic, assign) CGFloat pictureWidth;
@property (nonatomic, assign) CGFloat pictureHeight;
@property (nonatomic, assign) CGFloat clickAreaWidth;
@property (nonatomic, assign) CGFloat clickAreaHeight;

@end

@interface YumiMediationProvider : NSObject <NSCoding>

@property (nonatomic, nonnull) NSString *providerID;
@property (nonatomic, nonnull) NSString *key1;
@property (nonatomic, nullable) NSString *key2;
@property (nonatomic, nullable) NSString *key3;
@property (nonatomic, nullable) NSString *key4;

@property (nonatomic, assign) BOOL isPrioritized;
@property (nonatomic, assign) int weight;

@property (nonatomic, assign) NSTimeInterval requestTimeout;
@property (nonatomic, assign) NSTimeInterval materialEffectiveDuration;

@property (nonatomic, assign) YumiMediationAdRequestType requestType;
@property (nonatomic, assign) YumiMediationBrowserType browserType;

@property (nonatomic, nullable) YumiMediationNativeTemplate *generalTemplate;
@property (nonatomic, nullable) YumiMediationNativeTemplate *landscapeTemplate;
@property (nonatomic, nullable) YumiMediationNativeTemplate *verticalTemplate;
@property (nonatomic, nullable) YumiMediationCloseButton *closeButton;

@property (nonatomic, assign) NSTimeInterval nextRequestInterval;

// 3.4.0  new parameters for header bidding
@property (nonatomic, assign) BOOL isHeaderBidding;
@property (nonatomic, nullable) NSString *ecpm;
@property (nonatomic, nullable) NSString *currency;
@property (nonatomic, nullable) NSString *payload;
@property (nonatomic, nullable) NSArray<NSString *> *winNotificationTrackers;
@property (nonatomic, nullable) NSArray<NSString *> *billableNotificationTrackers;
@property (nonatomic, nullable) NSArray<NSString *> *lossNotificationTrackers;
@property (nonatomic, assign) BOOL sameAsTheLast;
@property (nonatomic, assign) int errCode;
@property (nonatomic, nullable) NSString *errMessage;

@end

@interface YumiMediationConfiguration : NSObject <NSCoding>

@property (nonatomic, nonnull) NSString *trans;
@property (nonatomic, nonnull) NSString *logUrl;

@property (nonatomic, assign) int adProviderMaxRetryTimes;
@property (nonatomic, assign) int rewardedVideoMaxRewardTimesPerDay;

@property (nonatomic, assign) NSTimeInterval spaceTime;
@property (nonatomic, assign) NSTimeInterval rotatedDuration;

@property (nonatomic, nonnull) NSArray<YumiMediationProvider *> *providers;

// 3.2.0  new parameters
@property (nonatomic, nonnull) NSString *partnerID;
@property (nonatomic, nonnull) NSString *developerID;
@property (nonatomic, nonnull) NSString *appID;
@property (nonatomic, nonnull) NSString *placementID;
@property (nonatomic, assign) YumiMediationConfigType configType;
@property (nonatomic, nonnull) NSString *configID;

// 3.4.0 new parameters
@property (nonatomic, nonnull) NSString *requestID;

@end
