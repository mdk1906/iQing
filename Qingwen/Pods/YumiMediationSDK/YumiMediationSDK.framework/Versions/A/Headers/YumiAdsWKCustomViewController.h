//
//  YumiAdsWKCustomViewController.h
//  Pods
//
//  Created by Michael Tang on 2018/5/23.
//
//

#import "YumiAdsWKCustomView.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol YumiAdsWKCustomViewControllerDelegate <NSObject>

- (void)yumiAdsWKCustomViewControllerDidReceivedAd:(UIViewController *)viewController;
- (void)yumiAdsWKCustomViewController:(UIViewController *)viewController didFailToReceiveAdWithError:(NSError *)error;
- (void)didClickOnYumiAdsWKCustomViewController:(UIViewController *)viewController point:(CGPoint)point;
- (void)yumiAdsWKCustomViewControllerDidPresent:(UIViewController *)viewController;
- (void)yumiAdsWKCustomViewControllerDidClosed:(UIViewController *)viewController;
@optional
- (void)yumiAdsWKCustomViewControllerDidReceivedAdWithWebView:(WKWebView *)webView;
- (void)didClickOnYumiAdsWKCustomViewControllerWithpoint:(CGPoint)point;

@end

@interface YumiAdsWKCustomViewController : UIViewController

@property (nonatomic, readonly) YumiAdsWKCustomView *customView;
@property (nonatomic, assign, readonly) BOOL isReady;
@property (nonatomic) NSString *clickURL;
@property (nonatomic) NSString *deeplinkUrl;
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

- (YumiAdsWKCustomViewController *)initYumiAdsWKCustomViewControllerWith:(CGRect)frame
                                                               clickType:(YumiAdsClickType)clickType
                                                        closeBtnPosition:(NSUInteger)closeBtnPosition
                                                           closeBtnFrame:(NSDictionary *)closeBtnFrame
                                                                logoType:(YumiAdsLogoType)logoType
                                                                delegate:
                                                                    (id<YumiAdsWKCustomViewControllerDelegate>)delegate;

- (void)loadHTMLString:(NSString *)htmlStr;
- (void)loadBaseUrl:(NSURL *)url;
- (void)presentFromRootViewController:(UIViewController *)viewController;
- (void)closeButtonPressed;

@end
NS_ASSUME_NONNULL_END
