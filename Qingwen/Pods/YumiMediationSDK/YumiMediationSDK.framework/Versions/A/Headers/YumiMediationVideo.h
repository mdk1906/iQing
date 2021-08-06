//
//  YumiMediationVideo.h
//  Pods
//
//  Created by d on 20/6/2017.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YumiMediationVideo;

/// Delegate for receiving state change messages from a YumiMediationVideo.
@protocol YumiMediationVideoDelegate <NSObject>

@optional

/// Tells the delegate that the video ad opened.
- (void)yumiMediationVideoDidOpen:(YumiMediationVideo *)video;

/// Tells the delegate that the video ad started playing.
- (void)yumiMediationVideoDidStartPlaying:(YumiMediationVideo *)video;

/// Tells the delegate that the video ad closed.
- (void)yumiMediationVideoDidClose:(YumiMediationVideo *)video;

/// Tells the delegate that the video ad has rewarded the user.
- (void)yumiMediationVideoDidReward:(YumiMediationVideo *)video;

@end

/// The YumiMediationVideo class is used for requesting and presenting a video ad.
@interface YumiMediationVideo : NSObject

/// Delegate for receiving video notifications.
@property (nonatomic, weak, nullable) id<YumiMediationVideoDelegate> delegate;

/// Returns the shared YumiMediationVideo instance.
+ (instancetype)sharedInstance;

/// Initiates the ad request, should only be called once as early as possible.
- (void)loadAdWithPlacementID:(NSString *)placementID channelID:(NSString *)channelID versionID:(NSString *)versionID;

/// Indicates if the receiver is ready to be presented full screen.
- (BOOL)isReady;

/// Presents the video ad with the provided view controller.
- (void)presentFromRootViewController:(UIViewController *)rootViewController;

@end

NS_ASSUME_NONNULL_END
