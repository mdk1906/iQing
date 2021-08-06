//
//  YumiAdsCustomView.h
//  Pods
//
//  Created by 甲丁乙_ on 2017/6/8.
//
//

#import "YumiAdsConstants.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol YumiAdsCustomViewDelegate <NSObject>

- (void)yumiAdsCustomViewDidFinishLoad:(UIWebView *)webView;
- (void)yumiAdsCustomView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
- (void)didClickOnYumiAdsCustomView:(UIWebView *)webView point:(CGPoint)point;
- (UIViewController *)rootViewControllerForPresentYumiAdsCustomView;
@optional
- (void)didClickOnYumiAdsCustomViewWithPoint:(CGPoint)point;

@end

@interface YumiAdsCustomView : UIView
@property (nonatomic, assign) BOOL isStyleOptimization;
@property (nonatomic) NSString *clickURL;
@property (nonatomic) NSString *itunesID;

+ (instancetype) new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (YumiAdsCustomView *)initYumiAdsCustomViewWith:(CGRect)frame
                                       clickType:(YumiAdsClickType)clickType
                                        logoType:(YumiAdsLogoType)logoType
                                        delegate:(id<YumiAdsCustomViewDelegate>)delegate;

- (void)loadHTMLString:(NSString *)htmlStr;
- (void)loadBaseUrl:(NSURL *)url;

@end
NS_ASSUME_NONNULL_END
