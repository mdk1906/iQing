//
//  QWShareManager.m
//  Qingwen
//
//  Created by Aimy on 8/20/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWShareManager.h"

#import "QWShareView.h"

#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "WeiboSDK.h"
#import "QWUserDefaults.h"
#import "QWJsonKit.h"

@interface QWShareManager ()
<
WXApiDelegate,
WeiboSDKDelegate,
QQApiInterfaceDelegate,
TencentSessionDelegate
>

@property (nonatomic, strong) TencentOAuth *tencentOAuth;

@property (nonatomic, copy) NSDictionary *wbShareInfo;

@property (nonatomic, copy) NSString *wbToken;

@property (nonatomic, strong) NSMutableArray *permissionArray;

@property (assign) BOOL share;
@end

@implementation QWShareManager

+ (void)load
{
    QWNativeFuncVO *vo = [QWNativeFuncVO new];
    vo.block = [(id) ^(NSDictionary *params) {
        [[QWShareManager sharedInstance] showWithTitle:params[@"title"] image:params[@"image"] intro:params[@"intro"] url:params[@"url"] dataDic:params];
        return nil;
    } copy];
    
    [[QWRouter sharedInstance] registerNativeFuncVO:vo withKey:@"share"];
}

DEF_SINGLETON(QWShareManager);

- (instancetype)init
{
    self = [super init];
    
    [WeiboSDK registerApp:WeiboAppKey];
    [WXApi registerApp:WeixinAppKey];
    self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQAppKey andDelegate:(id)self];
    
    return self;
}

- (void)dealloc {
    NSLog(@"[%@ call %@]", [self class], NSStringFromSelector(_cmd));
}

+ (BOOL)handleOpenUrl:(nullable NSURL *)url sourceApplication:(nullable NSString *)sourceApplication
{
    if ([sourceApplication isEqualToString:@"com.tencent.xin"]) {
        return [WXApi handleOpenURL:url delegate:[QWShareManager sharedInstance]];
    }
    else if ([sourceApplication isEqualToString:@"com.tencent.mqq"] ||[sourceApplication isEqualToString:@"com.tencent.mipadqq"]) {
        [QQApiInterface handleOpenURL:url delegate:[QWShareManager sharedInstance]];
        return [TencentOAuth HandleOpenURL:url];
    }
    else if ([sourceApplication isEqualToString:@"com.sina.weibo"] ||[sourceApplication isEqualToString:@"com.sina.weibohd"]) {
        return [WeiboSDK handleOpenURL:url delegate:[QWShareManager sharedInstance]];
    }
    
    return NO;
}

- (void)showWithTitle:(NSString * __nullable)aTitle image:(NSString * __nullable)aImage intro:(NSString * __nullable)aIntro url:(NSString * __nullable)aUrl dataDic:(NSDictionary * __nullable)adataDic
{
    self.share = true;
    
    UITabBarController *tbc = (id)[[UIApplication sharedApplication].delegate window].rootViewController;
    QWShareView *shareView = [QWShareView createWithNib];
    [tbc.view addSubview:shareView];
    [shareView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:tbc.view];
    [shareView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:tbc.view];
    [shareView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:tbc.view];
    [shareView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:tbc.view];
    
    WEAK_SELF;
    [shareView showWithCompleteBlock:^(NSInteger selectedIndex) {
        STRONG_SELF;
        [self showWithTitle:aTitle image:aImage intro:aIntro url:aUrl selectedIndex:selectedIndex dataDic:adataDic];
    }];
}

- (void)showWithTitle:(NSString * __nullable)aTitle image:(NSString * __nullable)aImage intro:(NSString * __nullable)aIntro url:(NSString * __nullable)aUrl selectedIndex:(NSInteger)selectedIndex dataDic:(NSDictionary * __nullable)adataDic
{
#ifndef DEBUG
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"type"] = @(selectedIndex);
    if (aUrl.length) {
        params[@"url"] = aUrl;
    }
    [[BaiduMobStat defaultStat] logEvent:@"share" eventLabel:[QWJsonKit stringFromDict:params]];
#endif
    
    NSString *title = aTitle.copy;
    NSString *intro = aIntro.copy;
    NSString *imageUrl = aImage.copy;
    NSString *url = [aUrl.copy stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *text = [NSString stringWithFormat:@"《%@》#轻文轻小说#", title];
    
    if (selectedIndex == 0) {
        if ([QWUserDefaults sharedInstance][@"wbAttention"]) {
            WBMessageObject *message = [WBMessageObject message];
            WBImageObject *image = [WBImageObject object];
            image.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[QWConvertImageString convertPicURL:imageUrl imageSizeType:QWImageSizeTypeCover]]];
            message.imageObject = image;
            message.text = [text stringByAppendingFormat:@" %@", url];
            
            NSMutableDictionary *params = @{}.mutableCopy;
            params[@"title"] = aTitle;
            params[@"intro"] = aIntro;
            params[@"image"] = aImage;
            params[@"url"] = aUrl;
            self.wbShareInfo = params;
            
            WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
            authRequest.redirectURI = WeiboRedirectURI;
            authRequest.scope = @"all";
            
            WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:self.wbToken];
            [WeiboSDK sendRequest:request];
        }
        else {
            NSMutableDictionary *params = @{}.mutableCopy;
            params[@"title"] = aTitle;
            params[@"intro"] = aIntro;
            params[@"image"] = aImage;
            params[@"url"] = aUrl;
            self.wbShareInfo = params;
            
            WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
            authRequest.redirectURI = WeiboRedirectURI;
            authRequest.scope = @"all";
            [WeiboSDK sendRequest:authRequest];
        }
    }
    else if (selectedIndex == 1 || selectedIndex == 3) {
        if (![WXApi isWXAppInstalled]) {
            [self showToastWithTitle:@"无法使用微信分享" subtitle:nil type:ToastTypeError];
            return ;
        }
        
        if (![WXApi isWXAppSupportApi]) {
            [self showToastWithTitle:@"无法使用微信分享" subtitle:nil type:ToastTypeError];
            return ;
        }
        if (adataDic == nil) {
            //没有小程序分享功能
            WXMediaMessage *message = [WXMediaMessage message];
            message.title = title;
            NSString *tempIntro = intro;
            if (tempIntro.length > 1000) {
                tempIntro = [tempIntro substringToIndex:1000];
            }
            message.description = tempIntro;
            message.thumbData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[QWConvertImageString convertPicURL:imageUrl imageSizeType:QWImageSizeTypeShare]]];
            
            WXWebpageObject *ext = [WXWebpageObject object];
            ext.webpageUrl = url;
            message.mediaObject = ext;
            
            SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            if (selectedIndex == 1) {
                req.scene = WXSceneSession;
            }
            else {
                req.scene = WXSceneTimeline;
                
            }
            
            [WXApi sendReq:req];
        }
        else{
            //有小程序分享功能
            WXMiniProgramObject *object = [WXMiniProgramObject object];
            object.webpageUrl = url;
            object.userName = WeixinMINIID;
            object.path = [NSString stringWithFormat:@"pages/%@?id=%@",adataDic[@"type"],adataDic[@"workId"]];
            object.hdImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[QWConvertImageString convertPicURL:imageUrl imageSizeType:QWImageSizeTypeShare]]];
            object.withShareTicket = NO;
            object.miniProgramType = WXMiniProgramTypeRelease;
            
            WXMediaMessage *message = [WXMediaMessage message];
            message.title = title;
            message.description = intro;
            message.thumbData = nil;  //兼容旧版本节点的图片，小于32KB，新版本优先
            //使用WXMiniProgramObject的hdImageData属性
            message.mediaObject = object;

            SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            req.scene = WXSceneSession;  //目前只支持会话
            [WXApi sendReq:req];
            if (selectedIndex == 1) {
                req.scene = WXSceneSession;
            }
            else {
                //            req.scene = WXSceneTimeline;
                [self showToastWithTitle:@"小程序暂时不能分享至朋友圈" subtitle:nil type:ToastTypeError];
            }
            
            [WXApi sendReq:req];
        }
        
        
    }
    else if (selectedIndex == 2) {
        if (![QQApiInterface isQQInstalled]) {
            [self showToastWithTitle:@"无法使用QQ分享" subtitle:nil type:ToastTypeError];
            return;
        }
        
        if (![QQApiInterface isQQSupportApi]) {
            [self showToastWithTitle:@"无法使用QQ分享" subtitle:nil type:ToastTypeError];
            return;
        }
        
        QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:url]
                                                            title:title
                                                      description:intro
                                                  previewImageURL:[NSURL URLWithString:[QWConvertImageString convertPicURL:imageUrl imageSizeType:QWImageSizeTypeShare]]];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
        [QQApiInterface sendReq:req];
    }
}

- (void)sendMessageWithqq:(NSString * )qqNumber{
    self.share = false;
    QQApiWPAObject *wpaObj = [QQApiWPAObject objectWithUin:qqNumber];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:wpaObj];
    [QQApiInterface sendReq:req];
}

#pragma mark - weibo Delegate

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    NSLog(@"didReceiveWeiboRequest");
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    NSLog(@"didReceiveWeiboResponse");
    if ([response isKindOfClass:[WBSendMessageToWeiboResponse class]]) {
        WBSendMessageToWeiboResponse *res = (id)response;
        if (res.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            [self showToastWithTitle:@"分享成功" subtitle:nil type:ToastTypeAlert options:@{kCRToastTimeIntervalKey: @1}];
            [self shareTaskFinishd];
        }
        else if (res.statusCode == WeiboSDKResponseStatusCodeUserCancel) {
            [self showToastWithTitle:@"分享取消了" subtitle:nil type:ToastTypeAlert options:@{kCRToastTimeIntervalKey: @1}];
        }
        else {
            [self showToastWithTitle:@"分享失败" subtitle:nil type:ToastTypeAlert options:@{kCRToastTimeIntervalKey: @1}];
        }
    }
    else if ([response isKindOfClass:[WBAuthorizeResponse class]]) {
        WBAuthorizeResponse *res = (id)response;
        if (res.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            [QWUserDefaults sharedInstance][@"wbAttention"] = @1;
            self.wbToken = res.accessToken;
            
            if ([_wbLoginDelegate respondsToSelector:@selector(loginWBSuccessWithJsonResponse:)]) {
                [_wbLoginDelegate loginWBSuccessWithJsonResponse:response.userInfo];
                return;
            }
            WEAK_SELF;
            [self performInMainThreadBlock:^{
                STRONG_SELF;
                [self showWithTitle:self.wbShareInfo[@"title"] image:self.wbShareInfo[@"image"] intro:self.wbShareInfo[@"intro"] url:self.wbShareInfo[@"url"] selectedIndex:0 dataDic:nil];
            } afterSecond:.5f];
            
            [self showToastWithTitle:@"登录成功" subtitle:nil type:ToastTypeAlert options:@{kCRToastTimeIntervalKey: @1}];
        }
        else if (res.statusCode == WeiboSDKResponseStatusCodeUserCancel) {
            [self showToastWithTitle:@"登录取消了" subtitle:nil type:ToastTypeAlert options:@{kCRToastTimeIntervalKey: @1}];
        }
        else {
            [self showToastWithTitle:@"登录失败" subtitle:nil type:ToastTypeAlert options:@{kCRToastTimeIntervalKey: @1}];
        }
    }
}

#pragma mark - QQ || weixin delegate
-(void)onReq:(id)req
{
    NSLog(@"onReq");
}

- (void)onResp:(id)resp
{
    NSLog(@"onResp");
    if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        SendMessageToQQResp *qq = resp;
        if (!self.share) {
            return;
        }
        if ([qq.result isEqualToString:@"0"]) {
            [self showToastWithTitle:@"分享成功" subtitle:nil type:ToastTypeAlert options:@{kCRToastTimeIntervalKey: @1}];
            [self shareTaskFinishd];
        }
        else if ([qq.result isEqualToString:@"-4"]) {
            [self showToastWithTitle:@"分享取消了" subtitle:nil type:ToastTypeAlert options:@{kCRToastTimeIntervalKey: @1}];
        }
        else {
            [self showToastWithTitle:@"分享失败" subtitle:nil type:ToastTypeAlert options:@{kCRToastTimeIntervalKey: @1}];
        }
    }
    else if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        BaseResp *weixin = resp;
        if (weixin.errCode == WXSuccess) {
            [self showToastWithTitle:@"分享成功" subtitle:nil type:ToastTypeAlert options:@{kCRToastTimeIntervalKey: @1}];
            [self shareTaskFinishd];
        }
        else if (weixin.errCode == WXErrCodeUserCancel) {
            [self showToastWithTitle:@"分享取消了" subtitle:nil type:ToastTypeAlert options:@{kCRToastTimeIntervalKey: @1}];
        }
        else {
            [self showToastWithTitle:@"分享失败" subtitle:nil type:ToastTypeAlert options:@{kCRToastTimeIntervalKey: @1}];
        }
    }
    //登录成功
    else if ([resp isKindOfClass:[SendAuthResp class]]) {//微信
        SendAuthResp *weixin = resp;
        if (weixin.errCode == 0) { //成功
            if ([_wxLoginDelegate respondsToSelector:@selector(loginWXSuccessWithCode:)]) {
                [_wxLoginDelegate loginWXSuccessWithCode:weixin.code];
            }
        }else {
            [self showToastWithTitle:weixin.errStr subtitle:nil type:ToastTypeAlert options:@{kCRToastTimeIntervalKey: @1}];
        }
    }
}

/**
 处理QQ在线状态的回调
 */
- (void)isOnlineResponse:(NSDictionary *)response
{
    
}

//分享成功任务完成
-(void)shareTaskFinishd{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"webShareSuccessful" object:nil];
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"task_type"] = @"4";
    NSString *url = [NSString stringWithFormat:@"%@/task/task_finished/",[QWOperationParam currentDomain]];
    QWOperationParam *pm = [QWInterface postWithUrl:url params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        NSDictionary *dict = aResponseObject;
        if ([dict[@"code"] intValue] == 0) {
            [self showToastWithTitle:dict[@"msg"] subtitle:nil type:ToastTypeError];
        }
        else{
            
        }
    }];
    pm.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:pm];
}
#pragma mark - QQ登录 
- (void)qqLogin {
    if (_tencentOAuth) {
        
        _permissionArray = [NSMutableArray arrayWithObjects:kOPEN_PERMISSION_GET_INFO,kOPEN_PERMISSION_GET_USER_INFO,kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, nil];
        [_tencentOAuth authorize:_permissionArray inSafari:YES];
    } else {
        [self showToastWithTitle:@"QQ登录失败" subtitle:nil type:ToastTypeAlert options:@{kCRToastTimeIntervalKey: @1}];
    }
}

- (void)tencentDidLogin {
    if (_tencentOAuth.accessToken) {
        [_tencentOAuth getUserInfo];
    } else {
        NSLog(@"AccessToken获取失败");
        [self showToastWithTitle:@"QQ登录失败" subtitle:nil type:ToastTypeAlert options:@{kCRToastTimeIntervalKey: @1}];
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    if (cancelled) {
        [self showToastWithTitle:@"取消QQ登录" subtitle:nil type:ToastTypeAlert options:@{kCRToastTimeIntervalKey: @1}];
    } else {
        NSLog(@"其它原因，导致登录失败");
        [self showToastWithTitle:@"QQ登录失败" subtitle:nil type:ToastTypeAlert options:@{kCRToastTimeIntervalKey: @1}];
    }
}

- (void)tencentDidNotNetWork {
    [self showToastWithTitle:@"网络连接错误" subtitle:nil type:ToastTypeAlert options:@{kCRToastTimeIntervalKey: @1}];
}

- (void)getUserInfoResponse:(APIResponse *)response {
    if ([_qqLoginDelegate respondsToSelector:@selector(loginQQSuccessWithJsonResponse:)]) {
        NSMutableDictionary *dic = @{}.mutableCopy;
        [dic addEntriesFromDictionary:response.jsonResponse];
        dic[@"access_token"] = _tencentOAuth.accessToken;
        dic[@"expired_time"] = _tencentOAuth.expirationDate;
        dic[@"openid"] = _tencentOAuth.openId;
        [_qqLoginDelegate loginQQSuccessWithJsonResponse:dic];
    }
}

#pragma mark - 微信登录
- (void)wxLogin {
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        SendAuthReq *req = [[SendAuthReq alloc]init];
        req.scope = @"snsapi_userinfo";
        req.openID = WeixinAppKey;
        req.state = @"com.iqing.com";
        [WXApi sendReq:req];
    }
}

#pragma mark - 微博登录
- (void)wbLogin {
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = WeiboRedirectURI;
    authRequest.scope = @"all";
    [WeiboSDK sendRequest:authRequest];
}
@end
