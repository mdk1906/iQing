//
//  QWRouter.m
//  OneStoreFramework
//
//  Created by Aimy on 14-6-23.
//  Copyright (c) 2014年 OneStore. All rights reserved.
//

#import "QWRouter.h"

#import "AppDelegate.h"
#import "NSString+plus.h"
#import "NSString+router.h"
#import "NSDictionary+router.h"
#import "UIViewController+create.h"

NSString const* QWScheme = @"iqing";
NSString const* QWFuncScheme = @"iqingfun";

NSString const* QWRouterCallbackKey = @"routercallback";
NSString const* QWRouterParamKey = @"body";

NSString const* QWRouterFromHostKey = @"QWRouterFromHostKey";
NSString const* QWRouterFromSchemeKey = @"QWRouterFromSchemeKey";

NSString const* QWHost = @"www.iqing.in";
NSString const* QWMHost = @"www.m.iqing.com";
@interface QWRouter ()

@property (nonatomic, strong) NSMutableDictionary *mapping;
@property (nonatomic, strong) NSMutableDictionary *nativeFuncMapping;
@property (nonatomic, strong) UIViewController *rootVC;
@property (nonatomic, strong) QWOperationManager *operationManager;
@property (nonatomic, strong) QWBestLogic *logic;
@property (nonatomic, strong) QWMyCenterLogic *centerLogic;
@property (nonatomic, strong) UIAlertController *visitorLogin;
@end

@implementation QWRouter

DEF_SINGLETON(QWRouter);

- (QWMyCenterLogic *)centerLogic
{
    if (!_centerLogic) {
        _centerLogic = [QWMyCenterLogic logicWithOperationManager:self.operationManager];
    }
    
    return _centerLogic;
}

- (UIAlertController *)visitorLogin
{
    if (!_visitorLogin) {
        _visitorLogin = [UIAlertController alertControllerWithTitle:@"登录" message:@"登录轻文可以有更多功能可以体验哦" preferredStyle:UIAlertControllerStyleAlert];
        [self configVisitorLogin];
        
    }
    
    return _visitorLogin;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.mapping = [NSMutableDictionary dictionary];
        self.nativeFuncMapping = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)configVisitorLogin{
    //__weak typeof(_visitorLogin) weakAlert = self.visitorLogin;
    UIAlertAction *loginQW = [UIAlertAction actionWithTitle:@"登录轻文账户" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"login" andParams:nil]];
    }];
    
    UIAlertAction *loginVistor = [UIAlertAction actionWithTitle:@"游客访问" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.rootVC showLoading];
        [self.centerLogic loginByVistor:^(id aResponseObject, NSError *anError) {
            WEAK_SELF;
            [self.rootVC hideLoading];
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
                    [QWGlobalValue sharedInstance].token = aResponseObject[@"token"];
                    [QWGlobalValue sharedInstance].username = aResponseObject[@"username"];
                    [QWGlobalValue sharedInstance].nid = aResponseObject[@"id"];
                    [QWGlobalValue sharedInstance].profile_url = aResponseObject[@"profile_url"];
                    UserVO *user = [UserVO voWithDict:aResponseObject];
                    [QWGlobalValue sharedInstance].user = user;
                    [QWGlobalValue sharedInstance].channel_token = aResponseObject[@"channel_token"];
                    [[QWGlobalValue sharedInstance] save];
                    
                    [[QWBindingValue sharedInstance] update];
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_STATE_CHANGED object:nil];
//                    [QWKeychain setKeychainValue:self.phoneTF.text forType:@"phone"];
//                    [QWKeychain setKeychainValue:self.stateLabel.text forType:@"state"];
                    
                }
            }
            else {
                [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
            }
            
            

        }];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [self.visitorLogin addAction:loginQW];
    [self.visitorLogin addAction:loginVistor];
    [self.visitorLogin addAction:cancel];
    
}

- (void)registerRouterVO:(QWMappingVO *)aVO withKey:(NSString *)aKeyName
{
    aKeyName = [aKeyName lowercaseString];
    if (self.mapping[aKeyName]) {
        NSLog(@"overwrite router vo key[%@], mapping vo,%@", aKeyName, self.mapping[aKeyName]);
    }
    self.mapping[aKeyName] = aVO;
}

- (void)registerNativeFuncVO:(QWNativeFuncVO *)aVO withKey:(NSString *)aKeyName
{
    aKeyName = [aKeyName lowercaseString];
    if (self.nativeFuncMapping[aKeyName]) {
        NSLog(@"overwrite native func vo key[%@], mapping vo,%@", aKeyName, self.nativeFuncMapping[aKeyName]);
    }
    self.nativeFuncMapping[aKeyName] = aVO;
}

- (void)registerRootVC:(UIViewController *)aRootVC
{
    if (self.rootVC) {
        NSLog(@"已经设置了rootvc，不能重复设置");
        return ;
    }
    self.rootVC = aRootVC;

    WEAK_SELF;
    [self performInThreadBlock:^{
        STRONG_SELF;
        [self registMapping];
    }];
}

- (id __nullable)routerWithUrlString:(NSString *)aUrlString
{
    return [self routerWithUrlString:aUrlString callbackBlock:nil];
}

- (id __nullable)routerWithUrlString:(NSString *)aUrlString callbackBlock:(QWNativeFuncVOBlock)aBlock
{
    NSLog(@"aUrlString = %@",aUrlString.urlDecoding);
    return [self routerWithUrl:[NSURL URLWithString:aUrlString.urlDecoding.urlEncoding] callbackBlock:aBlock];
}

- (id __nullable)routerWithUrl:(NSURL *)aUrl
{
    return [self routerWithUrl:aUrl callbackBlock:nil];
}

- (id __nullable)routerWithUrl:(NSURL *)aUrl callbackBlock:(QWNativeFuncVOBlock __nullable)aBlock
{
    if (!aUrl) {
        NSLog(@"router error url");
        return nil;
    }
    
    NSString *scheme = aUrl.scheme;
    NSString *host = [aUrl.host lowercaseString];
    NSString *query = aUrl.query;
    BOOL handle = NO;
    
    NSArray *vcs = [self routerInReservedField:aUrl callback:aBlock andHandled:&handle];
    if (handle) {
        return vcs;
    }
    
    NSMutableDictionary *params = ((NSDictionary *)([NSString getDictFromJsonString:query][QWRouterParamKey])).mutableCopy;
    params[QWRouterFromHostKey] = host;
    params[QWRouterFromSchemeKey] = scheme;
    if (aBlock) {
        params[QWRouterCallbackKey] = aBlock;
    }

    if ([QWScheme isEqualToString:scheme]) {
        if ([self.mapping objectForCaseInsensitiveKey:host]) {
            QWMappingVO *mappingVO = [self.mapping objectForCaseInsensitiveKey:host];
            return [self routerVCWithMappingVO:mappingVO params:params];
        }
        else if ([self.nativeFuncMapping objectForCaseInsensitiveKey:host]) {
            QWNativeFuncVO *nativeFuncVO = [self.nativeFuncMapping objectForCaseInsensitiveKey:host];
            return [self routerNativeFuncWithVO:nativeFuncVO params:params];

        }
        else {
            NSLog(@"没有这个VO, %@",aUrl.absoluteString.urlDecoding);
            return nil;
        }
    }
    else if ([QWFuncScheme isEqualToString:scheme]) {
        QWNativeFuncVO *nativeFuncVO = [self.nativeFuncMapping objectForCaseInsensitiveKey:host];
        
        if (!nativeFuncVO) {
            NSLog(@"没有这个QWNativeFuncVO, %@",aUrl.absoluteString.urlDecoding);
            return nil;
        }
        
        return [self routerNativeFuncWithVO:nativeFuncVO params:params];
    }
    else {
        NSLog(@"is not a router url,%@", aUrl.absoluteString.urlDecoding);
        return nil;
    }
}

- (id)routerNativeFuncWithVO:(QWNativeFuncVO *)aVO params:(NSDictionary *)aParams
{
    if (aVO.needLogin && ![QWGlobalValue sharedInstance].isLogin) {
        [self routerToLogin];
        return [NSNull null];
    }
    
    if (aVO.block) {
        return aVO.block(aParams);
    }
    else {
        return nil;
    }
}

- (id)routerVCWithMappingVO:(QWMappingVO *)aVO params:(NSDictionary *)aParams
{
    if (aVO.needLogin && ! [QWGlobalValue sharedInstance].isLogin) {
        [self routerToLogin];
        return [NSNull null];
    }

    if ([aParams[QWRouterFromHostKey] isEqualToString:@"web"]) {
        if ([self getCookiesWithUrl:aParams[@"url"] mapptingVO:aVO params:aParams]) {
            return [NSNull null];
        }
    }
    
    if ([aParams[QWRouterFromHostKey] isEqualToString:@"main"]) {//返回首页
        [self.topVC.navigationController popToRootViewControllerAnimated:YES];
        self.topVC.navigationController.tabBarController.selectedIndex = 1;
        self.topVC.hidesBottomBarWhenPushed = false;
        return [NSNull null];
    }
    
    UIViewController *vc = [UIViewController createWithMappingVO:aVO extraData:aParams];
    if (!vc) {
        NSLog(@"router error %@, can not new one",aVO);
        return nil;
    }
    
    if (aVO.model) {
        if (aVO.modalPresentationStyle) {
            vc.modalPresentationStyle = aVO.modalPresentationStyle;
            [[self topVC].navigationController presentViewController:vc animated:NO completion:nil];
        }
        else {
            [[self topVC].navigationController presentViewController:vc animated:YES completion:nil];
        }
    }
    else {
        if ( ! [vc isKindOfClass:[UINavigationController class]]) {
            [[self topVC].navigationController pushViewController:vc animated:YES];
        }
        else {
            NSLog(@"can not push an nc");
        }
    }
    
    return @[vc];
}

- (id)routerInReservedField:(NSURL *)aUrl callback:(QWNativeFuncVOBlock)aBlock andHandled:(BOOL *)handle
{
    *handle = YES;
    NSString *scheme = aUrl.scheme;
    NSString *host = [aUrl.host lowercaseString];
    NSString *query = aUrl.query;
    
    NSMutableDictionary *params = ((NSDictionary *)([NSString getDictFromJsonString:query][QWRouterParamKey])).mutableCopy;
    params[QWRouterFromHostKey] = host;
    params[QWRouterFromSchemeKey] = scheme;
    if (aBlock) {
        params[QWRouterCallbackKey] = aBlock;
    }

    if ([QWScheme isEqualToString:scheme]) {
        if ([host.lowercaseString isEqualToString:@"home"]) {
            return [self routerBackToRootAndChangTab:0 params:params];;
        }
        else if ([host.lowercaseString isEqualToString:@"feed"]) {
            return [self routerBackToRootAndChangTab:1 params:params];
        }
        else if ([host.lowercaseString isEqualToString:@"shelf"]) {
            return [self routerBackToRootAndChangTab:2 params:params];
        }
        else if ([host.lowercaseString isEqualToString:@"mycenter"]) {
            return [self routerBackToRootAndChangTab:3 params:params];
        }
    }
    else if ([QWFuncScheme isEqualToString:scheme]) {
        if ([host isEqualToString:@"back"]) {
            return [self routerBack:params];
        }
    }
    else {
        if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
            QWMappingVO *vo = self.mapping[@"web"];
            NSMutableDictionary *params = @{@"url": aUrl.absoluteString}.mutableCopy;
            params[QWRouterFromHostKey] = @"web";
            params[QWRouterFromSchemeKey] = QWScheme;
            if (aBlock) {
                params[QWRouterCallbackKey] = aBlock;
            }
            id res = [self routerVCWithMappingVO:vo params:params];
            if (res) {
                return res;
            }
        }
    }
    *handle = NO;
    
    return nil;
}

- (void)routerToLogin
{
    [self.rootVC showLoading];
    [self.centerLogic appWasPublished:^(id aResponseObject, NSError *anError) {
        WEAK_SELF;
        [weakSelf.rootVC hideLoading];
        NSNumber *status = nil;
        if(!anError){
            status = aResponseObject[@"status"];
            [QWGlobalValue sharedInstance].isPublished = status;
            [[QWGlobalValue sharedInstance] save];
        }
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"login" andParams:nil]];
        [self.rootVC presentViewController:self.visitorLogin animated:YES completion:nil];
//        if (status != nil && status.integerValue == 1) {
//            [self.rootVC presentViewController:self.visitorLogin animated:YES completion:nil];
//        }else{
//            [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"login" andParams:nil]];
//        }
    }];
}

- (NSArray *)routerBack
{
    return [self routerBack:nil];
}

- (NSArray *)routerBack:(NSDictionary *)aParams
{
    //暂时不解析参数
    if ([self.rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tbc = (id)self.rootVC;
        UIViewController *selectedVC = tbc.selectedViewController;
        if ([selectedVC isKindOfClass:[UINavigationController class]]) {
            UIViewController *vc = [(UINavigationController *)selectedVC popViewControllerAnimated:YES];
            if (vc) {
                return @[vc];
            }
            
            return nil;
        }
        else {
            NSLog(@"没有导航怎么pop?");
        }
    }
    else if ([self.rootVC isKindOfClass:[UINavigationController class]]) {
        UIViewController *vc = [(UINavigationController *)self.rootVC popViewControllerAnimated:YES];
        if (vc) {
            return @[vc];
        }
        
        return nil;
    }
    else {
        NSLog(@"没有导航怎么pop?");
    }
    
    return nil;
}

- (NSArray *)routerBackToRootAndChangTab:(NSUInteger)index params:(NSDictionary *)aParams
{
    NSArray *vcs = nil;
    if ([self.rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tbc = (id)self.rootVC;
        if (tbc.selectedIndex != index) {//如果不是同一个tab才需要切换
            tbc.selectedIndex = index;
        }

        if ([tbc.selectedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nc = (id)tbc.selectedViewController;
            if (nc.viewControllers.count > 1) {
                vcs = [nc popToRootViewControllerAnimated:YES];
            }
            [nc update];
        }
    }

    return vcs;
}

- (UIViewController *)topVC
{
    if ([self.rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tbc = (id)self.rootVC;
        UIViewController *selectedVC = tbc.selectedViewController;
        if ([selectedVC isKindOfClass:[UINavigationController class]]) {
            if (IOS_SDK_MORE_THAN(8.0) && [[(UINavigationController *)selectedVC visibleViewController] isKindOfClass:[UIAlertController class]]) {
                return [(UINavigationController *)selectedVC topViewController];
            }
            else {
                return [(UINavigationController *)selectedVC visibleViewController];
            }
        }
        else {
            NSLog(@"没有导航怎么pop?");
        }
    }
    else if ([self.rootVC isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)self.rootVC visibleViewController];
    }
    
    return nil;
}

- (void)enterHomepage
{
    NSLog(@"overwrite in child class");
}

- (BOOL)getCookiesWithUrl:(NSString *)url mapptingVO:(QWMappingVO *)aVO params:(NSDictionary *)aParams
{
    if (aParams[@"checked"]) {
        return NO;
    }

    [self.rootVC showLoading];
    [self.logic getPromotionCookiesWithUrl:url andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        [self.rootVC hideLoading];
        if (!anError && aResponseObject) {
            NSMutableDictionary *params = aParams.mutableCopy;
            params[@"checked"] = @1;
            if (aResponseObject[@"location"]) {
                params[@"url"] = aResponseObject[@"location"];
                [self routerVCWithMappingVO:aVO params:params];
            }
        }
        else {
            if ([anError.userInfo[NSLocalizedDescriptionKey] rangeOfString:@"401"].location != NSNotFound || [anError.userInfo[NSLocalizedDescriptionKey] rangeOfString:@"403"].location != NSNotFound) {
                [self routerToLogin];
            }

            [self showToastWithTitle:@"获取失败" subtitle:nil type:ToastTypeError];
        }
    }];

    return YES;
}

- (QWOperationManager *)operationManager
{
    if (!_operationManager) {
        _operationManager = [[QWNetworkManager sharedInstance] generateoperationManagerWithOwner:self];
    }

    return _operationManager;
}

- (QWBestLogic *)logic
{
    if (!_logic) {
        _logic = [QWBestLogic logicWithOperationManager:self.operationManager];
    }

    return _logic;
}

@end
