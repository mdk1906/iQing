//
//  AppDelegate.m
//  Qingwen
//
//  Created by Aimy on 7/1/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "AppDelegate.h"

#import "QWReachability.h"
#import "QWFileManager.h"
#import "QWUserDefaults.h"
#import "QWPatch.h"
#import "QWTracker.h"
#import "QWShareManager.h"
#import "QWBlacListManager.h"
#import "QWLoginVC.h"

#import <SDImageCache.h>
#import <GBVersionTracking/GBVersionTracking.h>

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#import "MiPushSDK.h"

#import "QWDownloadManager.h"
#import "QWMigrateManager.h"
#import "QWGameVC.h"

#import "QWPush.h"

#import "IFlyMSC/IFlyMSC.h"

//#import "SQLiteManager.h"
#import "QWGameVC.h"
#import "IQKeyboardManager.h"
#import "AvoidCrash.h"
#import "BaiduMobStat.h"
#import "GDTMobSDK/GDTSplashAd.h"
#import <BUAdSDK/BUAdSDKManager.h>
@interface AppDelegate () <MiPushSDKDelegate, UNUserNotificationCenterDelegate,GDTSplashAdDelegate>
@property (strong, nonatomic) GDTSplashAd *splash;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager]; // 获取类库的单例变量
    
    keyboardManager.enable = YES; // 控制整个功能是否启用
    
    keyboardManager.shouldResignOnTouchOutside = YES; // 控制点击背景是否收起键盘
    
    keyboardManager.shouldToolbarUsesTextFieldTintColor = YES; // 控制键盘上的工具条文字颜色是否用户自定义
    
    keyboardManager.toolbarManageBehaviour = IQAutoToolbarBySubviews; // 有多个输入框时，可以通过点击Toolbar 上的“前一个”“后一个”按钮来实现移动到不同的输入框
    
    keyboardManager.enableAutoToolbar = YES; // 控制是否显示键盘上的工具条
    
    //    keyboardManager.shouldShowTextFieldPlaceholder = YES; // 是否显示占位文字
    
    keyboardManager.placeholderFont = [UIFont boldSystemFontOfSize:17]; // 设置占位文字的字体
    
    keyboardManager.keyboardDistanceFromTextField = 10.0f; // 输入框距离键盘的距离
    

    //百度统计
    [BaiduMobStat defaultStat].enableExceptionLog = YES;
//    [BaiduMobStat defaultStat].enableDebugOn = YES;
    [BaiduMobStat defaultStat].channelId = [QWTracker sharedInstance].channel;
    [BaiduMobStat defaultStat].shortAppVersion = [QWTracker sharedInstance].Build;
    [BaiduMobStat defaultStat].sessionResumeInterval = 1;
    [[BaiduMobStat defaultStat] startWithAppId:BAIDU_ID];
    
    //友盟删除
//    [MobClick setCrashReportEnabled:NO];
//    [MobClick startWithAppkey:UMENG_ID reportPolicy:BATCH channelId:[QWTracker sharedInstance].channel];
//    [MobClick setAppVersion:[QWTracker sharedInstance].Build];
    //crash
//    [Fabric with:@[[Crashlytics class]]];
//    [[Crashlytics sharedInstance] setUserIdentifier:[QWTracker sharedInstance].channel];
//    [[Crashlytics sharedInstance] setObjectValue:[[GBVersionTracking versionHistory] componentsJoinedByString:@","] forKey:@"versionHistory"];
//    if ([QWGlobalValue sharedInstance].isLogin) {
//        [[Crashlytics sharedInstance] setObjectValue:[QWGlobalValue sharedInstance].nid forKey:@"userId"];
//    }


    [GBVersionTracking track];

    //run patch
//    [[QWPatch sharedInstance] config];

    //create folders
    [QWFileManager configDirectory];

    //迁移
    [QWMigrateManager migrate];

    if ([GBVersionTracking isFirstLaunchEver]) {
        //clear keychain data if reinstall
        [[QWGlobalValue sharedInstance] clear];
    }

    [[QWGlobalValue sharedInstance] config];
    
    [[QWBannedWords sharedInstance] getBannedWords];
    
    [[QWBindingValue sharedInstance] update];
    //获取网络连接状况
    [QWReachability sharedInstance];

    //下载相关
    [QWDownloadManager sharedInstance];
    
    //tips message tools
    [CRToastManager setDefaultOptions:@{
                                        kCRToastStatusBarStyleKey : @(UIStatusBarStyleLightContent),//浅色statusbar
                                        kCRToastAnimationInTimeIntervalKey : @0.2,//动画进来时间
                                        kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                                        kCRToastTimeIntervalKey : @0.5,//显示的时间
                                        kCRToastAnimationOutTimeIntervalKey : @0.1,//动画出去时间
                                        kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
                                        kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar),
                                        kCRToastNotificationPresentationTypeKey : @(CRToastPresentationTypeCover),
                                        kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                        kCRToastFontKey : [UIFont systemFontOfSize:20],
                                        kCRToastBackgroundColorKey : QWPINK,
                                         kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                        kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop),
                                        kCRToastAutorotateKey       : @YES
                                        }];

    //设置样式
    [[UINavigationBar appearance] setBarTintColor:HRGB(0xF8F8F8)];
    [[UINavigationBar appearance] setTintColor:HRGB(0x505050)];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: HRGB(0x505050), NSFontAttributeName: [UIFont systemFontOfSize:17]}];
    
    
    [[UITabBar appearance] setBarTintColor:HRGB(0xF9F9F9)];
    [[UITabBar appearance] setTintColor:HRGB(0x505050)];

    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: HRGB(0x848484)} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: QWPINK} forState:UIControlStateSelected];

    [[UITableView appearance] setSeparatorColor:HRGB(0xdcdcdc)];
    [[UITableView appearance] setBackgroundColor:HRGB(0xF4F4F4)];
    [[UICollectionView appearance] setBackgroundColor:HRGB(0xFFFFFFF)];

    [[UISegmentedControl appearance] setTintColor:[[UIColor whiteColor] colorWithAlphaComponent:.5f]];
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont boldSystemFontOfSize:14.0]} forState:UIControlStateNormal];
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: QWPINK, NSFontAttributeName: [UIFont boldSystemFontOfSize:14.0]} forState:UIControlStateSelected];

    [[UISwitch appearance] setOnTintColor:QWPINK];

    //推送
    [MiPushSDK registerMiPush:self type:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];

    //注册分享模块
    [QWShareManager sharedInstance];

    //恢复购买
    //    [QWPayManager sharedManager];

    //是否需要图片mask
    [[QWLocalPictures sharedInstance] checkBuildVersion];
    //获取黑名单
    [[QWBlacListManager sharedInstance] getBlackList];
    //注册router
    [[QWRouter sharedInstance] registerRootVC:self.window.rootViewController];

    //注册朗读
    //Set APPID
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=5af1637f"];
    
    //Configure and initialize iflytek services.(This interface must been invoked in application:didFinishLaunchingWithOptions:)
    [IFlySpeechUtility createUtility:initString];
    
    if (launchOptions[UIApplicationLaunchOptionsURLKey]) {//url打开
        NSURL *url = launchOptions[UIApplicationLaunchOptionsURLKey];
        NSString *sourceAppBundleId = launchOptions[UIApplicationLaunchOptionsSourceApplicationKey];
        id annotation = launchOptions[UIApplicationLaunchOptionsAnnotationKey];
        [self performInMainThreadBlock:^{
            [self application:application openURL:url sourceApplication:sourceAppBundleId annotation:annotation];
        } afterSecond:2.f];
    }
    else if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {//远程推送
        NSDictionary *userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        [self performInMainThreadBlock:^{
            NSString *url = userInfo[@"url"];
            [[QWRouter sharedInstance] routerWithUrlString:url];
        } afterSecond:2.f];
    }
    //创建postlog 数据库
    if (ISIPHONEX) {
        
    }
    else{
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        path = [path stringByAppendingPathComponent:@"postLog.sqlite"];
        NSURL *url = [NSURL fileURLWithPath:path];
        [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelWarn];
        [MagicalRecord setupCoreDataStackWithStoreAtURL:url];
    }
    
    //AvoidCrash配置
    //启动防止崩溃功能(注意区分becomeEffective和makeAllEffective的区别)
    //具体区别请看 AvoidCrash.h中的描述
    //建议在didFinishLaunchingWithOptions最初始位置调用 上面的方法
//
//    [AvoidCrash makeAllEffective];
//
//    //若出现unrecognized selector sent to instance导致的崩溃并且控制台输出:
//    //-[__NSCFConstantString initWithName:age:height:weight:]: unrecognized selector sent to instance
//    //你可以将@"__NSCFConstantString"添加到如下数组中，当然，你也可以将它的父类添加到下面数组中
//    //比如，对于部分字符串，继承关系如下
//    //__NSCFConstantString --> __NSCFString --> NSMutableString --> NSString
//    //你可以将上面四个类随意一个添加到下面的数组中，建议直接填入 NSString
//    NSArray *noneSelClassStrings = @[
//                                     @"NSString"
//                                     ];
//    [AvoidCrash setupNoneSelClassStringsArr:noneSelClassStrings];
//
//
//    //监听通知:AvoidCrashNotification, 获取AvoidCrash捕获的崩溃日志的详细信息
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealwithCrashMessage:) name:AvoidCrashNotification object:nil];
    
    
    
    
    //appKey 为预留字段，可填空字符串。
    if ([[QWGlobalValue sharedInstance].splash_ad intValue] == 0  ) {
        
        self.splash = [[GDTSplashAd alloc] initWithAppId:QWGDTAdKey placementId:QWGDTSplashAdKey];
        self.splash.delegate = self; //设置代理
        //根据iPhone设备不同设置不同背景图
        if ([[UIScreen mainScreen] bounds].size.height >= 568.0f) {
            self.splash.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LaunchImage-568h"]];
        } else {
            self.splash.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LaunchImage"]];
        }
        self.splash.fetchDelay = 5; //开发者可以设置开屏拉取时间，超时则放弃展示
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[@"source"] = @"GDT";
        [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"SplashEvent" extra:params];
        //［可选］拉取并展示全屏开屏广告
        [self.splash loadAdAndShowInWindow:self.window];
//        设置开屏底部自定义LogoView，展示半屏开屏广告
        
    }
    
    //穿山甲广告注册
    [BUAdSDKManager setAppID:QWCSJAdKey];
    
    return YES;
}
- (void)dealwithCrashMessage:(NSNotification *)note {
    //注意:所有的信息都在userInfo中
    //你可以在这里收集相应的崩溃信息进行相应的处理(比如传到自己服务器)
    NSMutableDictionary *params = [NSMutableDictionary new];
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    UINavigationController *navController = tabBarController.selectedViewController;
    UIViewController *serviceViewController = navController.topViewController;
    params[@"view"] = NSStringFromClass([serviceViewController class]);
    params[@"crashMsg"] = [NSString stringWithFormat:@"%@",note.userInfo];
    [QWUserStatistics postErrorDataToServers:params];
    NSLog(@"崩溃信息%@",note.userInfo);
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    [MagicalRecord cleanUp];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[SDImageCache sharedImageCache] clearMemory];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (IS_IPHONE_DEVICE) {
        if (self.window.rootViewController.presentedViewController != nil) {
            return UIInterfaceOrientationMaskPortrait;
        }
        
        QWTBC *tbc = (QWTBC *)self.window.rootViewController;
        QWBaseNC *baseNC = (QWBaseNC *)tbc.selectedViewController;
        if ([baseNC.topViewController isKindOfClass:[QWGameVC class]] || [baseNC.topViewController isKindOfClass:[QWLoginVC class]] ) {
            return UIInterfaceOrientationMaskAllButUpsideDown;
        } else {
            return UIInterfaceOrientationMaskPortrait;
        }
    }
    else {
        return UIInterfaceOrientationMaskAll;
    }
    
}
- (void)applicationwillenterForeground:(UIApplication *)application{

//这个方法会在应用程序从后台专到前台过程中被调用，可以在这边恢复正常运行所需要的信息。

}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    if (ISIPHONEX) {
        
    }
    else{
        NSMutableDictionary *params = [NSMutableDictionary new];
        UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
        UINavigationController *navController = tabBarController.selectedViewController;
        UIViewController *serviceViewController = navController.topViewController;
        params[@"view"] = NSStringFromClass([serviceViewController class]);
        NSLog(@"应用回到前台 = %@",params);
        [QWUserStatistics sendEventToServer:@"Event" pageID:@"AppBeActive" extra:params];
    }
    
    
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = [QWGlobalValue sharedInstance].unread.integerValue;
    if (ISIPHONEX) {
        
    }
    else{
        NSMutableDictionary *params = [NSMutableDictionary new];
        UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
        UINavigationController *navController = tabBarController.selectedViewController;
        UIViewController *serviceViewController = navController.topViewController;
        params[@"view"] = NSStringFromClass([serviceViewController class]);
        NSLog(@"应用在后台 = %@",params);
        [QWUserStatistics sendEventToServer:@"Event" pageID:@"AppGoBackground" extra:params];
    }
    if (![QWGlobalValue sharedInstance].isLogin) {
        //如果为空，代表未登录，不需要获取个人信息
        return ;
    }
}

#pragma mark - download
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    NSLog(@"handleEventsForBackgroundURLSession %@", identifier);
    if (completionHandler) {
        completionHandler();
    }
}

#pragma mark - mi push
- (void)miPushRequestSuccWithSelector:(NSString *)selector data:(NSDictionary *)data
{
    NSLog(@"push selector = %@, data = %@", selector, data);
    if ([selector isEqualToString:@"bindDeviceToken:"]) {
        [QWGlobalValue sharedInstance].pushId = data[@"regid"];
        NSLog(@"mipush id = %@",[QWGlobalValue sharedInstance].pushId);
        [[QWGlobalValue sharedInstance] save];
        [[QWPush sharedInstance] registPush];
    }
}

- (void)miPushRequestErrWithSelector:(NSString *)selector error:(int)error data:(NSDictionary *)data
{
    NSLog(@"push selector = %@, error = %d, data = %@", selector, error, data);
}

#pragma mark - regist apns
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"push deviceToken = %@", deviceToken);
    if (deviceToken.length) {
        [QWGlobalValue sharedInstance].deviceToken = deviceToken.description;
        [[QWGlobalValue sharedInstance] save];
        [MiPushSDK bindDeviceToken:deviceToken];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"push error = %@", error);
}

// iOS10新加入的回调方法
// 应用在前台收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [MiPushSDK handleReceiveRemoteNotification:userInfo];
    }
    //    completionHandler(UNNotificationPresentationOptionAlert);
}
// 点击通知进入应用
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [MiPushSDK handleReceiveRemoteNotification:userInfo];
    }
    completionHandler();
}
#pragma mark - remote Notification
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"push userInfo = %@", userInfo);
    NSString *url = userInfo[@"url"];
    NSString *message = userInfo[@"aps"][@"alert"];
    if (application.applicationState == UIApplicationStateActive) {
        UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"推送" message:message];
        [alertView bk_setCancelButtonWithTitle:@"忽略" handler:nil];
        [alertView bk_addButtonWithTitle:@"查看" handler:^{
            [[QWRouter sharedInstance] routerWithUrlString:url];
        }];

        [alertView show];
    }
    else {
        [[QWRouter sharedInstance] routerWithUrlString:url];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL flag = [QWShareManager handleOpenUrl:url sourceApplication:sourceApplication];
    if (flag) {
        return YES;
    }

    [[QWRouter sharedInstance] routerWithUrl:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
{
    if ([userActivity.activityType isEqualToString: @"NSUserActivityTypeBrowsingWeb"]) {
        NSURL *webpageURL = userActivity.webpageURL;
        if ( ! [self handleUniversalLink:webpageURL]) {
            [[UIApplication sharedApplication] openURL:webpageURL];
        }
    }
    return YES;
}

- (BOOL)handleUniversalLink:(NSURL *)url
{
    NSURLComponents *componets = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    NSString *host = componets.host;
    NSArray *pathComponents = componets.path.pathComponents;
    if ([host isEqualToString:@"www.iqing.in"] || [host isEqualToString:@"iqing.in"]) {
//        if (pathComponents.count > 1) {
//            if ([pathComponents[0] isEqualToString:@"/"] && [pathComponents[1] isEqualToString:@"book"]) {
//                NSString *bookId = pathComponents[2];
//                NSLog(@"handleUniversalLink = %@", url);
//
//                NSMutableDictionary *params = @{}.mutableCopy;
//                params[@"id"] = bookId;
//                [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"book" andParams:params]];
//                return YES;
//            }
//        }
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:url.absoluteString]];
        return YES;
    }
    
    return NO;
}

#pragma mark - 广告代理

- (void)splashAdApplicationWillEnterBackground:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}

-(void)splashAdSuccessPresentScreen:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}

-(void)splashAdFailToPresent:(GDTSplashAd *)splashAd withError:(NSError *)error
{
    NSLog(@"%s%@",__FUNCTION__,error);
    self.splash = nil;
}

- (void)splashAdWillClosed:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}
-(void)splashAdClosed:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
    self.splash = nil;
}

- (void)splashAdWillPresentFullScreenModal:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)splashAdDidPresentFullScreenModal:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)splashAdExposured:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)splashAdClicked:(GDTSplashAd *)splashAd
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"source"] = @"GDT";
    [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"SplashClickEvent" extra:params];
    NSLog(@"%s",__FUNCTION__);
}

- (void)splashAdWillDismissFullScreenModal:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)splashAdDidDismissFullScreenModal:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}
@end
