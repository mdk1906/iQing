//
//  QWInterstitialAdVC.m
//  Qingwen
//
//  Created by qingwen on 2019/2/26.
//  Copyright © 2019 iQing. All rights reserved.
//

#import "QWInterstitialAdVC.h"
#import <YumiMediationSDK/YumiMediationInterstitial.h>
#import <YumiMediationSDK/YumiAdsSplash.h>
@interface QWInterstitialAdVC ()<YumiMediationInterstitialDelegate,YumiAdsSplashDelegate>
@property (nonatomic) YumiMediationInterstitial *yumiInterstitial;
@end

@implementation QWInterstitialAdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    [[YumiAdsSplash sharedInstance] showYumiAdsSplashWith:QWSplashAdKey
                                                   appKey:QWYuMiAdKey
                                       rootViewController:self
                                                 delegate:self];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    [self startAd];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}
-(void)startAd{
    if ([self.yumiInterstitial isReady]) {
        [self.yumiInterstitial present];
    } else {
        NSLog(@"Ad wasn't ready");
    }
}
//implementing YumiMediationInterstitial Delegate
- (void)yumiMediationInterstitialDidReceiveAd:(YumiMediationInterstitial *)interstitial{
    NSLog(@"interstitialDidReceiveAd");
}
- (void)yumiMediationInterstitial:(YumiMediationInterstitial *)interstitial
                 didFailWithError:(YumiMediationError *)error{
    NSLog(@"interstitial:didFailToReceiveAdWithError: %@", error);
}
- (void)yumiMediationInterstitialWillDismissScreen:(YumiMediationInterstitial *)interstitial{
    NSLog(@"interstitialWillDismissScreen");
    
}
- (void)yumiMediationInterstitialDidClick:(YumiMediationInterstitial *)interstitial{
    NSLog(@"interstitialDidClick");
    
    NSMutableDictionary *adparam = [NSMutableDictionary new];
    adparam[@"token"] = [QWGlobalValue sharedInstance].token;
    adparam[@"device_id"] = [QWGlobalValue sharedInstance].deviceToken;
    adparam[[self.bookId stringValue]] = @"1";
    
    QWOperationParam *globalAdpm = [QWInterface postWithUrl:[NSString stringWithFormat:@"%@/ad/chapter_finish/",[QWOperationParam currentDomain]] params:adparam andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[@"chapter"] = self.chapterId;
        params[@"book"] = self.bookId;
        params[@"source"] = @"YUMI";
        [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"TipPayEvent" extra:params];
        [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"TipPayClickEvent" extra:params];
        [self.navigationController popViewControllerAnimated:NO];
    }];
    globalAdpm.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:globalAdpm];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)yumiAdsSplashDidLoad:(YumiAdsSplash *)splash{
    NSLog(@"yumiAdsSplashDidLoad.");
}
- (void)yumiAdsSplash:(YumiAdsSplash *)splash DidFailToLoad:(NSError *)error{
    NSLog(@"yumiAdsSplash:DidFailToLoad: %@", error);
}
- (void)yumiAdsSplashDidClicked:(YumiAdsSplash *)splash{
    NSLog(@"yumiAdsSplashDidClicked.");
    
}
- (void)yumiAdsSplashDidClosed:(YumiAdsSplash *)splash{
    NSLog(@"yumiAdsSplashDidClosed.");
    NSMutableDictionary *adparam = [NSMutableDictionary new];
    adparam[@"token"] = [QWGlobalValue sharedInstance].token;
    adparam[@"device_id"] = [QWGlobalValue sharedInstance].deviceToken;
    adparam[@"chapter_id"] = self.chapterId;
    
    QWOperationParam *globalAdpm = [QWInterface postWithUrl:[NSString stringWithFormat:@"%@/ad/chapter_finish/",[QWOperationParam currentDomain]] params:adparam andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[@"chapter"] = self.chapterId;
        params[@"book"] = self.bookId;
        params[@"source"] = @"YUMI";
        [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"TipPayEvent" extra:params];
        [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"TipPayClickEvent" extra:params];
        [self.navigationController popViewControllerAnimated:NO];
    }];
    globalAdpm.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:globalAdpm];
    
}
- (nullable UIImage *)yumiAdsSplashDefaultImage{
    return nil;//Your default image when app start
}

@end
