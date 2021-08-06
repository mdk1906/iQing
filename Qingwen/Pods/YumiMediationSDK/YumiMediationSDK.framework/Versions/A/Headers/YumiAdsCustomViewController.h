//
//  YumiAdsCustomViewController.h
//  Pods
//
//  Created by 甲丁乙_ on 2017/6/27.
//
//

#import "YumiAdsCustomView.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol YumiAdsCustomViewControllerDelegate <NSObject>

- (void)yumiAdsCustomViewControllerDidReceivedAd:(UIViewController *)viewController;
- (void)yumiAdsCustomViewController:(UIViewController *)viewController didFailToReceiveAdWithError:(NSError *)error;
- (void)didClickOnYumiAdsCustomViewController:(UIViewController *)viewController point:(CGPoint)point;
- (void)yumiAdsCustomViewControllerDidPresent:(UIViewController *)viewController;
- (void)yumiAdsCustomViewControllerDidClosed:(UIViewController *)viewController;
@optional
- (void)yumiAdsCustomViewControllerDidReceivedAdWithWebView:(UIWebView *)webView;
- (void)didClickOnYumiAdsCustomViewControllerWithpoint:(CGPoint)point;

@end

@interface YumiAdsCustomViewController : UIViewController

@property (nonatomic, readonly) YumiAdsCustomView *customView;
@property (nonatomic, assign, readonly) BOOL isReady;
@property (nonatomic) NSString *clickURL;
@property (nonatomic, assign) BOOL isNativeInterstitialGDT;

// for StyleOptimization ads
@property (nonatomic, assign) BOOL isStyleOptimization;
@property (nonatomic, assign) BOOL isStyleOptimizationVideo;
@property (nonatomic, assign) BOOL isStyleOptimizationVideoLoaded;
@property (nonatomic, assign) CGRect videoFrame;

+ (instancetype) new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (void)setFrame:(CGRect)frame NS_UNAVAILABLE;

- (YumiAdsCustomViewController *)initYumiAdsCustomViewControllerWith:(CGRect)frame
                                                           clickType:(YumiAdsClickType)clickType
                                                    closeBtnPosition:(NSUInteger)closeBtnPosition
                                                       closeBtnFrame:(NSDictionary *)closeBtnFrame
                                                            logoType:(YumiAdsLogoType)logoType
                                                            delegate:(id<YumiAdsCustomViewControllerDelegate>)delegate;

- (void)loadHTMLString:(NSString *)htmlStr;
- (void)loadBaseUrl:(NSURL *)url;
- (void)presentFromRootViewController:(UIViewController *)viewController;
- (void)closeButtonPressed;

@end
NS_ASSUME_NONNULL_END
