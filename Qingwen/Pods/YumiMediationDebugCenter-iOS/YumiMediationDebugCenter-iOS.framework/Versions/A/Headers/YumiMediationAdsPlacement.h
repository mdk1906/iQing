//
//  YumiMediationAdsPlacement.h
//  YumiMediationDebugCenter-iOS
//
//  Created by Michael Tang on 2017/12/8.
//

#import <Foundation/Foundation.h>

@interface YumiMediationAdsPlacement : NSObject <NSCoding>

@property (nonatomic) NSString *bannerPlacementID;
@property (nonatomic) NSString *interstitialPlacementID;
@property (nonatomic) NSString *videoPlacementID;
@property (nonatomic) NSString *nativePlacementID;
@property (nonatomic) NSString *channelID;
@property (nonatomic) NSString *versionID;

@end
