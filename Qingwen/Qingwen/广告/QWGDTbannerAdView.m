//
//  QWGDTbannerAdView.m
//  Qingwen
//
//  Created by qingwen on 2019/3/19.
//  Copyright © 2019 iQing. All rights reserved.
//

#import "QWGDTbannerAdView.h"
#import "GDTMobSDK/GDTMobBannerView.h"
@interface QWGDTbannerAdView () <GDTMobBannerViewDelegate>

 @property (nonatomic, strong) GDTMobBannerView *bannerView;

@end
@implementation QWGDTbannerAdView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self.bannerView removeFromSuperview];
        self.bannerView = nil;
        [self setupView];
    }
    return self;
}

-(void)setupView{
    CGRect rect = {CGPointMake((UISCREEN_WIDTH-320)/2, 5), GDTMOB_AD_SUGGEST_SIZE_320x50};
    _bannerView = [[GDTMobBannerView alloc] initWithFrame:rect appId:QWGDTAdKey placementId:QWGDTBannerAdKey];
    //设置当前的ViewController
    _bannerView.currentViewController = [self getTopVC];
    //设置广告轮播时间，范围为30-120秒，0表示不轮播
    _bannerView.interval = 30;
    //开启bnner轮播时的动画效果。默认开启。
//    _bannerView.isAnimationOn = self.animationSwitch.on;
    //展示关闭按钮，默认展示。
    _bannerView.showCloseBtn = NO;
    //开启GPS定位，默认关闭。
    _bannerView.isGpsOn = NO;
    //设置Delegate
    _bannerView.delegate = self;
    [self addSubview:_bannerView];
    [self.bannerView loadAdAndShow];
}

- (UIViewController *) getTopVC{
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (1) {
        //顶层控制器 可能是 UITabBarController的跟控制器
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        
        //顶层控制器 可能是 push出来的 或者是跟控制器
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        
        //顶层控制器 可能是 modal出来的
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    
    return vc;
}

#pragma mark - GDTMobBannerViewDelegate
// 请求广告条数据成功后调用
//
// 详解:当接收服务器返回的广告数据成功后调用该函数
- (void)bannerViewDidReceived
{
    NSLog(@"banner Received");
}

// 请求广告条数据失败后调用
//
// 详解:当接收服务器返回的广告数据失败后调用该函数
- (void)bannerViewFailToReceived:(NSError *)error
{
    NSLog(@"banner failed to Received : %@",error);
}

// 广告栏被点击后调用
//
// 详解:当接收到广告栏被点击事件后调用该函数
- (void)bannerViewClicked
{
    NSLog(@"banner clicked");
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"source"] = @"GDT";
    [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"IndexClickEvent" extra:params];
}

// 应用进入后台时调用
//
// 详解:当点击下载或者地图类型广告时，会调用系统程序打开，
// 应用将被自动切换到后台
- (void)bannerViewWillLeaveApplication
{
    NSLog(@"banner leave application");
}


-(void)bannerViewDidDismissFullScreenModal
{
    NSLog(@"%s",__FUNCTION__);
}

-(void)bannerViewWillDismissFullScreenModal
{
    NSLog(@"%s",__FUNCTION__);
}

-(void)bannerViewWillPresentFullScreenModal
{
    NSLog(@"%s",__FUNCTION__);
}

-(void)bannerViewDidPresentFullScreenModal
{
    NSLog(@"%s",__FUNCTION__);
}
@end
