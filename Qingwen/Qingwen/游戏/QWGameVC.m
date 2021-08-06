//
//  QWGameVC.m
//  Qingwen
//
//  Created by Aimy on 5/9/16.
//  Copyright © 2016 iQing. All rights reserved.
//

#import "QWGameVC.h"

#import "QWWebView.h"
#import <MJRefresh.h>
#import "QWNonModelLoadingView.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "QWGameSettingView.h"
#import "QWGameSubscribeView.h"
#import <WebKit/WebKit.h>
#import "WeakScriptMessageDelegate.h"
@interface QWGameVC () < QWGameSettingViewDelegate,
WKScriptMessageHandler,
WKUIDelegate,
UITextFieldDelegate,
WKNavigationDelegate>
{
    //登录界面
    UIView *loginView;
    UIButton *areaCodeBtn;
    NSString *stateStr;
    //注册界面
    UIView *registeView;
    UIButton *registAreaCodeBtn;
    NSString *registStateStr;
    UITextField *registTelTf;
    UITextField *registPassTf;
    UITextField *registCodeTf;
    UIButton *registCodeBtn;
    //忘记密码
    UIView *forgetView;
    UIButton *forgetAreaCodeBtn;
    NSString *forgetStateStr;
    UITextField *forgetTelTf;
    UITextField *forgetPassTf;
    UITextField *forgetCodeTf;
    UIButton *forgetCodeBtn;
    
}
//新登录界面
@property (nonatomic,strong)UITextField *telTf;
@property (nonatomic,strong)UITextField *passTf;
@property (nonatomic, strong) QWPopoverView *stateView;
@property (nonatomic, strong) NSArray *resource;
@property (strong, nonatomic) QWDeadtimeTimer *timer;

@property (nonatomic, strong) QWGameDetailLogic *DetailLogic;
@property (nonatomic, strong) QWMyCenterLogic *logic;
@property (nonatomic, strong) QWMyCenterLogic *centerLogic;

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic ,strong )WKWebViewConfiguration *config;
@property (nonatomic, assign) BOOL needUpdate;

@property (nonatomic, strong) QWGameSettingView *settingView;

@property (nonatomic, strong) QWGameSubscribeView *subscribeView;

@property (nonatomic, strong) QWGameEndVC *endVC;

@property (nonatomic, strong) NSString *key;

@property (nonatomic, strong, nullable) NSString *url;

@property (nonatomic) BOOL barStatusHiden;  // 状态栏是否隐藏

@end
#define viewWidth UISCREEN_WIDTH*0.57
#define viewHeight UISCREEN_HEIGHT*0.693
#define leftLength (UISCREEN_WIDTH-UISCREEN_WIDTH*0.57)/2
#define btnHeight UISCREEN_HEIGHT*0.10
#define topLength (UISCREEN_HEIGHT-UISCREEN_HEIGHT*0.693)/2
@implementation QWGameVC

+ (void)load
{
    QWMappingVO *vo = [QWMappingVO new];
    vo.className = [NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject;
    vo.createdType = QWMappingClassCreateByCode;
    [[QWRouter sharedInstance] registerRouterVO:vo withKey:@"game"];
}

- (QWGameDetailLogic *)DetailLogic
{
    if (!_DetailLogic) {
        _DetailLogic = [QWGameDetailLogic logicWithOperationManager:self.operationManager];
    }
    
    return _DetailLogic;
}

- (QWMyCenterLogic *)logic
{
    if (!_logic) {
        _logic = [QWMyCenterLogic logicWithOperationManager:self.operationManager];
    }
    
    return _logic;
}
- (QWMyCenterLogic *)centerLogic {
    if (!_centerLogic) {
        _centerLogic = [QWMyCenterLogic logicWithOperationManager:self.operationManager];
    }
    return _centerLogic;
}

- (void)loadView
{
    [super loadView];
}
- (QWPopoverView *)stateView {
    if (!_stateView) {
        //获取stateLabelRect 里面的位置
        CGPoint point = CGPointMake(50 + leftLength+60, UISCREEN_HEIGHT*0.2+btnHeight/2);
        _stateView = [[QWPopoverView alloc] initWithPoint:point titles:self.resource size:CGSizeMake(120, 150)];
    }
    return _stateView;
}
- (NSArray *)resource {
    if (!_resource) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"state" ofType:@"plist"];
        NSArray *states = [NSArray arrayWithContentsOfFile:plistPath];
        NSMutableArray *tempStates = @[].mutableCopy;
        [states enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *statesNumbers = [obj objectForKey:@"states"];
            [statesNumbers enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [tempStates addObject:obj];
            }];
        }];
        _resource = tempStates.copy;
        
    }
    return _resource;
}
- (void)setupViews
{
    [self.webView removeFromSuperview];
    NSString *sendToken = [NSString stringWithFormat:@"backToApp"];
    
    //WKUserScriptInjectionTimeAtDocumentStart：js加载前执行。
    //WKUserScriptInjectionTimeAtDocumentEnd：js加载后执行。
    //下面的injectionTime配置不要写错了
    //forMainFrameOnly:NO(全局窗口)，yes（只限主窗口）
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:sendToken injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    self.config = [[WKWebViewConfiguration alloc] init];
    
    //配置js(这个很重要，不配置的话，下面注入的js是不起作用的)
    //WeakScriptMessageDelegate这个类是用来避免循环引用的
    [_config.userContentController addScriptMessageHandler:[[WeakScriptMessageDelegate alloc] initWithDelegate:self] name:@"backToApp"];
    [_config.userContentController addScriptMessageHandler:[[WeakScriptMessageDelegate alloc] initWithDelegate:self] name:@"getClientToken"];
    // 开启屏幕常亮
    [_config.userContentController addScriptMessageHandler:[[WeakScriptMessageDelegate alloc] initWithDelegate:self] name:@"onKeepScreenLight"];
    
    // 关闭屏幕常亮
    [_config.userContentController addScriptMessageHandler:[[WeakScriptMessageDelegate alloc] initWithDelegate:self] name:@"offKeepScreenLight"];
    //注入js
    [_config.userContentController addUserScript:wkUScript];
    _config.allowsInlineMediaPlayback = YES;
    if (@available(iOS 10.0, *)) {
        _config.mediaTypesRequiringUserActionForPlayback = false;
    } else {
        // Fallback on earlier versions
    }

    self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, UISCREEN_HEIGHT, UISCREEN_WIDTH) configuration: self.config];
    if ([UIScreen mainScreen].bounds.size.width == 812) {
        self.webView.frame = CGRectMake(0, 0, UISCREEN_WIDTH, UISCREEN_HEIGHT);
        if (@available(iOS 11.0, *)) {
            self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
    }
    else{
        
    }
    [self.webView canGoBack];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.scrollView.scrollEnabled = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.webView setOpaque:YES];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    [self.view addSubview:self.webView];
    
    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_webView)]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_webView)]];
    
    
    
}

- (BOOL)prefersStatusBarHidden
{
    if (self.endVC) {
        return NO;
    }
    else {
        if (self.barStatusHiden) {
            return YES;
        }
        return self.settingView.hidden;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.endVC) {
        return UIStatusBarStyleDefault;
    }
    else {
        return UIStatusBarStyleLightContent;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.fd_prefersNavigationBarHidden = YES;
    self.fd_interactivePopDisabled = YES;
    
    self.settingView = [QWGameSettingView createWithNib];
    self.settingView.delegate = self;
    self.settingView.hidden = YES;
    [self.view addSubview:self.settingView];
    [self.settingView autoCenterInSuperview];
    [self.settingView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view];
    [self.settingView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.view];

    self.subscribeView = [QWGameSubscribeView createWithNib];
    self.subscribeView.hidden = YES;
    [self.view addSubview:self.subscribeView];
    [self.subscribeView autoCenterInSuperview];
    [self.subscribeView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view];
    [self.subscribeView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.view];

    self.title = @"演绘";
    self.view.backgroundColor = HRGB(0xf4f4f4);
    
    self.url = self.contentUrl;
    if ([self.extraData objectForCaseInsensitiveKey:@"content_url"] && [[self.extraData objectForCaseInsensitiveKey:@"content_url"] isKindOfClass:[NSString class]]) {
        self.url = [self.extraData objectForCaseInsensitiveKey:@"content_url"];
        if ([QWGlobalValue sharedInstance].channel_token) {
            self.url = [NSString stringWithFormat:@"%@&token=%@",self.url,[QWGlobalValue sharedInstance].channel_token];
            NSLog(@"token____%@",self.url);
        }
    }
    if ([self.extraData objectForCaseInsensitiveKey:@"title"]) {
        self.title = [self.extraData objectForCaseInsensitiveKey:@"title"];
    }
    
    if ([self.extraData objectForCaseInsensitiveKey:@"id"]) {
        self.bookId = [[[self.extraData objectForCaseInsensitiveKey:@"id"] toNumberIfNeeded] stringValue];
    }
    
    if ([self.extraData objectForCaseInsensitiveKey:@"url"]) {
        self.bookUrl = [self.extraData objectForCaseInsensitiveKey:@"url"];
    }
    
    WEAK_SELF;
    [self observeNotification:LOGIN_STATE_CHANGED withBlock:^(__weak id self, NSNotification *notification) {
        KVO_STRONG_SELF;
        //        [QWWebView setupDefaultCookies];
        if (!notification) {
            return;
        }
        NSString *token = [QWGlobalValue sharedInstance].token;
        NSString *setToken = [NSString stringWithFormat:@" ('%@')",token];
        NSLog(@"setToken = %@",setToken);
        [kvoSelf.webView evaluateJavaScript:setToken completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            NSLog(@"成功 = %@ 失败 = %@",result,error);
            //此处可以打印error.
            
        }];
        
    }];
    if (IOS_SDK_LESS_THAN(10.0)) {
        [self observeNotification:UIApplicationDidBecomeActiveNotification withBlock:^(__weak id self, NSNotification *notification) {
            if (!notification) {
                return ;
            }
            
            KVO_STRONG_SELF;
            NSString *scripte = @"window.iqa.root.onActive()";
            //                [kvoSelf.webView stringByEvaluatingJavaScriptFromString:scripte];
            [kvoSelf.webView evaluateJavaScript:scripte completionHandler:nil];
        }];
        
        
        [self observeNotification:UIApplicationWillResignActiveNotification withBlock:^(__weak id self, NSNotification *notification) {
            if (!notification) {
                return ;
            }
            KVO_STRONG_SELF;
            NSString *scripte = @"window.iqa.root.onDeactivate()";
            //            [kvoSelf.webView stringByEvaluatingJavaScriptFromString:scripte];
            [kvoSelf.webView evaluateJavaScript:scripte completionHandler:nil];
        }];
    }
    
    if (self.bookUrl.length) {
        WEAK_SELF;
        [self.DetailLogic getDetailWithBookUrl:self.bookUrl andCompleteBlock:^(id aResponseObject, NSError *anError) {
            STRONG_SELF;
            if (self.DetailLogic.bookVO.bf_url.length) {
                self.settingView.discussBtn.hidden = NO;
            }
            if (self.DetailLogic.bookVO.share_url.length) {
                self.settingView.shareBtn.hidden = NO;
            }
            self.settingView.titleLabel.text = self.DetailLogic.bookVO.title;
        }];
    }
    else if (self.bookId.length) {
        WEAK_SELF;
        [self.DetailLogic getDetailWithBookId:self.bookId andCompleteBlock:^(id aResponseObject, NSError *anError) {
            STRONG_SELF;
            if (self.DetailLogic.bookVO.bf_url.length) {
                self.settingView.discussBtn.hidden = NO;
            }
            if (self.DetailLogic.bookVO.share_url.length) {
                self.settingView.shareBtn.hidden = NO;
            }
            self.settingView.titleLabel.text = self.DetailLogic.bookVO.title;
        }];
    }
    self.stateView.selectRowAtIndex = ^(NSInteger index) {
        STRONG_SELF;
        NSDictionary *dic = [self.resource objectAtIndex:index];
        [self->areaCodeBtn setTitle:[NSString stringWithFormat:@"+%@",dic[@"code"]] forState:0];
        [self->registAreaCodeBtn setTitle:[NSString stringWithFormat:@"+%@",dic[@"code"]] forState:0];
        [self->forgetAreaCodeBtn setTitle:[NSString stringWithFormat:@"+%@",dic[@"code"]] forState:0];
        
            self->stateStr = self->areaCodeBtn.titleLabel.text;
            self->stateStr = self->forgetAreaCodeBtn.titleLabel.text;
            self->stateStr = self->registAreaCodeBtn.titleLabel.text;
        
    };
    self.timer = [QWDeadtimeTimer new];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.url.length) {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
        //刷新
        [UIViewController attemptRotationToDeviceOrientation];
        [self setupViews];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.webView loadHTMLString:@"" baseURL:nil];
    if (self.settingView.orientationBtn.selected) {
        [self.settingView onPressedOrientationBtn:self.settingView.orientationBtn];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.settingView.orientationBtn.selected == false) { //setingView == nil 退出
        [self.settingView onPressedOrientationBtn:self.settingView.orientationBtn];
    }
    
}

- (void)hideSetting {
    [self.settingView.contentTV resignFirstResponder];
    self.settingView.hidden = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}



- (void)setIQingTitle:(NSString *)title
{
    WEAK_SELF;
    NSLog(@"setIQingTitle = %@", title);
    [self performInMainThreadBlock:^{
        STRONG_SELF;
        self.title = title;
    }];
}

- (void)routerWithUrlString:(NSString *)title
{
    NSLog(@"routerWithUrlString = %@", title);
    [self performInMainThreadBlock:^{
        [[QWRouter sharedInstance] routerWithUrlString:title];
    }];
}

- (void)setGameProgress:(NSInteger)gameId :(NSString *)progress
{
    NSLog(@"setGameProgress = %@, %@", @(gameId), progress);
    if (gameId <= 0) {
        return;
    }
    
    BookCD *bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@", @(gameId)] inContext:[QWFileManager qwContext]];
    if (!bookCD) {
        bookCD = [BookCD MR_createEntityInContext:[QWFileManager qwContext]];
        bookCD.game = YES;
    }
    bookCD.nid = @(gameId);
    bookCD.progress = progress;
    [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];
}

- (NSString *)getGameProgress:(NSInteger)gameId
{
    NSLog(@"getGameProgress = %@", @(gameId));
    BookCD *bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@", @(gameId)] inContext:[QWFileManager qwContext]];
    
    return bookCD.progress ?: @"";
}

- (void)setGameStep:(float)gameStep {
    [self.settingView updateProgress:gameStep];
}

- (void)submitDanmu:(NSInteger)gameId :(NSString *)progress
{
    NSLog(@"submitDanmu = %@, %@", @(gameId), progress);
    [self showClientMenu];
}

- (void)showClientMenu
{
    NSLog(@"showClientMenu");
    [self performInMainThreadBlock:^{
        self.settingView.hidden = NO;
        [self setNeedsStatusBarAppearanceUpdate];
    }];
    
}

- (void)showEnd
{
    NSLog(@"showEnd");
    
    [self performInMainThreadBlock:^{
        if (self.settingView.orientationBtn.selected) {
            [self.settingView onPressedOrientationBtn:self.settingView.orientationBtn];
        }
        [self.webView loadHTMLString:@"" baseURL:nil];
        self.navigationController.navigationBarHidden = NO;
        self.endVC = [QWGameEndVC createFromStoryboardWithStoryboardID:@"end" storyboardName:@"QWGame"];
        self.fd_prefersNavigationBarHidden = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        self.endVC.bookId = self.bookId;
        self.endVC.book_url = self.bookUrl;
        [self addChildViewController:self.endVC];
        [self.endVC willMoveToParentViewController:self];
        [self.view addSubview:self.endVC.view];
        self.endVC.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.endVC.view autoCenterInSuperview];
        [self.endVC.view autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view];
        [self.endVC.view autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.view];
    }];
}

- (void)setKey:(NSString *)key
{
    NSLog(@"setKey %@", key);
    _key = key;
}

- (void)backToApp {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)setClientToken:(NSString *)token {
    if ([token isEmpty]) {
        [[QWRouter sharedInstance] routerToLogin];
    }
    [QWGlobalValue sharedInstance].token = token;
    [[QWGlobalValue sharedInstance] save];
    WEAK_SELF;
    [self.centerLogic getUserInfoWithCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (anError) {
            [self showToastWithTitle:[anError description] subtitle:nil type:ToastTypeError];
            [[QWRouter sharedInstance] routerToLogin];
        }
    }];
}

- (NSString *)getClientToken {
    if (![QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        return @"false";
    }
    
    return [QWGlobalValue sharedInstance].token;
}

- (void)showSubscribeWithChapterId:(NSString *)chapterId andGold:(NSString *)gold {
    [self performInMainThreadBlock:^{
        WEAK_SELF;
        [self.subscribeView showWithGameId:self.bookId chapterId:chapterId gold:gold andCompletBlock:^(QWSubscriberActionType type) {
            STRONG_SELF;
            NSMutableString *scripte = [NSMutableString stringWithFormat:@"iqa.root.payStatus"];
            switch (type) {
                case QWSubscriberActionTypeBuy:
                    [scripte appendString:@"('0')"];
                    break;
                case QWSubscriberActionTypeRemove:
                    [scripte appendString:@"('1')"];
                    break;
                default:
                    [scripte appendString:@"('2')"];
                    break;
            }
            //            [self.webView stringByEvaluatingJavaScriptFromString:scripte];
            [self.webView evaluateJavaScript:scripte completionHandler:nil];
        }];
    }];
}

#pragma mark - QWGameSettingViewDelegate
- (void)settingView:(QWGameSettingView *)view didClickedBackBtn:(id)sender
{
    if (self.settingView.orientationBtn.selected) {
        [self.settingView onPressedOrientationBtn:self.settingView.orientationBtn];
    }
    [self leftBtnClicked:sender];
}

- (void)settingView:(QWGameSettingView *)view didClickedShareBtn:(id)sender
{
    [self hideSetting];
    if (self.settingView.orientationBtn.selected) {
        self.settingView.orientationBtn.selected = false;
        [self.settingView changeConstraint];
    }
    BookVO *book = self.DetailLogic.bookVO;
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"title"] = book.title;
    params[@"image"] = book.cover;
    params[@"intro"] = book.intro;
    params[@"url"] = book.share_url;
    [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"share" andParams:params]];
}

- (void)settingView:(QWGameSettingView *)view didClickedDiscussBtn:(id)sender
{
    [self hideSetting];
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"url"] = self.DetailLogic.bookVO.bf_url;
    [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"discuss" andParams:params]];
}

- (void)settingView:(QWGameSettingView *)view didClickedSendBtn:(id)sender
{
    if (self.settingView.contentTV.text.length == 0) {
        return;
    }
    
    if (![QWGlobalValue sharedInstance].isLogin) {
        if (self.settingView.orientationBtn.selected) {
            [self.settingView onPressedOrientationBtn:self.settingView.orientationBtn];
        }
        [[QWRouter sharedInstance] routerToLogin];
        return;
    }
    
    [self.settingView.contentTV resignFirstResponder];
    NSString *content = self.settingView.contentTV.text;
    
    [self showLoading];
    WEAK_SELF;
    [self.DetailLogic submitDanmu:self.key content:content completeBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && [code isKindOfClass:[NSNumber class]] && ! [code isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"data"];
                if ([message isKindOfClass:[NSString class]] && message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:@"发送弹幕失败" subtitle:nil type:ToastTypeAlert];
                }
            }
            else {
                NSString *danmu = [NSString stringWithFormat:@"showDanmu('%@')", content];
                //                [self.webView stringByEvaluatingJavaScriptFromString:danmu];
                [self.webView evaluateJavaScript:danmu completionHandler:nil];
                self.settingView.contentTV.text = nil;
                [self hideSetting];
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }
        
        [self hideLoading];
    }];
}

- (void)settingView:(QWGameSettingView *)view didClickedCancelBtn:(id)sender
{
    [self hideSetting];
}

- (void)settingView:(QWGameSettingView *)view didClickOrientationBtn:(id)sender {
    [self rotationToDeviceOrientation];
}

- (void)settingView:(QWGameSettingView *)view didClickedProgressSlider:(UISlider *)sender {
    NSString *gameStep = [NSString stringWithFormat:@"clientSetStep('%f')", sender.value];
    //    [self.webView stringByEvaluatingJavaScriptFromString:gameStep];
    [self.webView evaluateJavaScript:gameStep completionHandler:nil];
}

- (void)askSuperVCChangeStatusBarWithState:(BOOL)state {
    self.barStatusHiden = !state;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)settingView:(QWGameSettingView *)view didClickedResolutionBtn:(UIButton *)sender {
    NSString *definition = [NSString stringWithFormat:@"setDefinition('%ld')",(long)sender.tag];
    //    [self.webView stringByEvaluatingJavaScriptFromString:definition];
    [self.webView evaluateJavaScript:definition completionHandler:nil];
}

- (void)settingView:(QWGameSettingView *)view didClickedPauseBtn:(UIButton *)sender {
    NSString *playerStatus = @"";
    if (sender.selected) {
        playerStatus = @"play";
    }
    else {
        playerStatus = @"pause";
    }
    NSString *clientSetPlayerStatus = [NSString stringWithFormat:@"clientSetPlayerStatus('%@')",playerStatus];
    //    [self.webView stringByEvaluatingJavaScriptFromString:clientSetPlayerStatus];
    [self.webView evaluateJavaScript:clientSetPlayerStatus completionHandler:nil];
}

#pragma mark - 屏幕旋转

- (void)rotationToDeviceOrientation {
    if (self.settingView.orientationBtn.selected) {
        [self forceLandScape];
    }
    else {
        [self forcePortrait];
    }
    [UIViewController attemptRotationToDeviceOrientation];
    UIInterfaceOrientation sataus=[UIApplication sharedApplication].statusBarOrientation;
    NSLog(@"屏幕旋转 = %ld",(long)sataus);
}

- (void)forcePortrait {
    CGFloat width = UISCREEN_WIDTH;
    CGFloat height = UISCREEN_HEIGHT;
    
    if (width > height) {
        UIDevice *device = [UIDevice currentDevice];
        NSNumber *number = @(UIDeviceOrientationPortrait);
        [device setValue:number forKey:@"orientation"];
    }
}

-(void)forceLandScape{
    CGFloat width = UISCREEN_WIDTH;
    CGFloat height = UISCREEN_HEIGHT;
    
    if (width < height) {
        UIDevice *device = [UIDevice currentDevice];
        NSNumber *number = @(UIDeviceOrientationLandscapeLeft);
        [device setValue:number forKey:@"orientation"];
    }
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (IS_IPHONE_DEVICE) {
        if (self.settingView.orientationBtn.selected) {
            return UIInterfaceOrientationMaskLandscapeRight;
        } else {
            return UIInterfaceOrientationMaskPortrait;
        }
    }
    else {
        return UIInterfaceOrientationMaskAll;
    }
}

#pragma mark - wkwebView
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSLog(@"JS 调用了 %@ 方法，传回参数 %@",message.name,message.body);
    if ([message.name isEqualToString:@"backToApp"]) {
        [self.navigationController popViewControllerAnimated:true];
    }
    if ([message.name isEqualToString:@"getClientToken"]) {
        if (![QWGlobalValue sharedInstance].isLogin) {
            [self createLoginView];
        }
        
    }
    if ([message.name isEqualToString:@"onKeepScreenLight"]) {
        //开启屏幕常亮
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES]; //屏幕常亮
    }
    if ([message.name isEqualToString:@"offKeepScreenLight"]) {
        //关闭屏幕常亮
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO]; //关闭常亮
    }
    
}
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    NSLog(@"提示信息：%@", message);   //js的alert框的message
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - 登录界面UI
-(void)createLoginView{
    
    loginView = [UIView new];
    loginView.frame = CGRectMake(leftLength, topLength, viewWidth, viewHeight);
    loginView.layer.cornerRadius = 5;
    loginView.layer.masksToBounds = YES;
    loginView.backgroundColor = UIColor.whiteColor;
    loginView.layer.borderWidth = 1;
    loginView.layer.borderColor = HRGB(0xadadad).CGColor;
    [self.view addSubview:loginView];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 23, viewWidth, 25)];
    titleLab.textColor = HRGB(0x4e4142);
    titleLab.font = [UIFont systemFontOfSize:17];
    titleLab.text = @"账号登录";
    titleLab.textAlignment = 1;
    [loginView addSubview:titleLab];
    
    UIButton *cancelBtn = [UIButton new];
    cancelBtn.frame = CGRectMake(viewWidth-20-19, 14.5, 19, 19);
    [cancelBtn setImage:[UIImage imageNamed:@"取消"] forState:0];
    [cancelBtn addTarget:self action:@selector(onPressCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    [loginView addSubview:cancelBtn];
    
    UIView *firstView = [UIView new];
    firstView.frame = CGRectMake(50, UISCREEN_HEIGHT*0.2, viewWidth-110, btnHeight);
    firstView.layer.cornerRadius = 5;
    firstView.layer.masksToBounds = YES;
    firstView.layer.borderWidth = 1;
    firstView.layer.borderColor = HRGB(0xdcdcdc).CGColor;
    [loginView addSubview:firstView];
    
    areaCodeBtn = [UIButton new];
    areaCodeBtn.frame = CGRectMake(0, 0, UISCREEN_HEIGHT*0.2, btnHeight);
    [areaCodeBtn setTitle:@"+86" forState:0];
    areaCodeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [areaCodeBtn setTitleColor:HRGB(0x505050) forState:0];
    areaCodeBtn.backgroundColor = [UIColor clearColor];
    stateStr = @"+86";
    [areaCodeBtn addTarget:self action:@selector(onPrssedStateBtn) forControlEvents:UIControlEventTouchUpInside];
    [firstView addSubview:areaCodeBtn];
    
    _telTf = [UITextField new];
    _telTf.frame = CGRectMake(kMaxX(areaCodeBtn.frame)+10, 0, viewWidth-110-UISCREEN_HEIGHT*0.2, btnHeight);
    _telTf.placeholder = @"   请输入手机号";
    _telTf.keyboardType = UIKeyboardTypePhonePad;
    _telTf.delegate = self;
    _telTf.font = [UIFont systemFontOfSize:14];
    [firstView addSubview:_telTf];
    
    UIView *hui = [UIView new];
    hui.frame = CGRectMake(kMaxX(areaCodeBtn.frame), 1, 1, btnHeight-2);
    hui.backgroundColor = HRGB(0xdcdcdc);
    [firstView addSubview:hui];
    
    UIView *secondView = [UIView new];
    secondView.frame = CGRectMake(50, kMaxY(firstView.frame)+10, viewWidth-110, btnHeight);
    secondView.layer.cornerRadius = 5;
    secondView.layer.masksToBounds = YES;
    secondView.layer.borderWidth = 1;
    secondView.layer.borderColor = HRGB(0xdcdcdc).CGColor;
    [loginView addSubview:secondView];
    
    _passTf = [UITextField new];
    _passTf.frame = CGRectMake(10, 0, viewWidth-110, btnHeight);
    _passTf.placeholder = @"请输入密码";
    _passTf.keyboardType = UIKeyboardTypeDefault;
    _passTf.secureTextEntry = YES;
    _passTf.delegate = self;
    _passTf.font = [UIFont systemFontOfSize:14];
    [secondView addSubview:_passTf];
    
    UIButton *loginBtn = [UIButton new];
    loginBtn.frame = CGRectMake(50, kMaxY(secondView.frame)+10.5, viewWidth-50*2, btnHeight);
    [loginBtn setTitle:@"登录" forState:0];
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:19];
    [loginBtn setTintColor:HRGB(0xffffff)];
    loginBtn.layer.cornerRadius = 5;
    [loginBtn addTarget:self action:@selector(onPressLoginBtn) forControlEvents:UIControlEventTouchUpInside];
    loginBtn.layer.masksToBounds = YES;
    loginBtn.backgroundColor = HRGB(0xfb83ac);
    [loginView addSubview:loginBtn];
    
    UIButton *registBtn = [UIButton new];
    registBtn.frame = CGRectMake(50, kMaxY(loginBtn.frame)+7.5, 75, 20);
    [registBtn setTitle:@"立即注册" forState:0];
    registBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [registBtn setTitleColor:HRGB(0xfb83ac) forState:0];
    registBtn.backgroundColor = [UIColor clearColor];
    [registBtn addTarget:self action:@selector(createRegistUI) forControlEvents:UIControlEventTouchUpInside];
    [loginView addSubview:registBtn];
    
    UIButton *forgetBtn = [UIButton new];
    forgetBtn.frame = CGRectMake(viewWidth-50-75, kMaxY(loginBtn.frame)+7.5, 75, 20);
    [forgetBtn setTitle:@"忘记密码？" forState:0];
    forgetBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [forgetBtn setTitleColor:HRGB(0xfb83ac) forState:0];
    forgetBtn.backgroundColor = [UIColor clearColor];
    [forgetBtn addTarget:self action:@selector(createForgetUI) forControlEvents:UIControlEventTouchUpInside];
    [loginView addSubview:forgetBtn];
}

-(void)onPressLoginBtn{
    if (!self.telTf.text.length) {
        [self showToastWithTitle:@"手机号不能为空" subtitle:nil type:ToastTypeError];
        return ;
    }
    
    if (!self.passTf.text.length) {
        [self showToastWithTitle:@"密码不能为空" subtitle:nil type:ToastTypeError];
        return ;
    }
    
    if (self.passTf.text.length < 2) {
        [self showToastWithTitle:@"密码不能小于2位" subtitle:nil type:ToastTypeError];
        return ;
    }
    
    if (self.passTf.text.length > 24) {
        [self showToastWithTitle:@"密码不能大于24位" subtitle:nil type:ToastTypeError];
        return ;
    }
    
    [self endTextEditing];
    
    NSString *phone = self.telTf.text;
    if (![self->stateStr isEqualToString:@"+86"]) {
        phone = [NSString stringWithFormat:@"%@%@", [self->stateStr stringByReplacingOccurrencesOfString:@"+" withString:@""], self.telTf.text];
    }
    WEAK_SELF;
    [self showLoading];
    [self.logic loginWithName:phone password:self.passTf.text andCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"data"];
                if (message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:@"登录失败" subtitle:nil type:ToastTypeError];
                }
            }
            else {
                [self saveGlobalValueWithAResponseObject:aResponseObject];
                [QWKeychain setKeychainValue:self.telTf.text forType:@"phone"];
                [QWKeychain setKeychainValue:self->stateStr forType:@"state"];
                [self->loginView removeFromSuperview];
                [self->registeView removeFromSuperview];
                [self->forgetView removeFromSuperview];
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }
        
        [self hideLoading];
    }];
}
-(void)onPressCancelBtn{
    [loginView removeFromSuperview];
    [registeView removeFromSuperview];
    [forgetView removeFromSuperview];
    NSString *quitLogin = [NSString stringWithFormat:@"IQA.NativeCall.requestLoginQuit()"];
    NSLog(@"quitLogin = %@",quitLogin);
    [self.webView evaluateJavaScript:quitLogin completionHandler:nil];
}
-(void)onPrssedStateBtn{
    [self.stateView show];
}
#pragma mark - 注册界面UI
-(void)createRegistUI{
    [loginView removeFromSuperview];
    [forgetView removeFromSuperview];
    
    registeView = [UIView new];
    registeView.frame = CGRectMake(leftLength, topLength, viewWidth, viewHeight);
    registeView.layer.cornerRadius = 5;
    registeView.layer.masksToBounds = YES;
    registeView.backgroundColor = UIColor.whiteColor;
    registeView.layer.borderWidth = 1;
    registeView.layer.borderColor = HRGB(0xadadad).CGColor;
    [self.view addSubview:registeView];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 23, viewWidth, 25)];
    titleLab.textColor = HRGB(0x4e4142);
    titleLab.font = [UIFont systemFontOfSize:17];
    titleLab.text = @"账号注册";
    titleLab.textAlignment = 1;
    [registeView addSubview:titleLab];
    
    UIButton *cancelBtn = [UIButton new];
    cancelBtn.frame = CGRectMake(viewWidth-20-19, 14.5, 19, 19);
    [cancelBtn setImage:[UIImage imageNamed:@"取消"] forState:0];
    [cancelBtn addTarget:self action:@selector(onPressCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    [registeView addSubview:cancelBtn];
    
    UIView *firstView = [UIView new];
    firstView.frame = CGRectMake(50, UISCREEN_HEIGHT*0.2, viewWidth-110, btnHeight);
    firstView.layer.cornerRadius = 5;
    firstView.layer.masksToBounds = YES;
    firstView.layer.borderWidth = 1;
    firstView.layer.borderColor = HRGB(0xdcdcdc).CGColor;
    [registeView addSubview:firstView];
    
    registAreaCodeBtn = [UIButton new];
    registAreaCodeBtn.frame = CGRectMake(0, 0, UISCREEN_HEIGHT*0.2, btnHeight);
    [registAreaCodeBtn setTitle:@"+86" forState:0];
    registAreaCodeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [registAreaCodeBtn setTitleColor:HRGB(0x505050) forState:0];
    registAreaCodeBtn.backgroundColor = [UIColor clearColor];
    stateStr = @"+86";
    [registAreaCodeBtn addTarget:self action:@selector(onPrssedStateBtn) forControlEvents:UIControlEventTouchUpInside];
    [firstView addSubview:registAreaCodeBtn];
    
    registTelTf = [UITextField new];
    registTelTf.frame = CGRectMake(kMaxX(areaCodeBtn.frame)+10, 0, viewWidth-110-UISCREEN_HEIGHT*0.2, btnHeight);
    registTelTf.placeholder = @"   请输入手机号";
    registTelTf.keyboardType = UIKeyboardTypePhonePad;
    registTelTf.delegate = self;
    registTelTf.font = [UIFont systemFontOfSize:14];
    [firstView addSubview:registTelTf];
    
    UIView *hui = [UIView new];
    hui.frame = CGRectMake(kMaxX(areaCodeBtn.frame), 1, 1, btnHeight);
    hui.backgroundColor = HRGB(0xdcdcdc);
    [firstView addSubview:hui];
    
    UIView *secondView = [UIView new];
    secondView.frame = CGRectMake(50, kMaxY(firstView.frame)+10, viewWidth-110, btnHeight);
    secondView.layer.cornerRadius = 5;
    secondView.layer.masksToBounds = YES;
    secondView.layer.borderWidth = 1;
    secondView.layer.borderColor = HRGB(0xdcdcdc).CGColor;
    [registeView addSubview:secondView];
    
    registPassTf = [UITextField new];
    registPassTf.frame = CGRectMake(10, 0, viewWidth-110, btnHeight);
    registPassTf.placeholder = @"设置密码";
    registPassTf.keyboardType = UIKeyboardTypeDefault;
    registPassTf.secureTextEntry = YES;
    registPassTf.delegate = self;
    registPassTf.font = [UIFont systemFontOfSize:14];
    [secondView addSubview:registPassTf];
    
    UIView *ThirdView = [UIView new];
    ThirdView.frame = CGRectMake(50, kMaxY(secondView.frame)+10, viewWidth-100, btnHeight);
    [registeView addSubview:ThirdView];
    
    registCodeTf = [UITextField new];
    registCodeTf.frame = CGRectMake(0, 0, viewWidth-100-UISCREEN_WIDTH*0.16-15, btnHeight);
    registCodeTf.placeholder = @"  六位数验证码";
    registCodeTf.keyboardType = UIKeyboardTypeNumberPad;
    //    registCodeTf.secureTextEntry = YES;
    registCodeTf.delegate = self;
    registCodeTf.font = [UIFont systemFontOfSize:14];
    registCodeTf.layer.borderWidth = 1;
    registCodeTf.layer.borderColor = HRGB(0xdcdcdc).CGColor;
    registCodeTf.layer.cornerRadius = 5;
    registCodeTf.layer.masksToBounds = YES;
    [ThirdView addSubview:registCodeTf];
    
    registCodeBtn = [UIButton new];
    registCodeBtn.frame = CGRectMake(viewWidth-100-UISCREEN_WIDTH*0.16, 0, UISCREEN_WIDTH*0.16, btnHeight);
    [registCodeBtn setTitle:@"发送验证码" forState:0];
    registCodeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [registCodeBtn setTitleColor:HRGB(0x505050) forState:0];
    registCodeBtn.backgroundColor = [UIColor clearColor];
    registCodeBtn.layer.borderWidth = 1;
    registCodeBtn.layer.borderColor = HRGB(0xdcdcdc).CGColor;
    registCodeBtn.layer.cornerRadius = 5;
    registCodeBtn.layer.masksToBounds = YES;
    [registCodeBtn addTarget:self action:@selector(onpressRegistCodeBtn) forControlEvents:UIControlEventTouchUpInside];
    [ThirdView addSubview:registCodeBtn];
    
    UIButton *loginBtn = [UIButton new];
    loginBtn.frame = CGRectMake(50, kMaxY(ThirdView.frame)+10.5, viewWidth-50*2, btnHeight);
    [loginBtn setTitle:@"注册" forState:0];
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:19];
    [loginBtn setTintColor:HRGB(0xffffff)];
    loginBtn.layer.cornerRadius = 5;
    [loginBtn addTarget:self action:@selector(onPressRegistBtn) forControlEvents:UIControlEventTouchUpInside];
    loginBtn.layer.masksToBounds = YES;
    loginBtn.backgroundColor = HRGB(0xfb83ac);
    [registeView addSubview:loginBtn];
}
-(void)onpressRegistCodeBtn{
//    registCodeBtn.enabled = NO;
    if (!registTelTf.text.length) {
        [self showToastWithTitle:@"手机号为空" subtitle:nil type:ToastTypeError];
        return ;
    }
    
    NSString *phone = registTelTf.text;
    if ( ! [stateStr isEqualToString:@"+86"]) {
        phone = [NSString stringWithFormat:@"%@%@", [stateStr stringByReplacingOccurrencesOfString:@"+" withString:@""], self->registTelTf.text];
    }
    
    [self showLoading];
    
    WEAK_SELF;
    [self.logic sendVerificationCodeToPhone:phone registe:QWVerificationTypeRegiste andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (!anError && code && [code isEqualToNumber:@0]) {
                [self.timer runWithDeadtime:[NSDate dateWithTimeIntervalSinceNow:60.f] andBlock:^(NSDateComponents *dateComponents) {
                    STRONG_SELF;
                    if (dateComponents.second > 0) {
                        [self->registCodeBtn setTitle:[NSString stringWithFormat:@"%@秒",@(dateComponents.second)] forState:UIControlStateNormal];
                    }
                    else {
                        self->registCodeBtn.enabled = YES;
                        [self->registCodeBtn setTitle:@"重发" forState:UIControlStateNormal];
                    }
                }];
            }
            else {
                if ([code isEqualToNumber:@-1]) {
                    [self showToastWithTitle:@"发送失败" subtitle:nil type:ToastTypeError];
                }
                else {
                    NSString *message = aResponseObject[@"msg"];
                    if (message.length) {
                        [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                    }
                    else {
                        [self showToastWithTitle:@"发送失败" subtitle:nil type:ToastTypeError];
                    }
                }
                
                self->registCodeBtn.enabled = YES;
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
            self->registCodeBtn.enabled = YES;
        }
        
        [self hideLoading];
    }];
    
}
-(void)onPressRegistBtn{
    if (!registTelTf.text.length) {
        [self showToastWithTitle:@"手机号不能为空" subtitle:nil type:ToastTypeError];
        return ;
    }
    
    if (!registCodeTf.text.length) {
        [self showToastWithTitle:@"验证码不能为空" subtitle:nil type:ToastTypeError];
        return ;
    }
    
    if (registCodeTf.text.length != 6) {
        [self showToastWithTitle:@"验证码不正确" subtitle:nil type:ToastTypeError];
        return ;
    }
    
    
    if (!registPassTf.text.length) {
        [self showToastWithTitle:@"密码不能为空" subtitle:nil type:ToastTypeError];
        return ;
    }
    
    if (registPassTf.text.length < 2) {
        [self showToastWithTitle:@"密码不能小于2位" subtitle:nil type:ToastTypeError];
        return ;
    }
    
    if (registPassTf.text.length > 24) {
        [self showToastWithTitle:@"密码不能大于24位" subtitle:nil type:ToastTypeError];
        return ;
    }
    
    NSString *phone = registTelTf.text;
    if ( ! [stateStr isEqualToString:@"+86"]) {
        phone = [NSString stringWithFormat:@"%@%@", [stateStr stringByReplacingOccurrencesOfString:@"+" withString:@""], self->registTelTf.text];
    }
    
    [self endTextEditing];
    
    WEAK_SELF;
    [self showLoading];
    [self.logic registWithName:phone password:registPassTf.text code:registCodeTf.text username:@"" invite:@"" andCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"data"];
                if ([message isKindOfClass:[NSString class]] && message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:@"注册失败" subtitle:nil type:ToastTypeError];
                }
            }
            else {
                [QWGlobalValue sharedInstance].token = aResponseObject[@"token"];
                [QWGlobalValue sharedInstance].username = aResponseObject[@"username"];
                [QWGlobalValue sharedInstance].nid = aResponseObject[@"id"];
                [QWGlobalValue sharedInstance].profile_url = aResponseObject[@"profile_url"];
                [QWGlobalValue sharedInstance].channel_token = aResponseObject[@"channel_token"];
                UserVO *user = [UserVO voWithDict:aResponseObject];
                [QWGlobalValue sharedInstance].user = user;
                [[QWGlobalValue sharedInstance] save];
                
                [QWKeychain setKeychainValue:phone forType:@"phone"];
                
                [[QWBindingValue sharedInstance] update];
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_STATE_CHANGED object:nil];
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }
        
        [self hideLoading];
        
    }];
}
#pragma mark - 忘记密码UI
-(void)createForgetUI{
    [loginView removeFromSuperview];
    [registeView removeFromSuperview];
    
    forgetView = [UIView new];
    forgetView.frame = CGRectMake(leftLength, topLength, viewWidth, viewHeight);
    forgetView.layer.cornerRadius = 5;
    forgetView.layer.masksToBounds = YES;
    forgetView.backgroundColor = UIColor.whiteColor;
    forgetView.layer.borderWidth = 1;
    forgetView.layer.borderColor = HRGB(0xadadad).CGColor;
    [self.view addSubview:forgetView];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 23, viewWidth, 25)];
    titleLab.textColor = HRGB(0x4e4142);
    titleLab.font = [UIFont systemFontOfSize:17];
    titleLab.text = @"忘记密码";
    titleLab.textAlignment = 1;
    [forgetView addSubview:titleLab];
    
    UIButton *cancelBtn = [UIButton new];
    cancelBtn.frame = CGRectMake(viewWidth-20-19, 14.5, 19, 19);
    [cancelBtn setImage:[UIImage imageNamed:@"取消"] forState:0];
    [cancelBtn addTarget:self action:@selector(onPressCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    [forgetView addSubview:cancelBtn];
    
    UIView *firstView = [UIView new];
    firstView.frame = CGRectMake(50, UISCREEN_HEIGHT*0.2, viewWidth-110, btnHeight);
    firstView.layer.cornerRadius = 5;
    firstView.layer.masksToBounds = YES;
    firstView.layer.borderWidth = 1;
    firstView.layer.borderColor = HRGB(0xdcdcdc).CGColor;
    [forgetView addSubview:firstView];
    
    forgetAreaCodeBtn = [UIButton new];
    forgetAreaCodeBtn.frame = CGRectMake(0, 0, UISCREEN_HEIGHT*0.2, btnHeight);
    [forgetAreaCodeBtn setTitle:@"+86" forState:0];
    forgetAreaCodeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [forgetAreaCodeBtn setTitleColor:HRGB(0x505050) forState:0];
    forgetAreaCodeBtn.backgroundColor = [UIColor clearColor];
    stateStr = @"+86";
    [forgetAreaCodeBtn addTarget:self action:@selector(onPrssedStateBtn) forControlEvents:UIControlEventTouchUpInside];
    [firstView addSubview:forgetAreaCodeBtn];
    
    forgetTelTf = [UITextField new];
    forgetTelTf.frame = CGRectMake(kMaxX(areaCodeBtn.frame)+10, 0, viewWidth-110-UISCREEN_HEIGHT*0.2, btnHeight);
    forgetTelTf.placeholder = @"   请输入手机号";
    forgetTelTf.keyboardType = UIKeyboardTypePhonePad;
    forgetTelTf.delegate = self;
    forgetTelTf.font = [UIFont systemFontOfSize:14];
    [firstView addSubview:forgetTelTf];
    
    UIView *hui = [UIView new];
    hui.frame = CGRectMake(kMaxX(areaCodeBtn.frame), 1, 1, btnHeight);
    hui.backgroundColor = HRGB(0xdcdcdc);
    [firstView addSubview:hui];
    
    UIView *secondView = [UIView new];
    secondView.frame = CGRectMake(50, kMaxY(firstView.frame)+10, viewWidth-110, btnHeight);
    secondView.layer.cornerRadius = 5;
    secondView.layer.masksToBounds = YES;
    secondView.layer.borderWidth = 1;
    secondView.layer.borderColor = HRGB(0xdcdcdc).CGColor;
    [forgetView addSubview:secondView];
    
    forgetPassTf = [UITextField new];
    forgetPassTf.frame = CGRectMake(10, 0, viewWidth-110, btnHeight);
    forgetPassTf.placeholder = @"设置密码";
    forgetPassTf.keyboardType = UIKeyboardTypeDefault;
    forgetPassTf.secureTextEntry = YES;
    forgetPassTf.delegate = self;
    forgetPassTf.font = [UIFont systemFontOfSize:14];
    [secondView addSubview:forgetPassTf];
    
    UIView *ThirdView = [UIView new];
    ThirdView.frame = CGRectMake(50, kMaxY(secondView.frame)+10, viewWidth-110, btnHeight);
    [forgetView addSubview:ThirdView];
    
    forgetCodeTf = [UITextField new];
    forgetCodeTf.frame = CGRectMake(0, 0, viewWidth-100-UISCREEN_WIDTH*0.16-15, btnHeight);
    forgetCodeTf.placeholder = @"  六位数验证码";
    forgetCodeTf.keyboardType = UIKeyboardTypeNumberPad;
    //    registCodeTf.secureTextEntry = YES;
    forgetCodeTf.delegate = self;
    forgetCodeTf.font = [UIFont systemFontOfSize:14];
    forgetCodeTf.layer.borderWidth = 1;
    forgetCodeTf.layer.borderColor = HRGB(0xdcdcdc).CGColor;
    forgetCodeTf.layer.cornerRadius = 5;
    forgetCodeTf.layer.masksToBounds = YES;
    [ThirdView addSubview:forgetCodeTf];
    
    forgetCodeBtn = [UIButton new];
    forgetCodeBtn.frame = CGRectMake(viewWidth-100-UISCREEN_WIDTH*0.16, 0, UISCREEN_WIDTH*0.16, btnHeight);
    [forgetCodeBtn setTitle:@"发送验证码" forState:0];
    forgetCodeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [forgetCodeBtn setTitleColor:HRGB(0x505050) forState:0];
    forgetCodeBtn.backgroundColor = [UIColor clearColor];
    forgetCodeBtn.layer.borderWidth = 1;
    forgetCodeBtn.layer.borderColor = HRGB(0xdcdcdc).CGColor;
    forgetCodeBtn.layer.cornerRadius = 5;
    forgetCodeBtn.layer.masksToBounds = YES;
    [forgetCodeBtn addTarget:self action:@selector(onpressForgetCodeBtn) forControlEvents:UIControlEventTouchUpInside];
    [ThirdView addSubview:forgetCodeBtn];
    
    UIButton *loginBtn = [UIButton new];
    loginBtn.frame = CGRectMake(50, kMaxY(ThirdView.frame)+10.5, viewWidth-50*2, btnHeight);
    [loginBtn setTitle:@"找回密码" forState:0];
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:19];
    [loginBtn setTintColor:HRGB(0xffffff)];
    loginBtn.layer.cornerRadius = 5;
    [loginBtn addTarget:self action:@selector(onPressForgetBtn) forControlEvents:UIControlEventTouchUpInside];
    loginBtn.layer.masksToBounds = YES;
    loginBtn.backgroundColor = HRGB(0xfb83ac);
    [forgetView addSubview:loginBtn];
}
-(void)onPressForgetBtn{
    if (!forgetTelTf.text.length) {
        [self showToastWithTitle:@"手机号不能为空" subtitle:nil type:ToastTypeError];
        return ;
    }
    
    if (!forgetCodeTf.text.length) {
        [self showToastWithTitle:@"验证码不能为空" subtitle:nil type:ToastTypeError];
        return ;
    }
    
    if (forgetCodeTf.text.length != 6) {
        [self showToastWithTitle:@"验证码不正确" subtitle:nil type:ToastTypeError];
        return ;
    }
    
    if (!forgetPassTf.text.length) {
        [self showToastWithTitle:@"密码不能为空" subtitle:nil type:ToastTypeError];
        return ;
    }
    
    if (forgetPassTf.text.length < 2) {
        [self showToastWithTitle:@"密码不能小于2位" subtitle:nil type:ToastTypeError];
        return ;
    }
    
    if (forgetPassTf.text.length > 24) {
        [self showToastWithTitle:@"密码不能大于24位" subtitle:nil type:ToastTypeError];
        return ;
    }
    
    if (!forgetPassTf.text.length) {
        [self showToastWithTitle:@"密码不能为空" subtitle:nil type:ToastTypeError];
        return ;
    }
    
    if (forgetPassTf.text.length < 2) {
        [self showToastWithTitle:@"密码不能小于2位" subtitle:nil type:ToastTypeError];
        return ;
    }
    
    if (forgetPassTf.text.length > 24) {
        [self showToastWithTitle:@"密码不能大于24位" subtitle:nil type:ToastTypeError];
        return ;
    }
    
    NSString *phone = forgetTelTf.text;
    if ( ! [stateStr isEqualToString:@"+86"]) {
        phone = [NSString stringWithFormat:@"%@%@", stateStr, self->registTelTf.text];
    }
    
    [self endTextEditing];
    
    WEAK_SELF;
    [self showLoading];
    [self.logic resetPasswordWithPhone:phone password:forgetPassTf.text code:forgetCodeTf.text andCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"data"];
                if (message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:@"重置失败" subtitle:nil type:ToastTypeError];
                }
            }
            else {
                [[QWGlobalValue sharedInstance] clear];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_STATE_CHANGED object:nil];
                [self->loginView removeFromSuperview];
                [self->registeView removeFromSuperview];
                [self->forgetView removeFromSuperview];
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }
        
        [self hideLoading];
    }];
}
-(void)onpressForgetCodeBtn{
    if (!forgetTelTf.text.length) {
        [self showToastWithTitle:@"手机号为空" subtitle:nil type:ToastTypeError];
        return ;
    }
    
    NSString *phone = forgetTelTf.text;
    if ( ! [stateStr isEqualToString:@"+86"]) {
        phone = [NSString stringWithFormat:@"%@%@", stateStr, self->registTelTf.text];
    }
    
    forgetCodeBtn.enabled = NO;
    
    WEAK_SELF;
    [self showLoading];
    [self.logic sendVerificationCodeToPhone:phone registe:QWVerificationTypeResetPassword andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (!anError && code && [code isEqualToNumber:@0]) {
                [self.timer runWithDeadtime:[NSDate dateWithTimeIntervalSinceNow:60.f] andBlock:^(NSDateComponents *dateComponents) {
                    STRONG_SELF;
                    if (dateComponents.second > 0) {
                        [self->forgetCodeBtn setTitle:[NSString stringWithFormat:@"%@秒",@(dateComponents.second)] forState:UIControlStateNormal];
                    }
                    else {
                        self->forgetCodeBtn.enabled = YES;
                        [self->forgetCodeBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
                    }
                }];
            }
            else {
                if ([code isEqualToNumber:@-1]) {
                    [self showToastWithTitle:@"发送失败" subtitle:nil type:ToastTypeError];
                }
                else {
                    NSString *message = aResponseObject[@"msg"];
                    if (message.length) {
                        [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                    }
                    else {
                        [self showToastWithTitle:@"发送失败" subtitle:nil type:ToastTypeError];
                    }
                }
                
                self->forgetCodeBtn.enabled = YES;
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
            self->forgetCodeBtn.enabled = YES;
        }
        
        [self hideLoading];
    }];
}


- (void)saveGlobalValueWithAResponseObject:(NSDictionary *)aResponseObject {
    
    [QWGlobalValue sharedInstance].token = aResponseObject[@"token"];
    NSLog(@"token12345 = %@",[QWGlobalValue sharedInstance].token);
    [QWGlobalValue sharedInstance].username = aResponseObject[@"username"];
    [QWGlobalValue sharedInstance].nid = aResponseObject[@"id"];
    [QWGlobalValue sharedInstance].profile_url = aResponseObject[@"profile_url"];
    UserVO *user = [UserVO voWithDict:aResponseObject];
    [QWGlobalValue sharedInstance].user = user;
    [QWGlobalValue sharedInstance].channel_token = aResponseObject[@"channel_token"];
    
    if (aResponseObject[@"update_username"] != nil) {
        [QWGlobalValue sharedInstance].update_username = aResponseObject[@"update_username"];
    }
    else{
        [QWGlobalValue sharedInstance].update_username = 0;
    }
    [[QWGlobalValue sharedInstance] save];
    
    [[QWBindingValue sharedInstance] update];
    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_STATE_CHANGED object:nil];
}

@end
