//
//  QWbannerAdView.m
//  Qingwen
//
//  Created by qingwen on 2019/2/20.
//  Copyright © 2019 iQing. All rights reserved.
//

#import "QWbannerAdView.h"
#import <YumiMediationSDK/YumiMediationBannerView.h>
@interface QWbannerAdView () <YumiMediationBannerViewDelegate>

@property (nonatomic,strong) YumiMediationBannerView *yumiBanner;

@end
@implementation QWbannerAdView

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
        
        [self setupView];
    }
    return self;
}

-(void)setupView{
    _yumiBanner = [[YumiMediationBannerView alloc]
                       initWithPlacementID:QWBannerAdKey
                       channelID:@""
                       versionID:@""
                       position:YumiMediationBannerPositionTop
                       rootViewController:[self getTopVC]];
    _yumiBanner.delegate = self;
//    self.yumiBanner.bannerSize = kYumiMediationAdViewBanner300x250;
    [_yumiBanner loadAd:YES];
    [self addSubview:_yumiBanner];
    
//    UIView *view = [UIView new];
//    view.frame = CGRectMake(0, 60, UISCREEN_WIDTH, 20);
//    view.backgroundColor = [UIColor whiteColor];
//    [self addSubview:view];
//    
//    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, UISCREEN_WIDTH-20, 20)];
//    titleLab.textColor = HRGB(0x9a9696);
//    titleLab.textAlignment = 2;
//    titleLab.font = [UIFont systemFontOfSize:12];
//    titleLab.text = @"广告";
//    [view addSubview:titleLab];
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
- (void)yumiMediationBannerViewDidLoad:(YumiMediationBannerView *)adView{
    NSLog(@"adViewDidReceiveAd");
}
- (void)yumiMediationBannerView:(YumiMediationBannerView *)adView didFailWithError:(YumiMediationError *)error{
    NSLog(@"adView:didFailToReceiveAdWithError: %@", error);
}
- (void)yumiMediationBannerViewDidClick:(YumiMediationBannerView *)adView{
    NSLog(@"adViewDidClick");
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"FavoriteEvent" extra:params];
    
}
@end
