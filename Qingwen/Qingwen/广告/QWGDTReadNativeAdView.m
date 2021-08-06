//
//  QWGDTReadNativeAdView.m
//  Qingwen
//
//  Created by qingwen on 2019/3/19.
//  Copyright © 2019 iQing. All rights reserved.
//

#import "QWGDTReadNativeAdView.h"
#import "GDTMobSDK/GDTNativeExpressAd.h"
#import "GDTMobSDK/GDTNativeExpressAdView.h"
@interface QWGDTReadNativeAdView () <GDTNativeExpressAdDelegete>
@property (nonatomic, strong) NSMutableArray *expressAdViews;

@property (nonatomic, strong) GDTNativeExpressAd *nativeExpressAd;
@property (nonatomic,strong) NSNumber *bookId;
@property (nonatomic,strong)NSNumber *chapterId;
@property (nonatomic,strong)NSNumber *free;//0是免费章节 1是付费章节
@property (nonatomic,strong)NSNumber *lastAd;//最后一页是否有广告 0广点通广告 1自定义广告 2关闭广告
@end

@implementation QWGDTReadNativeAdView

-(instancetype)initWithFrame:(CGRect)frame withBook:(NSNumber*)bookId withChapter:(NSNumber*)chapter{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupView];
        self.bookId = bookId;
        self.chapterId = chapter;
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupView];
        
    }
    return self;
}
-(void)getBookId:(NSNumber *)bookId getChapterId:(NSNumber *)chapter getFree:(NSNumber *)free getLastAd:(NSNumber *)lastAd{
    self.bookId = bookId;
    self.chapterId = chapter;
    self.free =free;
    self.lastAd = lastAd;
}
-(void)setupView{
    self.nativeExpressAd = [[GDTNativeExpressAd alloc] initWithAppId:QWGDTAdKey
                                                         placementId:QWGDTReadNativedAdKey
                                                              adSize:self.bounds.size];
    self.nativeExpressAd.delegate = self;
    [self.nativeExpressAd loadAd:3];
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

#pragma mark - GDTNativeExpressAdDelegete
/**
 * 拉取广告成功的回调
 */
- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views
{
    self.expressAdViews = [NSMutableArray arrayWithArray:views];
    if (self.expressAdViews.count) {
        [self.expressAdViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GDTNativeExpressAdView *expressView = (GDTNativeExpressAdView *)obj;
            expressView.controller = [self getTopVC];
            [expressView render];
        }];
    }
    
}

/**
 * 拉取广告失败的回调
 */
- (void)nativeExpressAdRenderFail:(GDTNativeExpressAdView *)nativeExpressAdView
{
}

/**
 * 拉取原生模板广告失败
 */
- (void)nativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error
{
    NSLog(@"Express Ad Load Fail : %@",error);
}

- (void)nativeExpressAdViewRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView
{
    UIView *view = [self.expressAdViews objectAtIndex:0];
    view.tag = 1000;
    [self addSubview:view];
}

- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"chapter"] = self.chapterId;
    params[@"book"] = self.bookId;
    params[@"source"] = @"GDT";
    if ([self.free isEqualToNumber: [NSNumber numberWithInteger:1]] && [self.lastAd isEqualToNumber: [NSNumber numberWithInteger:2]]) {
        [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"InsertPayClickEvent" extra:params];
    }
    if ([self.free isEqualToNumber: [NSNumber numberWithInteger:0]] && [self.lastAd isEqualToNumber: [NSNumber numberWithInteger:2]]) {
        [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"InsertFreeClickEvent" extra:params];
    }
    if ([self.free isEqualToNumber: [NSNumber numberWithInteger:1]] && [self.lastAd isEqualToNumber: [NSNumber numberWithInteger:0]]) {
        [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"FootingPayClickEvent" extra:params];
    }
    if ([self.free isEqualToNumber: [NSNumber numberWithInteger:0]] && [self.lastAd isEqualToNumber: [NSNumber numberWithInteger:0]]) {
        [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"FootingFreeClickEvent" extra:params];
    }
    
}

- (void)nativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"--------%s-------",__FUNCTION__);
    [self.expressAdViews removeObject:nativeExpressAdView];
    
}

@end
