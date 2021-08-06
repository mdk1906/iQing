//
//  QWBaseNC.m
//  Qingwen
//
//  Created by Aimy on 7/1/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBaseNC.h"
#import "QWGameVC.h"
@interface QWBaseNC ()

@end

@implementation QWBaseNC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.customAnimationDelegate = [QWNCDelegate new];
    self.customAnimationDelegate.ownerNC = self;
    self.delegate = self.customAnimationDelegate;
}

- (void)update
{
    [self.visibleViewController update];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.visibleViewController.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    return self.visibleViewController.prefersStatusBarHidden;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }

    [super pushViewController:viewController animated:animated];
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers animated:(BOOL)animated{
    if (self.viewControllers.count > 0) {
        for (int i = 0; i < viewControllers.count; i++) {
            if (i > 0) {
                UIViewController *vc = viewControllers[i];
                vc.hidesBottomBarWhenPushed = YES;
            }
        }
    }
    [super setViewControllers:viewControllers animated:animated];
    
}

- (void)repeateClickTabBarItem:(NSInteger)count
{
    [self.visibleViewController repeateClickTabBarItem:count];
}

// New Autorotation support.
- (BOOL)shouldAutorotate
{
    return self.visibleViewController.shouldAutorotate;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (IOS_SDK_MORE_THAN(9.0)) {
        if ([self.visibleViewController isKindOfClass:[UIAlertController class]]) {
            return self.topViewController.supportedInterfaceOrientations;
        }
        else {
            return self.visibleViewController.supportedInterfaceOrientations;
        }
    }
    else {
        return self.visibleViewController.supportedInterfaceOrientations;
    }
}

// Returns interface orientation masks.
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return self.visibleViewController.preferredInterfaceOrientationForPresentation;
}

@end
