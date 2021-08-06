//
//  QWTBC.m
//  Qingwen
//
//  Created by Aimy on 7/1/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWTBC.h"

#import "QWReachability.h"
#import "QWDetailLogic.h"

@interface QWTBC () <UITabBarControllerDelegate, QWSummonsSelectViewDelegate>

@property (nonatomic, weak) UIViewController *lastVC;
//@property (nonatomic, strong) QWIntroVC *introVC;
@property (nonatomic, strong) QWChooseLocateVC *locateVC;
@property (nonatomic, strong) QWDetailLogic *logic;
@property (strong, nonatomic) QWSummonsSelectView *selectedView;

@end

@implementation QWTBC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIViewController *vc1 = ({
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"QWCollectionBase" bundle:nil];
        UIViewController *vc = [sb instantiateInitialViewController];
        vc.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabitem1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        vc.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabitem1_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        vc;
    });
    
    UIViewController *vc2 = ({
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"QWHome" bundle:nil];
        UIViewController *vc = [sb instantiateInitialViewController];
        vc.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabitem2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        vc.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabitem2_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        vc;
    });
    
    UIViewController *vc3 = ({
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"QWSquare" bundle:nil];
        UIViewController *vc = [sb instantiateInitialViewController];
        vc.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabitem3"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        vc.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabitem3_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        vc;
    });
    
    UIViewController *vc4 = ({
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"QWMyCenter" bundle:nil];
        UIViewController *vc = [sb instantiateInitialViewController];
        vc.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabitem4"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        vc.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabitem4_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        vc;
    });

    self.viewControllers = @[vc1, vc2, vc3, vc4];

    self.delegate = self;
    self.selectedIndex = 1;
    WEAK_SELF;
    [self observeNotification:NotificationNetworkStatusReachable withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }

        KVO_STRONG_SELF;
        NSDictionary *info = notification.userInfo;
        if ([info[@"reachability"] boolValue]) {
            [kvoSelf showToastWithTitle:@"网络已连接" subtitle:nil type:ToastTypeAlert options:@{kCRToastTimeIntervalKey: @1}];
        }
        else {
            [kvoSelf showToastWithTitle:@"网络连接已断开" subtitle:nil type:ToastTypeAlert options:@{kCRToastTimeIntervalKey: @1}];
        }
    }];

    [self.viewControllers.lastObject.tabBarItem showIndicator:[QWGlobalValue sharedInstance].unread.integerValue];
    [self observeNotification:@"UNREAD_CHANGED" withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }

        KVO_STRONG_SELF;
        UIViewController *vc = kvoSelf.viewControllers.lastObject;
        [vc.tabBarItem showIndicator:[QWGlobalValue sharedInstance].unread.integerValue];
    }];

//    if (![QWUserDefaults sharedInstance][@"showIntro1.10.0"]) {
//        [self performInMainThreadBlock:^{
//            self.introVC = [[UIStoryboard storyboardWithName:@"QWIntro" bundle:nil] instantiateInitialViewController];
//            [self presentViewController:self.introVC animated:NO completion:nil];
//        } afterSecond:.1f];
//    }

//    if (![QWUserDefaults sharedInstance][@"showChannel2.0.0"]) {
//        [self performInMainThreadBlock:^{
//            self.locateVC = [QWChooseLocateVC createFromXibWithNibName:@"QWChooseLocateOnlyOneVC"];
//            [self presentViewController:self.locateVC animated:NO completion:nil];
//        } afterSecond:.1f];
//    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.selectedViewController.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    return self.selectedViewController.prefersStatusBarHidden;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    static NSInteger count = 1;
    if (self.lastVC == viewController) {
        count++;
        [self.lastVC repeateClickTabBarItem:count];
    }
    else {
        count = 1;
    }
    
    self.lastVC = viewController;
}

// New Autorotation support.
- (BOOL)shouldAutorotate
{
    return self.selectedViewController.shouldAutorotate;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.selectedViewController.supportedInterfaceOrientations;
}

// Returns interface orientation masks.
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return self.selectedViewController.preferredInterfaceOrientationForPresentation;
}

// charge
- (void)doChargeWithBook:(BookVO *)book heavy:(BOOL)heavy
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        return;
    }

    self.logic.bookVO = book;
    self.selectedView = [QWSummonsSelectView createWithNib];
    self.selectedView.type = heavy ? 1 : 0;
    self.selectedView.chargeType = 0;
    self.selectedView.delegate = self;
    self.selectedView.frame = self.view.bounds;
    [self.selectedView updateDisplay];
    [self.view addSubview:self.selectedView];
}

- (void)doChargeWithFavorite:(FavoriteBooksVO *)favorite heavy:(BOOL)heavy
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        return;
    }
    
    self.logic.favBooks = favorite;
    self.selectedView = [QWSummonsSelectView createWithNib];
    self.selectedView.type = heavy ? 1 : 0;
    self.selectedView.chargeType = 1;
    self.selectedView.delegate = self;
    self.selectedView.frame = self.view.bounds;
    [self.selectedView updateDisplay];
    [self.view addSubview:self.selectedView];
}

- (void)doCharge
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        return;
    }

    [self.selectedView removeFromSuperview];
    self.selectedView = [QWSummonsSelectView createWithNib];
    self.selectedView.delegate = self;
    self.selectedView.chargeType = 0;
    [self.selectedView onPressedChargeBtn:nil];
}

- (QWDetailLogic *)logic
{
    if (!_logic) {
        _logic = [QWDetailLogic logicWithOperationManager:self.operationManager];
    }

    return _logic;
}
-(void)selectView:(QWSummonsSelectView *)view didSelectedCount:(NSNumber *)indexCount type:(NSNumber *)type chargeType:(NSNumber *)chargeType
{
    if (!type.boolValue && [QWGlobalValue sharedInstance].user.coin.integerValue < indexCount.integerValue) {
        [self showToastWithTitle:@"轻石不够" subtitle:nil type:ToastTypeAlert];
        return;
    }

    if (type.boolValue && [QWGlobalValue sharedInstance].user.gold.integerValue < indexCount.integerValue) {
        [self showToastWithTitle:@"重石不够" subtitle:nil type:ToastTypeAlert];
        return;
    }

    [self showLoading];
    WEAK_SELF;
    if (chargeType.integerValue == 1){
        [self.logic doChargeToFavorite:type.integerValue amount:indexCount.integerValue andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            STRONG_SELF;
            [self hideLoading];
            if (!anError) {
                NSNumber *code = aResponseObject[@"code"];
                if (code && ! [code isEqualToNumber:@0]) {//有错误
                    NSString *message = aResponseObject[@"msg"];
                    if (message.length) {
                        [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                    }
                    else {
                        [self showToastWithTitle:@"投石失败" subtitle:nil type:ToastTypeError];
                    }
                }
                else {
                    //self.logic.bookVO.coin = @(self.logic.bookVO.coin.integerValue + indexCount.integerValue);
                    if ([type  isEqualToNumber: @0]){
                        [QWGlobalValue sharedInstance].user.coin = @([QWGlobalValue sharedInstance].user.coin.integerValue - indexCount.integerValue);
                    }else{
                        [QWGlobalValue sharedInstance].user.gold = @([QWGlobalValue sharedInstance].user.gold.integerValue - indexCount.integerValue);
                    }
                    //dry code
                    [[QWGlobalValue sharedInstance] save];
                    [self showToastWithTitle:@"投石成功" subtitle:nil type:ToastTypeError];
                    [self.selectedView removeFromSuperview];
                    self.selectedView = nil;
                    [[QWRouter sharedInstance].topVC update];
                }
            }
            else {
                [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
            }
        }];
        
    }
    else{
        if ([type  isEqualToNumber: @0]) {
            [self.logic doChargeWithCoin:indexCount.integerValue andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
                STRONG_SELF;
                [self hideLoading];
                if (!anError) {
                    NSNumber *code = aResponseObject[@"code"];
                    if (code && ! [code isEqualToNumber:@0]) {//有错误
                        NSString *message = aResponseObject[@"data"];
                        if (message.length) {
                            [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                        }
                        else {
                            [self showToastWithTitle:@"投石失败" subtitle:nil type:ToastTypeError];
                        }
                    }
                    else {
                        self.logic.bookVO.coin = @(self.logic.bookVO.coin.integerValue + indexCount.integerValue);
                        [QWGlobalValue sharedInstance].user.coin = @([QWGlobalValue sharedInstance].user.coin.integerValue - indexCount.integerValue);
                        [[QWGlobalValue sharedInstance] save];
                        [self showToastWithTitle:@"投石成功" subtitle:nil type:ToastTypeError];
                        [self.selectedView removeFromSuperview];
                        self.selectedView = nil;
                        NSDictionary *activity_data = aResponseObject[@"activity_data"];
                        if (activity_data[@"count"] != 0) {
                            NSArray *data = activity_data[@"data"];
                            for (NSDictionary *res in data) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"gameTicketParams" object:res];
//                                NSString *content_url = res[@"content_url"];
                                
                            }
                        }
                        [[QWRouter sharedInstance].topVC update];
                    }
                }
                else {
                    [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
                }
            }];
        }
        else {
            [self.logic doChargeWithGold:indexCount.integerValue andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
                STRONG_SELF;
                [self hideLoading];
                if (!anError) {
                    NSNumber *code = aResponseObject[@"code"];
                    if (code && ! [code isEqualToNumber:@0]) {//有错误
                        NSString *message = aResponseObject[@"data"];
                        if (message.length) {
                            [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                        }
                        else {
                            [self showToastWithTitle:@"投石失败" subtitle:nil type:ToastTypeError];
                        }
                    }
                    else {
                        self.logic.bookVO.gold = @(self.logic.bookVO.gold.integerValue + indexCount.integerValue);
                        [QWGlobalValue sharedInstance].user.gold = @([QWGlobalValue sharedInstance].user.gold.integerValue - indexCount.integerValue);
                        [[QWGlobalValue sharedInstance] save];
                        [self showToastWithTitle:@"投石成功" subtitle:nil type:ToastTypeError];
                        [self.selectedView removeFromSuperview];
                        self.selectedView = nil;
                        [[QWRouter sharedInstance].topVC update];
                    }
                }
                else {
                    [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
                }
            }];
        }
    }
}


@end
