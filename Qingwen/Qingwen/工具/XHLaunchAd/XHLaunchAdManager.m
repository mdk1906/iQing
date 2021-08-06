//
//  XHLaunchAdManager.m
//  XHLaunchAdExample
//
//  Created by zhuxiaohui on 2017/5/3.
//  Copyright © 2017年 it7090.com. All rights reserved.
//  代码地址:https://github.com/CoderZhuXH/XHLaunchAd
//  开屏广告初始化

#import "XHLaunchAdManager.h"
#import "XHLaunchAd.h"
#import "WebViewController.h"
#import "QWBaseVC.h"
#import <YumiMediationSDK/YumiAdsSplash.h>
#import "GDTMobSDK/GDTSplashAd.h"

@interface XHLaunchAdManager()<XHLaunchAdDelegate,GDTSplashAdDelegate>
@property (strong, nonatomic) GDTSplashAd *splash;
@end

@implementation XHLaunchAdManager

+(void)load{
    [self shareManager];
}

+(XHLaunchAdManager *)shareManager{
    static XHLaunchAdManager *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken,^{
        instance = [[XHLaunchAdManager alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        //在UIApplicationDidFinishLaunching时初始化开屏广告,做到对业务层无干扰,当然你也可以直接在AppDelegate didFinishLaunchingWithOptions方法中初始化
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            //            //初始化开屏广告
            [self setupXHLaunchAd];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:@"XHLaunchAdWaitDataDurationArriveNotification" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            //            //初始化开屏广告
            XHLaunchImageAdConfiguration *imageAdconfiguration = [XHLaunchImageAdConfiguration new];
            imageAdconfiguration.duration = 3;
            imageAdconfiguration.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-[UIScreen mainScreen].bounds.size.width*0.572)/2, [UIScreen mainScreen].bounds.size.height*0.1, [UIScreen mainScreen].bounds.size.width*0.572, [UIScreen mainScreen].bounds.size.height*0.573);
            imageAdconfiguration.imageNameOrURLString = @"轻文娘秋季人设Q版.png";
            imageAdconfiguration.contentMode = UIViewContentModeScaleAspectFit;
            //广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
            //            imageAdconfiguration.openModel = data[@"link"];
            imageAdconfiguration.imageOption = XHLaunchAdImageOnlyLoad;
            //广告显示完成动画
            imageAdconfiguration.showFinishAnimate =ShowFinishAnimateLite;
            //广告显示完成动画时间
            imageAdconfiguration.showFinishAnimateTime = 0.8;
            //跳过按钮类型
            imageAdconfiguration.skipButtonType = SkipTypeTimeText;
            //后台返回时,是否显示广告
            imageAdconfiguration.showEnterForeground = NO;
            [XHLaunchAd imageAdWithImageAdConfiguration:imageAdconfiguration delegate:self];
        }];
    }
    return self;
}

-(void)setupXHLaunchAd{
    
    /** 1.图片开屏广告 - 网络数据 */
    [self example01];
    
}

#pragma mark - 图片开屏广告-网络数据-示例
//图片开屏广告 - 网络数据
-(void)example01{
    
    
    [QWGlobalValue sharedInstance].brand_ad = @"https://image.iqing.com/recommend/a409de81-53eb-4d8d-a567-53fa5286bd79.jpg?imageMogr2/thumbnail/x120";
    [QWGlobalValue sharedInstance].brand_adInc = @"1";
    [[QWGlobalValue sharedInstance] globalDicSave];

    //设置你工程的启动页使用的是:LaunchImage 还是 LaunchScreen.storyboard(不设置默认:LaunchImage)
    [XHLaunchAd setLaunchSourceType:SourceTypeLaunchImage];
    
    //1.因为数据请求是异步的,请在数据请求前,调用下面方法配置数据等待时间.
    //2.设为3即表示:启动页将停留3s等待服务器返回广告数据,3s内等到广告数据,将正常显示广告,否则将不显示
    //3.数据获取成功,配置广告数据后,自动结束等待,显示广告
    //注意:请求广告数据前,必须设置此属性,否则会先进入window的的根控制器
    [XHLaunchAd setWaitDataDuration:0.5];
    
    NSDictionary *dict = @{@"work":@(0),
                           @"register":@(0),
                           @"hot_discuss":@(0),
                           @"home":@(0),
                           @"square":@(0),
                           };
    [QWGlobalValue sharedInstance].systemSwitchesDic = dict;
    [[QWGlobalValue sharedInstance] save];
    NSLog(@"systemSwitchesDic = %@",[QWGlobalValue sharedInstance].systemSwitchesDic);
    
    //查询广告是否打开设置
//    ad_type : 0 SDK广告
//    1 自定义广告
//    2 关闭广告
    NSMutableDictionary *adSwitchparam = [NSMutableDictionary new];
    adSwitchparam[@"token"] = [QWGlobalValue sharedInstance].token;
    adSwitchparam[@"device_id"] = [QWGlobalValue sharedInstance].deviceToken;
    QWOperationParam *adSwitchpm = [QWInterface postWithUrl:[NSString stringWithFormat:@"%@/ad/switch/",[QWOperationParam currentDomain]] params:adSwitchparam andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (aResponseObject != nil) {
            
            NSDictionary *dictdata = aResponseObject;
            
            if ([dictdata[@"code"] intValue] == 0) {
                NSDictionary *dict = dictdata[@"data"];
                NSDictionary *checkin_ad = dict[@"checkin_ad"];
                NSDictionary *favorite_ad = dict[@"favorite_ad"];
                NSDictionary *read_ad = dict[@"read_ad"];
                NSDictionary *splash_ad = dict[@"splash_ad"];
                NSDictionary *square_ad = dict[@"square_ad"];
                NSDictionary *active_ad = dict[@"active_ad"];
                NSDictionary *brand_ad = dict[@"brand_ad"];
                NSDictionary *download_ad = dict[@"download_ad"];
                NSDictionary *topic_ad = dict[@"topic_ad"];
                NSDictionary *upper_ad = dict[@"upper_ad"];
                NSDictionary *index_ad = dict[@"index_ad"];
                [QWGlobalValue sharedInstance].checkin_ad = [checkin_ad[@"ad_type"] stringValue];
                [QWGlobalValue sharedInstance].favorite_ad = [favorite_ad[@"ad_type"] stringValue];
                [QWGlobalValue sharedInstance].read_ad = [read_ad[@"ad_type"] stringValue];
                [QWGlobalValue sharedInstance].splash_ad = [splash_ad[@"ad_type"] stringValue];
                [QWGlobalValue sharedInstance].square_ad = [square_ad[@"ad_type"] stringValue];
                [QWGlobalValue sharedInstance].active_ad = [active_ad[@"ad_type"] stringValue];
                [QWGlobalValue sharedInstance].brand_ad = [brand_ad[@"ad_type"] stringValue];
                [QWGlobalValue sharedInstance].download_ad = [download_ad[@"ad_type"] stringValue];
                [QWGlobalValue sharedInstance].topic_ad = [topic_ad[@"ad_type"] stringValue];
                [QWGlobalValue sharedInstance].upper_ad = [upper_ad[@"ad_type"] stringValue];
                [QWGlobalValue sharedInstance].index_ad = [index_ad[@"ad_type"] stringValue];
                
                
                [QWGlobalValue sharedInstance].checkin_adInc = checkin_ad[@"ad_image"];
                [QWGlobalValue sharedInstance].favorite_adInc = favorite_ad[@"ad_image"];
                [QWGlobalValue sharedInstance].read_adInc = read_ad[@"ad_image"];
                [QWGlobalValue sharedInstance].splash_adInc = splash_ad[@"ad_image"];
                [QWGlobalValue sharedInstance].square_adInc = square_ad[@"ad_image"];
                [QWGlobalValue sharedInstance].active_adInc = active_ad[@"ad_image"];
                [QWGlobalValue sharedInstance].brand_adInc = brand_ad[@"ad_image"];
                [QWGlobalValue sharedInstance].download_adInc = download_ad[@"ad_image"];
                [QWGlobalValue sharedInstance].topic_adInc = topic_ad[@"ad_image"];
                [QWGlobalValue sharedInstance].upper_adInc = upper_ad[@"ad_image"];
                [QWGlobalValue sharedInstance].index_adInc = index_ad[@"ad_image"];
                
                [QWGlobalValue sharedInstance].checkin_adURL = checkin_ad[@"ad_url"];
                [QWGlobalValue sharedInstance].favorite_adURL = favorite_ad[@"ad_url"];
                [QWGlobalValue sharedInstance].read_adURL = read_ad[@"ad_url"];
                [QWGlobalValue sharedInstance].splash_adURL = splash_ad[@"ad_url"];
                [QWGlobalValue sharedInstance].square_adURL = square_ad[@"ad_url"];
                [QWGlobalValue sharedInstance].active_adURL = active_ad[@"ad_url"];
                [QWGlobalValue sharedInstance].brand_adURL = brand_ad[@"ad_url"];
                [QWGlobalValue sharedInstance].download_adURL = download_ad[@"ad_url"];
                [QWGlobalValue sharedInstance].topic_adURL = topic_ad[@"ad_url"];
                [QWGlobalValue sharedInstance].upper_adURL = upper_ad[@"ad_url"];
                [QWGlobalValue sharedInstance].index_adURL = index_ad[@"ad_url"];
                
                [[QWGlobalValue sharedInstance] globalDicSave];
            }
            else{
                [QWGlobalValue sharedInstance].checkin_ad = @"2";
                [QWGlobalValue sharedInstance].favorite_ad = @"2";
                [QWGlobalValue sharedInstance].read_ad = @"2";
                [QWGlobalValue sharedInstance].splash_ad = @"2";
                [QWGlobalValue sharedInstance].square_ad = @"0";
                [QWGlobalValue sharedInstance].active_ad = @"2";
                [QWGlobalValue sharedInstance].brand_ad = @"2";
                [QWGlobalValue sharedInstance].download_ad = @"2";
                [QWGlobalValue sharedInstance].topic_ad = @"2";
                [QWGlobalValue sharedInstance].upper_ad = @"2";
                [QWGlobalValue sharedInstance].index_ad = @"2";
                
                
                [QWGlobalValue sharedInstance].checkin_adInc = @"https://image.iqing.com/recommend/a409de81-53eb-4d8d-a567-53fa5286bd79.jpg?imageMogr2/thumbnail/x120";
                [QWGlobalValue sharedInstance].favorite_adInc = @"https://image.iqing.com/recommend/a409de81-53eb-4d8d-a567-53fa5286bd79.jpg?imageMogr2/thumbnail/x120";
                [QWGlobalValue sharedInstance].read_adInc = @"https://image.iqing.com/recommend/a409de81-53eb-4d8d-a567-53fa5286bd79.jpg?imageMogr2/thumbnail/x120";
                [QWGlobalValue sharedInstance].splash_adInc = @"https://image.iqing.com/recommend/a409de81-53eb-4d8d-a567-53fa5286bd79.jpg?imageMogr2/thumbnail/x120";
                [QWGlobalValue sharedInstance].square_adInc = @"https://image.iqing.com/recommend/a409de81-53eb-4d8d-a567-53fa5286bd79.jpg?imageMogr2/thumbnail/x120";
                [QWGlobalValue sharedInstance].active_adInc = @"https://image.iqing.com/recommend/a409de81-53eb-4d8d-a567-53fa5286bd79.jpg?imageMogr2/thumbnail/x120";
                [QWGlobalValue sharedInstance].brand_adInc = @"https://image.iqing.com/recommend/a409de81-53eb-4d8d-a567-53fa5286bd79.jpg?imageMogr2/thumbnail/x120";
                [QWGlobalValue sharedInstance].download_adInc = @"https://image.iqing.com/recommend/a409de81-53eb-4d8d-a567-53fa5286bd79.jpg?imageMogr2/thumbnail/x120";
                [QWGlobalValue sharedInstance].topic_adInc = @"https://image.iqing.com/recommend/a409de81-53eb-4d8d-a567-53fa5286bd79.jpg?imageMogr2/thumbnail/x120";
                [QWGlobalValue sharedInstance].upper_adInc = @"https://image.iqing.com/recommend/a409de81-53eb-4d8d-a567-53fa5286bd79.jpg?imageMogr2/thumbnail/x120";
                [QWGlobalValue sharedInstance].index_adInc = @"https://image.iqing.com/recommend/a409de81-53eb-4d8d-a567-53fa5286bd79.jpg?imageMogr2/thumbnail/x120";
                
                [QWGlobalValue sharedInstance].checkin_adURL = @"www.iqing.com";
                [QWGlobalValue sharedInstance].favorite_adURL = @"www.iqing.com";
                [QWGlobalValue sharedInstance].read_adURL = @"www.iqing.com";
                [QWGlobalValue sharedInstance].splash_adURL = @"www.iqing.com";
                [QWGlobalValue sharedInstance].square_adURL = @"www.iqing.com";
                [QWGlobalValue sharedInstance].active_adURL = @"www.iqing.com";
                [QWGlobalValue sharedInstance].brand_adURL = @"www.iqing.com";
                [QWGlobalValue sharedInstance].download_adURL = @"www.iqing.com";
                [QWGlobalValue sharedInstance].topic_adURL = @"www.iqing.com";
                [QWGlobalValue sharedInstance].upper_adURL = @"www.iqing.com";
                [QWGlobalValue sharedInstance].index_adURL = @"www.iqing.com";
                
                [[QWGlobalValue sharedInstance] globalDicSave];
            }
        }
        else{
            [QWGlobalValue sharedInstance].checkin_ad = @"2";
            [QWGlobalValue sharedInstance].favorite_ad = @"2";
            [QWGlobalValue sharedInstance].read_ad = @"2";
            [QWGlobalValue sharedInstance].splash_ad = @"2";
            [QWGlobalValue sharedInstance].square_ad = @"2";
            [QWGlobalValue sharedInstance].active_ad = @"2";
            [QWGlobalValue sharedInstance].brand_ad = @"2";
            [QWGlobalValue sharedInstance].download_ad = @"2";
            [QWGlobalValue sharedInstance].topic_ad = @"2";
            [QWGlobalValue sharedInstance].upper_ad = @"2";
            [QWGlobalValue sharedInstance].index_ad = @"2";
            
            
            [QWGlobalValue sharedInstance].checkin_adInc = @"https://image.iqing.com/recommend/a409de81-53eb-4d8d-a567-53fa5286bd79.jpg?imageMogr2/thumbnail/x120";
            [QWGlobalValue sharedInstance].favorite_adInc = @"https://image.iqing.com/recommend/a409de81-53eb-4d8d-a567-53fa5286bd79.jpg?imageMogr2/thumbnail/x120";
            [QWGlobalValue sharedInstance].read_adInc = @"https://image.iqing.com/recommend/a409de81-53eb-4d8d-a567-53fa5286bd79.jpg?imageMogr2/thumbnail/x120";
            [QWGlobalValue sharedInstance].splash_adInc = @"https://image.iqing.com/recommend/a409de81-53eb-4d8d-a567-53fa5286bd79.jpg?imageMogr2/thumbnail/x120";
            [QWGlobalValue sharedInstance].square_adInc = @"https://image.iqing.com/recommend/a409de81-53eb-4d8d-a567-53fa5286bd79.jpg?imageMogr2/thumbnail/x120";
            [QWGlobalValue sharedInstance].active_adInc = @"https://image.iqing.com/recommend/a409de81-53eb-4d8d-a567-53fa5286bd79.jpg?imageMogr2/thumbnail/x120";
            [QWGlobalValue sharedInstance].brand_adInc = @"https://image.iqing.com/recommend/a409de81-53eb-4d8d-a567-53fa5286bd79.jpg?imageMogr2/thumbnail/x120";
            [QWGlobalValue sharedInstance].download_adInc = @"https://image.iqing.com/recommend/a409de81-53eb-4d8d-a567-53fa5286bd79.jpg?imageMogr2/thumbnail/x120";
            [QWGlobalValue sharedInstance].topic_adInc = @"https://image.iqing.com/recommend/a409de81-53eb-4d8d-a567-53fa5286bd79.jpg?imageMogr2/thumbnail/x120";
            [QWGlobalValue sharedInstance].upper_adInc = @"https://image.iqing.com/recommend/a409de81-53eb-4d8d-a567-53fa5286bd79.jpg?imageMogr2/thumbnail/x120";
            [QWGlobalValue sharedInstance].index_adInc = @"https://image.iqing.com/recommend/a409de81-53eb-4d8d-a567-53fa5286bd79.jpg?imageMogr2/thumbnail/x120";
            
            [QWGlobalValue sharedInstance].checkin_adURL = @"www.iqing.com";
            [QWGlobalValue sharedInstance].favorite_adURL = @"www.iqing.com";
            [QWGlobalValue sharedInstance].read_adURL = @"www.iqing.com";
            [QWGlobalValue sharedInstance].splash_adURL = @"www.iqing.com";
            [QWGlobalValue sharedInstance].square_adURL = @"www.iqing.com";
            [QWGlobalValue sharedInstance].active_adURL = @"www.iqing.com";
            [QWGlobalValue sharedInstance].brand_adURL = @"www.iqing.com";
            [QWGlobalValue sharedInstance].download_adURL = @"www.iqing.com";
            [QWGlobalValue sharedInstance].topic_adURL = @"www.iqing.com";
            [QWGlobalValue sharedInstance].upper_adURL = @"www.iqing.com";
            [QWGlobalValue sharedInstance].index_adURL = @"www.iqing.com";
            
            [[QWGlobalValue sharedInstance] globalDicSave];
        }
    }];
    adSwitchpm.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:adSwitchpm];
    
 
    
    
        //开屏数据请求
        QWOperationParam *pm = [QWInterface getWithDomainUrl:@"/config/splashscreen/?equipment=1" params:nil andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            NSLog(@"adInfo = %@",aResponseObject);
            //配置广告数据
            NSArray *results = aResponseObject[@"results"];
            if (results.count >0) {
                NSDictionary *data = results[0];
                
                XHLaunchImageAdConfiguration *imageAdconfiguration = [XHLaunchImageAdConfiguration new];
                imageAdconfiguration.duration = 3;
                imageAdconfiguration.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height *0.88);
                //            imageAdconfiguration.imageNameOrURLString = [QWConvertImageString convertPicURL:data[@"image"] imageSizeType:QWImageSizeTypeLaunchImgWebP];
                imageAdconfiguration.imageNameOrURLString = data[@"image"];
                //            NSLog(@"图片 = %@",[QWConvertImageString convertPicURL:data[@"image"] imageSizeType:QWImageSizeTypeLaunchImgWebP]);
                imageAdconfiguration.contentMode = UIViewContentModeScaleAspectFill;
                //广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
                imageAdconfiguration.openModel = data[@"link"];
                imageAdconfiguration.imageOption = XHLaunchAdImageOnlyLoad;
                //广告显示完成动画
                imageAdconfiguration.showFinishAnimate =ShowFinishAnimateLite;
                //广告显示完成动画时间
                imageAdconfiguration.showFinishAnimateTime = 0.8;
                //跳过按钮类型
                imageAdconfiguration.skipButtonType = SkipTypeTimeText;
                //后台返回时,是否显示广告
                imageAdconfiguration.showEnterForeground = NO;
                [XHLaunchAd imageAdWithImageAdConfiguration:imageAdconfiguration delegate:self];
                
                
            }
            else{
                XHLaunchImageAdConfiguration *imageAdconfiguration = [XHLaunchImageAdConfiguration new];
                imageAdconfiguration.duration = 3;
                imageAdconfiguration.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-[UIScreen mainScreen].bounds.size.width*0.572)/2, [UIScreen mainScreen].bounds.size.height*0.1, [UIScreen mainScreen].bounds.size.width*0.572, [UIScreen mainScreen].bounds.size.height*0.573);
                imageAdconfiguration.imageNameOrURLString = @"轻文娘秋季人设Q版.png";
                imageAdconfiguration.contentMode = UIViewContentModeScaleAspectFit;
                //广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
                //            imageAdconfiguration.openModel = data[@"link"];
                imageAdconfiguration.imageOption = XHLaunchAdImageOnlyLoad;
                //广告显示完成动画
                imageAdconfiguration.showFinishAnimate =ShowFinishAnimateLite;
                //广告显示完成动画时间
                imageAdconfiguration.showFinishAnimateTime = 0.8;
                //跳过按钮类型
                imageAdconfiguration.skipButtonType = SkipTypeTimeText;
                //后台返回时,是否显示广告
                imageAdconfiguration.showEnterForeground = NO;
                [XHLaunchAd imageAdWithImageAdConfiguration:imageAdconfiguration delegate:self];
            }
            
        } ];
        pm.requestType = QWRequestTypeGet;
        [self.operationManager requestWithParam:pm];
    
    
    
    QWOperationParam *pm2 = [QWInterface getWithDomainUrl:@"config/behavior_config/?app_id=82313&app_key=817b60e4aa6511e895db0242ac151a05" params:nil andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        NSLog(@"behaivor_config = %@",aResponseObject);
        //配置数据统计配置
        NSArray *data = aResponseObject[@"data"];
        if ([aResponseObject[@"code"]isEqualToString:@"200"]) {
            if (data.count>0) {
                NSDictionary *dic = data[0];
                
            }
            else{
                
            }
        }
        else{
            
        }
        
    } ];
    pm2.requestType = QWRequestTypeGet;
    [self.operationManager requestWithParam:pm2];
}


#pragma mark - 自定义跳过按钮-示例


#pragma mark - 使用默认配置快速初始化 - 示例


#pragma mark - subViews
-(NSArray<UIView *> *)launchAdSubViews_alreadyView{
    
    CGFloat y = XH_IPHONEX ? 46:22;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-140, y, 60, 30)];
    label.text  = @"已预载";
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = 5.0;
    label.layer.masksToBounds = YES;
    label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    return [NSArray arrayWithObject:label];
    
}

-(NSArray<UIView *> *)launchAdSubViews{
    
    CGFloat y = XH_IPHONEX ? 54 : 30;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-170, y, 60, 30)];
    label.text  = @"subViews";
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = 5.0;
    label.layer.masksToBounds = YES;
    label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    return [NSArray arrayWithObject:label];
    
}

#pragma mark - customSkipView
//自定义跳过按钮
-(UIView *)customSkipView{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor =[UIColor orangeColor];
    button.layer.cornerRadius = 5.0;
    button.layer.borderWidth = 1.5;
    button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    CGFloat y = XH_IPHONEX ? 54 : 30;
    button.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-100,y, 80, 38);
    [button addTarget:self action:@selector(skipAction) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

//跳过按钮点击事件
-(void)skipAction{
    
    //移除广告
    [XHLaunchAd removeAndAnimated:YES];
}

#pragma mark - XHLaunchAd delegate - 倒计时回调
/**
 *  倒计时回调
 *
 *  @param launchAd XHLaunchAd
 *  @param duration 倒计时时间
 */
-(void)xhLaunchAd:(XHLaunchAd *)launchAd customSkipView:(UIView *)customSkipView duration:(NSInteger)duration{
    //设置自定义跳过按钮时间
    UIButton *button = (UIButton *)customSkipView;//此处转换为你之前的类型
    //设置时间
    [button setTitle:[NSString stringWithFormat:@"自定义%lds",duration] forState:UIControlStateNormal];
}

#pragma mark - XHLaunchAd delegate - 其他
/**
 广告点击事件回调
 */
-(void)xhLaunchAd:(XHLaunchAd *)launchAd clickAndOpenModel:(id)openModel clickPoint:(CGPoint)clickPoint{
    
    NSLog(@"广告点击事件");
    
    /** openModel即配置广告数据设置的点击广告时打开页面参数(configuration.openModel) */
    if(openModel==nil) return;
    NSString *urlString = (NSString *)openModel;
    //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    //
    NSURL *reqest = [NSURL URLWithString:urlString];
    NSURL *url = reqest;
    NSLog(@"webview = %@",url.absoluteString);
    
    self.itemVO = [DiscussItemVO new];
    _itemVO.content = urlString;
    NSArray *routerArray = [self getRouterArrayFormItem:self.itemVO];
    [routerArray enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (!obj) {
            return;
        }
        NSString *router = [obj objectForKey:@"value"];
        NSLog(@"roter123 = %@",router);
        NSString *key = [obj objectForKey:@"key"];
        NSLog(@"key123 = %@",key);
        if (router.length == 0 || router == nil || key.length == 0 || obj == nil) {
            return;
        }
        [[QWRouter sharedInstance] routerWithUrlString:router];
    }];
    
}

/**
 *  图片本地读取/或下载完成回调
 *
 *  @param launchAd  XHLaunchAd
 *  @param image 读取/下载的image
 *  @param imageData 读取/下载的imageData
 */
-(void)xhLaunchAd:(XHLaunchAd *)launchAd imageDownLoadFinish:(UIImage *)image imageData:(NSData *)imageData{
    
    NSLog(@"图片下载完成/或本地图片读取完成回调");
}

/**
 *  视频本地读取/或下载完成回调
 *
 *  @param launchAd XHLaunchAd
 *  @param pathURL  视频保存在本地的path
 */
-(void)xhLaunchAd:(XHLaunchAd *)launchAd videoDownLoadFinish:(NSURL *)pathURL{
    
    NSLog(@"video下载/加载完成 path = %@",pathURL.absoluteString);
}

/**
 *  视频下载进度回调
 */
-(void)xhLaunchAd:(XHLaunchAd *)launchAd videoDownLoadProgress:(float)progress total:(unsigned long long)total current:(unsigned long long)current{
    
    NSLog(@"总大小=%lld,已下载大小=%lld,下载进度=%f",total,current,progress);
}

/**
 *  广告显示完成
 */
-(void)xhLaunchAdShowFinish:(XHLaunchAd *)launchAd{
    
    NSLog(@"广告显示完成");
}
- (NSArray *)getRouterArrayFormItem:(DiscussItemVO *)itemVO {
    if (itemVO.content.length == 0) {
        return NULL;
    }
    NSMutableArray *routerArray = @[].mutableCopy;
    
    {
        WEAK_SELF;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"《([^《》]{1,})》" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray<NSTextCheckingResult *> *result = [regex matchesInString:itemVO.content options:0 range:NSMakeRange(0, itemVO.content.length)];
        [result enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            STRONG_SELF;
            NSMutableDictionary *params = @{}.mutableCopy;
            params[@"book_name"] = [itemVO.content substringWithRange:obj.range];
            NSString *routerValue = [NSString getRouterVCUrlStringFromUrlString:@"search" andParams:params];
            
            NSMutableDictionary *router = @{}.mutableCopy;
            
            router[@"key"] = [itemVO.content substringWithRange:obj.range];
            router[@"value"] = routerValue;
            [routerArray addObject:router];
        }];
    }
    
    {
        WEAK_SELF;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@([^@《》\\[\\] ]{1,})( |$)" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray<NSTextCheckingResult *> *result = [regex matchesInString:itemVO.content options:0 range:NSMakeRange(0, itemVO.content.length)];
        [result enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            STRONG_SELF;
            NSMutableDictionary *params = @{}.mutableCopy;
            NSString *username = [itemVO.content substringWithRange:obj.range];
            username = [username substringWithRange:NSMakeRange(1, username.length - 1)];
            username = [username stringByReplacingOccurrencesOfString:@" " withString:@""];
            params[@"username"] = username;
            NSString *routerValue = [NSString getRouterVCUrlStringFromUrlString:@"user" andParams:params];
            
            NSMutableDictionary *router = @{}.mutableCopy;
            router[@"key"] = username;
            router[@"value"] = routerValue;
            [routerArray addObject:router];
        }];
    }
    
    {
        WEAK_SELF;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray<NSTextCheckingResult *> *result = [regex matchesInString:itemVO.content options:0 range:NSMakeRange(0, itemVO.content.length)];
        [result enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            STRONG_SELF;
            NSMutableDictionary *params = @{}.mutableCopy;
            NSString *url = [itemVO.content substringWithRange:obj.range];
            params[@"url"] = url;
            
            NSMutableDictionary *router = @{}.mutableCopy;
            router[@"key"] = url;
            router[@"value"] = [NSString getRouterVCUrlStringFromUrlString:url];
            [routerArray addObject:router];
        }];
    }
    
    return routerArray;
}
/**
 如果你想用SDWebImage等框架加载网络广告图片,请实现此代理(注意:实现此方法后,图片缓存将不受XHLaunchAd管理)
 
 @param launchAd          XHLaunchAd
 @param launchAdImageView launchAdImageView
 @param url               图片url
 */
//-(void)xhLaunchAd:(XHLaunchAd *)launchAd launchAdImageView:(UIImageView *)launchAdImageView URL:(NSURL *)url
//{
//    [launchAdImageView sd_setImageWithURL:url];
//
//}

@end
