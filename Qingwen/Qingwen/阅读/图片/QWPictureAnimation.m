//
//  QWPictureAnimation.m
//  Qingwen
//
//  Created by Aimy on 7/31/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWPictureAnimation.h"

@implementation QWPictureAnimation

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    __unused CGRect fromFrame = [transitionContext initialFrameForViewController:toVC];
    CGRect toFrame = [transitionContext finalFrameForViewController:toVC];
    UIView *contentView = [transitionContext containerView];

    if (self.push) {
        toVC.view.frame = toFrame;
        toVC.view.alpha = 0.f;
        toVC.view.transform = CGAffineTransformMakeScale(.1f, .1f);
        [contentView addSubview:toVC.view];

        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toVC.view.alpha = 1.f;
            toVC.view.transform = CGAffineTransformIdentity;
            fromVC.view.alpha = .0f;
        } completion:^(BOOL finished) {
            fromVC.view.alpha = 1.f;
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        toVC.view.frame = toFrame;
        toVC.view.alpha = 0.f;
        [contentView addSubview:toVC.view];
        [contentView sendSubviewToBack:toVC.view];

        fromVC.view.transform = CGAffineTransformIdentity;

        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromVC.view.alpha = 0.f;
            fromVC.view.transform = CGAffineTransformMakeScale(.1f, .1f);
            toVC.view.alpha = 1.f;
        } completion:^(BOOL finished) {
            fromVC.view.alpha = 1.f;
            toVC.view.alpha = 1.f;
            fromVC.view.transform = CGAffineTransformIdentity;
            [transitionContext completeTransition:YES];
        }];
    }
}

@end
