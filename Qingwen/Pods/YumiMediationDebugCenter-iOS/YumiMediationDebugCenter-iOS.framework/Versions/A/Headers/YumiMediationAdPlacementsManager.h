//
//  YumiMediationAdPlacementsManager.h
//  YumiMediationDebugCenter-iOS
//
//  Created by Michael Tang on 2017/12/11.
//

#import "YumiMediationAdsPlacement.h"
#import <Foundation/Foundation.h>

@interface YumiMediationAdPlacementsManager : NSObject

+ (instancetype)sharedAdPlacementsManager;

- (void)persistAdPlacements:(YumiMediationAdsPlacement *)adsPlacement;

- (YumiMediationAdsPlacement *)fetchAdPlacements;

@end
