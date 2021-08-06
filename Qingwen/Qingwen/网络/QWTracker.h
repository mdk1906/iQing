//
//  QWTracker.h
//  Qingwen
//
//  Created by Aimy on 7/24/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking.h>

//苹果应用id
#define APP_ID @"1018140532"
//友盟统计id
#define UMENG_ID @"5595050067e58ee97b000ea8"
//百度统计id
#define BAIDU_ID @"2ef853f161"
//微博id
#define WeiboAppKey         @"1425751600"
#define WeiboRedirectURI    @"http://www.iqing.in"
//微信id
#define WeixinAppKey        @"wxf1e615ada37872ce"
#define WeixinAppSecret     @"20c7bd6616a0403605e9bbec7b39ddba"
#define WeixinMINIID        @"gh_ea899b7fff3a"
//腾讯id
#define QQAppKey            @"1104788776"

//广告id
//正式玉米key
#define QWYuMiAdKey         @"u5h2wohv"
#define QWSplashAdKey       @"d7tmlltg"
#define QWInterstitialAdKey @"46r2fgae"
#define QWBannerAdKey       @"lbn1v64v"
#define QWRewardedAdKey     @"ao7myhtv"


//正式穿山甲 key
#define QWCSJAdKey             @"5022306"
#define QWCSJRewardedAdKey     @"922306566"
#define QWCSJReadRewardedAdKey     @"922306396"
//广点通key
#define QWGDTAdKey             @"1108159385"
#define QWGDTSplashAdKey       @"9040653700237565"
#define QWGDTInterstitialAdKey @"4060056569573361"
#define QWGDTBannerAdKey       @"5050758782026861"
//#define QWGDTRewardedAdKey     @"Lo9SNuUcoC4yiKQxREE"
#define QWGDTNativedAdKey      @"8020953569275219"
#define QWGDTReadNativedAdKey  @"1090254732330504"


//换行
#define GDTAdChangeLine @"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
@interface QWTracker : NSObject

+ (QWTracker * __nonnull)sharedInstance;

@property (nonatomic, readonly, getter=isBeta) BOOL beta;//是否是beta
@property (nonatomic, strong, readonly, nullable) NSString *AppVersion;//接口版本号 v2
@property (nonatomic, strong, readonly, nullable) NSString *System;//iphone，ipad
@property (nonatomic, strong, readonly, nullable) NSString *Version;//系统版本号 8.4
@property (nonatomic, strong, readonly, nullable) NSString *GUID;//设备唯一标识符 lkasdjlf-ajsdfjlasd-ajdslfkj-jadlfj
@property (nonatomic, strong, readonly, nullable) NSString *Build;//app版本号 1.0.0
@property (nonatomic, strong, readonly, nullable) NSString *track;//app版本号+渠道 1.0.0-STORE
@property (nonatomic, strong, readonly, nullable) NSString *channel;//渠道STORE，OFFLINE
@property (nonatomic, strong, readonly, nullable) NSString *BuildVersion;//app编译版本号20150806131313

//2.5.1 新增
@property (nonatomic, strong, readonly, nullable) NSString *AppName;//app编译版本号20150806131313
@property (nonatomic, strong, readonly, nullable) NSString *Country;//用户所在地

- (void)configHeader:(AFHTTPRequestSerializer * __nonnull)requestSerializer;
- (void)configRequestHeader:(NSMutableURLRequest * __nonnull)request;
- (void)configCookies;

@end
