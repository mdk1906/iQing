//
//  QWActivityWebVC.m
//  Qingwen
//
//  Created by mumu on 2017/4/24.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWActivityWebVC.h"
#import "QWBestLogic.h"
#import <JavaScriptCore/JavaScriptCore.h>
//#import <WebKit/WebKit.h>
#import "QWNonModelLoadingView.h"
#import "QWWebPURLProtocol.h"
#import "QWMyCenterLogic.h"
@protocol QWActivityJSObjectProtocol <JSExport>

//签到
-(void)SignIn;
//投石
-(void)CastStone;
//登录
-(void)WebLogin;
//充值
-(void)WebCharge;
//调token
-(void)ReadToken;
//token过期
-(void)ExpireToken;

//分享
-(void)PostShare;
@end

@interface QWActivityJSObject : NSObject<QWActivityJSObjectProtocol>

@property (nonatomic, weak) id<QWActivityJSObjectProtocol> delegate;

@end

@implementation QWActivityJSObject


- (void)CastStone {
    [self.delegate CastStone];
}

- (void)SignIn {
    [self.delegate SignIn];
}

- (void)WebCharge {
    [self.delegate WebCharge];
}

- (void)WebLogin {
    [self.delegate WebLogin];
}

-(void)ReadToken{
    [self.delegate ReadToken];
}

- (void)ExpireToken {
    [self.delegate ExpireToken];
}

-(void)PostShare{
    [self.delegate PostShare];
}
@end

@interface QWActivityWebVC ()<QWActivityJSObjectProtocol>

@property (nonatomic, strong) QWBestLogic *logic;

@property (nonatomic, strong) QWMyCenterLogic *centerlogic;
@end

@implementation QWActivityWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInset = UIEdgeInsetsMake(self.view.safeAreaInsets.top, 0, self.view.safeAreaInsets.bottom, 0);
    }else{
        self.webView.scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    }
    
    [self getCookie];
//    self.webView.scrollView.mj_header = [QWRefreshHeader headerWithRefreshingBlock:^{
//
//    }];
    self.webView.scrollView.mj_header.hidden = YES;
    self.webView.scrollView.mj_footer.hidden = YES;
    
    WEAK_SELF;
    [self observeNotification:LOGIN_STATE_CHANGED withBlock:^(__weak id self, NSNotification *notification) {
        KVO_STRONG_SELF;
        [QWWebView setupDefaultCookies];
        NSString *setAc_code = [NSString stringWithFormat:@"WebLogin('%@')",[QWGlobalValue sharedInstance].token];
        [kvoSelf.webView stringByEvaluatingJavaScriptFromString:setAc_code];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webShareSuccessful) name:@"webShareSuccessful" object:nil];
}
-(void)webShareSuccessful{
//
    NSString *setAc_code = [NSString stringWithFormat:@"Webshare"];
    NSLog(@"Webshare = %@",setAc_code);
    [self.webView stringByEvaluatingJavaScriptFromString:setAc_code];
}
- (void)getCookie{
    NSString *locationUrl = self.url;
    if (!self.url) {
        if ([self.extraData objectForCaseInsensitiveKey:@"url"] && [[self.extraData objectForCaseInsensitiveKey:@"url"] isKindOfClass:[NSString class]]) {
            NSString *url = [self.extraData objectForCaseInsensitiveKey:@"url"];
            locationUrl = url;
        }
    }
    
    if (!locationUrl) {
        return;
    }

    WEAK_SELF;
    [self.logic getPromotionCookiesWithUrl:locationUrl andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (!anError && aResponseObject) {
           [self.webView reload];
        }
        else {
            if ([anError.userInfo[NSLocalizedDescriptionKey] rangeOfString:@"401"].location != NSNotFound || [anError.userInfo[NSLocalizedDescriptionKey] rangeOfString:@"403"].location != NSNotFound) {
            }
            [self showToastWithTitle:@"获取失败" subtitle:nil type:ToastTypeError];
        }
    }];
}

- (QWBestLogic *)logic
{
    if (!_logic) {
        _logic = [QWBestLogic logicWithOperationManager:self.operationManager];
    }
    
    return _logic;
}

- (QWMyCenterLogic *)centerlogic
{
    if (!_centerlogic) {
        _centerlogic = [QWMyCenterLogic logicWithOperationManager:self.operationManager];
    }
    
    return _centerlogic;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
    [QWNonModelLoadingView showLoadingAddedTo:webView animated:YES];
    
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"加载js");
    
    [QWNonModelLoadingView hideLoadingForView:webView animated:YES];
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (title.length) {
        self.title = title;
    }
    [self.webView.scrollView.mj_header endRefreshing];
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    context[@"window.client.readConfig"] = ^(JSValue *valuew) {
        NSLog(@"setIQingTitle = %@", valuew);
    };
    [self setContext];
    
}

- (void)setContext {
    // get JSContext from UIWebView instance
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    // enable error logging
    [context setExceptionHandler:^(JSContext *context, JSValue *value) {
        NSLog(@"WEB JS: %@", value);
    }];
    QWActivityJSObject *jso = [QWActivityJSObject new];
    jso.delegate = self;
    context[@"client"] = jso;
    
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    NSLog(@"webview = %@",url.absoluteString);
    
    if ([QWHost isEqualToString:url.host] || [QWScheme isEqualToString:url.scheme] || [QWMHost isEqualToString:url.host]) {//界面跳转url
        //在当前界面才处理url
            //            [[QWRouter sharedInstance] routerWithUrl:url];
            NSString *routerUrl = [NSString getRouterVCUrlStringFromUrlString:url.absoluteString];
            NSURL *tmpUrl = [NSURL URLWithString:routerUrl];
            
            if ([tmpUrl.host isEqualToString:@"web"] || [tmpUrl.host isEqualToString:@"actopic"]) {
                return YES;
            }
            else {
                [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:url.absoluteString]];
        }
        return NO;
    }
    else if ([url.absoluteString rangeOfString:@"favorite"].location != NSNotFound){
        NSLog(@"是书单");
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:url.absoluteString]];
        return NO;
    }
    else if ([url.absoluteString rangeOfString:@"book"].location != NSNotFound){
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:url.absoluteString]];
        return NO;
    }
    else if ([url.absoluteString rangeOfString:@"biligame"].location != NSNotFound){
        [[QWRouter sharedInstance] routerWithUrlString:url.absoluteString];
        return NO;
    }
    else if ([url.absoluteString rangeOfString:@"play"].location != NSNotFound){
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:url.absoluteString]];
        return NO;
    }
    else if ([QWFuncScheme isEqualToString:url.scheme]) {//iOS native func url
        [[QWRouter sharedInstance] routerWithUrl:url];
        return NO;
    }
    
    return YES;
}

- (void)CastStone {
    NSLog(@"CastStone");
}

- (void)SignIn {
    NSLog(@"SignIn");
    [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"mycenter" andParams:nil]];
    
    
}

- (void)WebCharge {
    NSLog(@"WebCharge");
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        return;
    }
    QWCharge *charge = [QWCharge new];
    [charge doCharge];
}

- (void)WebLogin {
    NSLog(@"WebLogin");
}

-(void)ReadToken{
    NSLog(@"传token");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //inset code....
        if ( ! [QWGlobalValue sharedInstance].isLogin) {
            [[QWRouter sharedInstance] routerToLogin];
            return;
        }
        NSString *setAc_code = [NSString stringWithFormat:@"WebLogin('%@')",[QWGlobalValue sharedInstance].token];
        NSLog(@"setAc_code = %@",setAc_code);
        [self.webView stringByEvaluatingJavaScriptFromString:setAc_code];
    });
    
}

- (void)ExpireToken {
    NSLog(@"丢失token");
}
-(void)PostShare{
    NSLog(@"PostShare");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"webViewShare" object:nil];
//    [self webShareSuccessful];
}

@end
