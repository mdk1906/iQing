//
//  QWWebVC.m
//  
//
//  Created by Aimy on 9/7/15.
//
//

#import "QWWebVC.h"
#import <MJRefresh.h>
#import "QWNonModelLoadingView.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "QWWebPURLProtocol.h"

@interface QWWebVC () <UIWebViewDelegate>

@property (nonatomic, assign) BOOL needUpdate;
@property (nonatomic, strong) NSString *url;

@end

@implementation QWWebVC

+ (void)load
{
    QWMappingVO *vo = [QWMappingVO new];
    vo.className = [NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject;
    vo.createdType = QWMappingClassCreateByCode;
    [[QWRouter sharedInstance] registerRouterVO:vo withKey:@"web"];
}

- (void)loadView
{
    [super loadView];
    [self setupViews];
    [QWWebView setupDefaultCookies];
}

- (void)setupViews
{
    self.webView = [QWWebView autolayoutView];
    [self.view addSubview:self.webView];
    self.webView.delegate = self;

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_webView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_webView)]];

    //下拉刷新
    WEAK_SELF;
    self.webView.scrollView.mj_header = [QWRefreshHeader headerWithRefreshingBlock:^{
        STRONG_SELF;
        [self.webView reload];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSURLProtocol registerClass:[QWWebPURLProtocol class]];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = HRGB(0xf4f4f4);

    // get JSContext from UIWebView instance
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];

    // enable error logging
    [context setExceptionHandler:^(JSContext *context, JSValue *value) {
        NSLog(@"WEB JS: %@", value);
    }];

    WEAK_SELF;
    context[@"setIQingTitle"] = ^(JSValue *title) {
        STRONG_SELF;
        NSLog(@"setIQingTitle = %@", title);
        [self performInMainThreadBlock:^{
            STRONG_SELF;
            self.title = title.toString;
        }];
    };

    context[@"routerWithUrlString"] = ^(JSValue *title) {
        STRONG_SELF;
        NSLog(@"routerWithUrlString = %@", title);
        [self performInMainThreadBlock:^{
            STRONG_SELF;
            [[QWRouter sharedInstance] routerWithUrlString:title.toString];
        }];
    };

    if ([self.extraData objectForCaseInsensitiveKey:@"url"] && [[self.extraData objectForCaseInsensitiveKey:@"url"] isKindOfClass:[NSString class]]) {
        NSString *url = [self.extraData objectForCaseInsensitiveKey:@"url"];
        self.url = url;
        if (self.navigationController.topViewController ==  self) {
            [self addRightBarBtn];
        }
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }

    if ([self.extraData objectForCaseInsensitiveKey:@"localurl"] && [[self.extraData objectForCaseInsensitiveKey:@"localurl"] isKindOfClass:[NSString class]]) {
        NSString *localurl = [self.extraData objectForCaseInsensitiveKey:@"localurl"];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:localurl]]];
    }

    if ([self.extraData objectForCaseInsensitiveKey:@"title"]) {
        self.title = [self.extraData objectForCaseInsensitiveKey:@"title"];
    }

    [self observeNotification:LOGIN_STATE_CHANGED withBlock:^(__weak id self, NSNotification *notification) {
        KVO_STRONG_SELF;
        [QWWebView setupDefaultCookies];
        if (kvoSelf.navigationController.topViewController == self) {
            [kvoSelf.webView reload];
        }
        else {
            kvoSelf.needUpdate = YES;
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    //web view刷新
    if (self.needUpdate) {
        self.needUpdate = NO;
        [self.webView reload];
    }
}

- (void)addRightBarBtn {
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_safari"] style:UIBarButtonItemStylePlain target:self action:@selector(onPressedRightBarBtn)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)onPressedRightBarBtn {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] bk_initWithTitle:nil];
    WEAK_SELF;
    [actionSheet bk_addButtonWithTitle:@"分享" handler:^{
        STRONG_SELF;
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"title"] = self.title;
        params[@"url"] = self.url;
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"share" andParams:params]];
    }];
    
    [actionSheet bk_addButtonWithTitle:@"在Safari中打开" handler:^{
        STRONG_SELF;
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.url]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
        }
    }];
    [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:^{
        
    }];
    [actionSheet showInView:self.view];
}

#pragma mark - Left Buttons Action
- (void)onPressedExit
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onPressedGoBack
{
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }
    else {
        [super leftBtnClicked:nil];
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    NSLog(@"webview = %@",url.absoluteString);

    if ([QWHost isEqualToString:url.host] || [QWScheme isEqualToString:url.scheme]) {//界面跳转url
        //在当前界面才处理url
        if (self.navigationController.topViewController == self) {
//            [[QWRouter sharedInstance] routerWithUrl:url];
            NSString *routerUrl = [NSString getRouterVCUrlStringFromUrlString:url.absoluteString];
            NSURL *tmpUrl = [NSURL URLWithString:routerUrl];
            
            if ([tmpUrl.host isEqualToString:@"web"]) {
                return YES;
            }
            else {
                [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:url.absoluteString]];
            }
        }
        return NO;
    }
    else if ([QWFuncScheme isEqualToString:url.scheme]) {//iOS native func url
        //在当前界面才处理url
        if (self.navigationController.topViewController == self) {
            [[QWRouter sharedInstance] routerWithUrl:url];
        }
        return NO;
    }

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [QWNonModelLoadingView showLoadingAddedTo:webView animated:YES];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [QWNonModelLoadingView hideLoadingForView:webView animated:YES];
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (title.length) {
        self.title = title;
    }
    [self.webView.scrollView.mj_header endRefreshing];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [QWNonModelLoadingView hideLoadingForView:webView animated:YES];
    [self.webView.scrollView.mj_header endRefreshing];
}

@end
