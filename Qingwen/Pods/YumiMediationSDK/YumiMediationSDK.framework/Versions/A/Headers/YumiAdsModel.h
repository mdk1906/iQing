//
//  YumiRequestModel.h
//  Pods
//
//  Created by 甲丁乙_ on 2017/6/5.
//
//

#import "YumiAdsNativeData.h"
#import <Foundation/Foundation.h>

@interface YumiAdsNativeLinkObject : NSObject

@property (nonatomic) NSString *linkUrl;
@property (nonatomic) NSArray *clickTrackers;
@property (nonatomic) NSString *fallback;
@property (nonatomic, assign) int linkType;

@end

@interface YumiAdsNativeObject : NSObject

@property (nonatomic) YumiAdsNativeData *nativeData;
@property (nonatomic) YumiAdsNativeLinkObject *link;
@property (nonatomic) NSArray *imptrackers;
@property (nonatomic) NSString *bundle;

@end

@interface YumiAdsConfigDataObject : NSObject
@property (nonatomic, assign) int bInterval;
@property (nonatomic, assign) int cInterval;
@property (nonatomic, assign) BOOL isClose;
@property (nonatomic, assign) int kInterval;
@property (nonatomic, assign) int vInterval;

@end

@interface YumiAdsTrackersObject : NSObject
@property (nonatomic) NSArray *showChanceTrackerUrl;
@property (nonatomic) NSArray *displayStartTrackerUrl;
@property (nonatomic) NSArray *displayFinishTrackerUrl;
@property (nonatomic) NSArray *reDisplayTrackerUrl;
@property (nonatomic) NSArray *displayTrackerUrl;
@property (nonatomic) NSArray *clickTrackerUrl;
@property (nonatomic) NSArray *targetCloseTrackerUrl;
@property (nonatomic) NSArray *sdkErrorTrackerUrl;
@end

@interface YumiAdsBidObject : NSObject
@property (nonatomic) NSString *adid;
@property (nonatomic, assign) CGFloat adWidth;
@property (nonatomic, assign) CGFloat adHeight;
@property (nonatomic, assign) int adType;
@property (nonatomic) NSString *html;
@property (nonatomic) NSString *changeUrl;
@property (nonatomic, assign) int closeButton_w;
@property (nonatomic, assign) int closeButton_h;
@property (nonatomic, assign) int closeImage_w;
@property (nonatomic, assign) int closeImage_h;
@property (nonatomic, assign) int closeButtonPosition;
@property (nonatomic) NSString *url;
@property (nonatomic) NSString *resUrl;
@property (nonatomic, assign) int clickType;
@property (nonatomic) NSString *evUrl;
@property (nonatomic) YumiAdsTrackersObject *trackersObject;
@property (nonatomic) NSString *requestID;
@property (nonatomic) YumiAdsConfigDataObject *config;
@property (nonatomic, assign) int preload;
@property (nonatomic, assign) int supportPreDoload;
@property (nonatomic, assign) int evOrientation;
@property (nonatomic, assign) int storageNumber;
@property (nonatomic) NSString *evDispTime;
@property (nonatomic) NSString *deeplinkUrl;
// native
@property (nonatomic) YumiAdsNativeObject *native;

@end

@interface YumiAdsModel : NSObject
@property (nonatomic) NSString *code;
@property (nonatomic) NSString *message;
@property (nonatomic) NSArray<NSDictionary *> *bids;
@property (nonatomic) NSDictionary *requestBackParam;

@end
