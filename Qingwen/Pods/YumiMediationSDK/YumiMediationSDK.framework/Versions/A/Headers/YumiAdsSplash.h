//
//  YumiAdsSplash.h
//  Pods
//
//  Created by 甲丁乙_ on 2017/7/5.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class YumiAdsSplash;
/// Delegate for receiving state change messages from a YumiAdsSplash.
@protocol YumiAdsSplashDelegate <NSObject>

/// Tells the delegate that the splash ad did load.
- (void)yumiAdsSplashDidLoad:(YumiAdsSplash *)splash;
/// Tells the delegate that the splash ad did fail to load.
- (void)yumiAdsSplash:(YumiAdsSplash *)splash DidFailToLoad:(NSError *)error;
/// Tells the delegate that the splash ad did clicked.
- (void)yumiAdsSplashDidClicked:(YumiAdsSplash *)splash;
/// Tells the delegate that the splash ad did closed.
- (void)yumiAdsSplashDidClosed:(YumiAdsSplash *)splash;
/// return your lunchImages
- (nullable UIImage *)yumiAdsSplashDefaultImage;

@end

/// The YumiAdsSplash class is used for requesting and presenting a splash ad.
@interface YumiAdsSplash : NSObject

// the durations of time out ,default is 3s
@property (nonatomic, assign) NSTimeInterval fetchDelay;

// return a splash singleton
+ (instancetype)sharedInstance;

/// show splash full screen
- (void)showYumiAdsSplashWith:(NSString *)placementID
                       appKey:(NSString *)appKey
           rootViewController:(UIViewController *)rootViewController
                     delegate:(id<YumiAdsSplashDelegate>)delegate;

// show splash with bottom custom view
// warning: bottomView's frame is nonnull
- (void)showYumiAdsSplashWith:(NSString *)placementID
                       appKey:(NSString *)appKey
             customBottomView:(UIView *)bottomView
           rootViewController:(UIViewController *)rootViewController
                     delegate:(id<YumiAdsSplashDelegate>)delegate;

@end
NS_ASSUME_NONNULL_END
