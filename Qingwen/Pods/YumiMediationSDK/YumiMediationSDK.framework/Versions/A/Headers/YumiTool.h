//
//  YumiTool.h
//  Pods
//
//  Created by d on 2/5/2017.
//
//

#import "YumiMediationConfiguration.h"
#import "YumiMediationConstants.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define kSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define kIPHONEXHEIGHT 812.0
#define kIPHONEXHOMEINDICATOR 34.0
#define kIPHONEXSTATUSBAR 44.0
#define kIPHONEXWIDTH 375.0
NS_ASSUME_NONNULL_BEGIN

@interface YumiTool : NSObject

@property (nonatomic, assign, readonly) int screenScale;
@property (nonatomic, assign, readonly) int dpi;
@property (nonatomic, readonly) NSString *userAgent;
@property (nonatomic, readonly) NSString *macAddress;
@property (nonatomic, readonly) NSString *model;
@property (nonatomic, readonly) NSString *idfa;
@property (nonatomic, readonly) NSString *idfv;
@property (nonatomic, readonly) NSString *plmn;
@property (nonatomic, readonly) NSString *systemVersion;
@property (nonatomic, readonly) NSString *appVersion;
@property (nonatomic, readonly) NSString *openUDID;
@property (nonatomic, readonly) NSString *preferredLanguage;
@property (nonatomic, readonly) NSString *networkStatus;
@property (nonatomic, readonly) NSString *bundleID;
@property (nonatomic, readonly) NSString *appName;
@property (nonatomic, readonly) NSString *carrierName;
@property (nonatomic, readonly) NSString *mcc;
@property (nonatomic, readonly) NSString *mnc;
@property (nonatomic, readonly) NSString *ip;
@property (nonatomic, readonly) NSString *deviceName;
@property (nonatomic, assign, readonly) BOOL allowArbitraryLoads;
@property (nonatomic, readonly) NSString *uuid;

+ (instancetype _Nonnull)sharedTool;

- (BOOL)isiPhone;
- (BOOL)isiPad;
- (BOOL)isiPod;
- (BOOL)isSimulator;
- (BOOL)isAdTrackingEnabled;
- (BOOL)isInterfaceOrientationPortrait;
- (NSBundle *_Nullable)resourcesBundleWithBundleName:(NSString *)bundleName;
- (void)setUpdateIPInterval:(NSTimeInterval)interval;
- (NSString *)sign:(NSDictionary *)parameters;
- (NSString *)fetchItunesIdWith:(NSString *)tempString;
- (void)openBySystemMethod:(NSURL *)openUrl;
- (BOOL)isiPhoneX;
- (CGSize)fetchBannerAdSizeWith:(YumiMediationAdViewBannerSize)bannerSizeType smartBanner:(BOOL)isSmart;
- (UIViewController *)topMostController;
- (NSString *)fetchBiddingTokenWith:(NSString *)providerID adType:(YumiMediationAdType)adType;
- (void)fetchTheFinalMediationConfigurationWithPlacementID:(NSString *)placementID
                                                    adType:(YumiMediationAdType)adType
                                                 channelID:(NSString *)channelID
                                                 versionID:(NSString *)versionID
                                                   success:
                                                       (void (^)(YumiMediationConfiguration *_Nullable config))success
                                                   failure:(void (^)(NSError *error))failure;
- (NSString *)getBiddingPayloadKeyWithAdType:(YumiMediationAdType)adType;
@end

NS_ASSUME_NONNULL_END
