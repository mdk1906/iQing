//
//  YumiAdsWKCustomView.h
//  YumiMediationSDK
//
//  Created by Michael Tang on 2018/5/23.
//

#import "YumiAdsConstants.h"
#import "YumiAdsModel.h"
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol YumiAdsWKCustomViewDelegate <NSObject>

- (void)yumiAdsWKCustomViewDidFinishLoad:(WKWebView *)webView;
- (void)yumiAdsWKCustomView:(WKWebView *)webView didFailLoadWithError:(NSError *)error;
- (void)didClickOnYumiAdsWKCustomView:(WKWebView *)webView point:(CGPoint)point;
- (UIViewController *)rootViewControllerForPresentYumiAdsWKCustomView;
@optional
- (void)didClickOnYumiAdsWKCustomViewWithPoint:(CGPoint)point;

@end

@interface YumiAdsWKCustomView : UIView

@property (nonatomic, assign) BOOL isStyleOptimization;
@property (nonatomic) NSString *clickURL;
@property (nonatomic) NSString *itunesID;
@property (nonatomic) NSString *deeplinkUrl;

+ (instancetype) new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (YumiAdsWKCustomView *)initYumiAdsWKCustomViewWith:(CGRect)frame
                                           clickType:(YumiAdsClickType)clickType
                                            logoType:(YumiAdsLogoType)logoType
                                            delegate:(id<YumiAdsWKCustomViewDelegate>)delegate;

- (void)loadHTMLString:(NSString *)htmlStr;
- (void)loadBaseUrl:(NSURL *)url;

@end
NS_ASSUME_NONNULL_END
