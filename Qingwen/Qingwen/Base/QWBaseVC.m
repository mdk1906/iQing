//
//  QWBaseVC.m
//  Qingwen
//
//  Created by Aimy on 7/1/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBaseVC.h"

@interface QWBaseVC ()

@end

@implementation QWBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.navigationController.viewControllers.count > 1) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_left"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBtnClicked:)];
        self.navigationItem.leftBarButtonItem = item;
    }
}

- (void)dealloc
{
    NSLog(@"[%@ call %@]", [self class], NSStringFromSelector(_cmd));
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
#ifndef DEBUG
    [[BaiduMobStat defaultStat] pageviewStartWithName:NSStringFromClass([self class])];
    [[QWActivityTracing sharedInstance] setCurrentRunningIdentifier:NSStringFromClass([self class])];
#endif
    if (ISIPHONEX) {
        
    }
    else{
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[@"view"] = NSStringFromClass([self class]);
        [QWUserStatistics sendEventToServer:@"Event" pageID:@"ViewAppear" extra:params];
        NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
        //    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
        [QWGlobalValue sharedInstance].viewApperDate = datenow;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    END_EDITING;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
#ifndef DEBUG
    [[BaiduMobStat defaultStat] pageviewEndWithName:NSStringFromClass([self class])];
#endif
    if (ISIPHONEX) {
        
    }
    else{
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[@"view"] = NSStringFromClass([self class]);
        [QWUserStatistics sendEventToServer:@"Event" pageID:@"ViewDisappear" extra:params];
    }
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

    if (IOS_SDK_MORE_THAN(8.0)) {
        return ;
    }

    CGSize size = CGSizeZero;
    if (!IS_LANDSCAPE) {
        size = [UIScreen mainScreen].bounds.size;
    }
    else {
        size = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }

    WEAK_SELF;
    [UIView animateWithDuration:duration animations:^{
        STRONG_SELF;
        [self resize:size];
    } completion:^(BOOL finished) {
        STRONG_SELF;
        [self didResize:size];
    }];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    WEAK_SELF;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        STRONG_SELF;
        [self resize:size];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        STRONG_SELF;
        [self didResize:size];
    }];
}

// New Autorotation support.
- (BOOL)shouldAutorotate
{
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (IS_IPHONE_DEVICE) {
        return UIInterfaceOrientationMaskPortrait;
    }
    else {
        return UIInterfaceOrientationMaskAll;
    }
}

// Returns interface orientation masks.
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [super preferredInterfaceOrientationForPresentation];
}

@end
