//
//  QWVCAnimation.m
//  Qingwen
//
//  Created by Aimy on 7/30/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWVCAnimation.h"

@interface QWVCAnimation ()

@property (nonatomic) BOOL push;

@end

@implementation QWVCAnimation

+ (instancetype)animationWithType:(BOOL)push
{
    QWVCAnimation *animations = [self new];
    animations.push = push;
    return animations;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return .34f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    CGRect finalFrame = [transitionContext finalFrameForViewController:toViewController];

    UIView *containerView = [transitionContext containerView];
    float deviation = (self.isPush) ? 1.0f : -1.0f;

    CGRect newFrame = finalFrame;
    newFrame.origin.x += newFrame.size.width * deviation;
    toViewController.view.frame = newFrame;

    [containerView addSubview:toViewController.view];
    [containerView addSubview:fromViewController.view];

    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toViewController.view.frame = finalFrame;

        CGRect animationFrame = fromViewController.view.frame;
        animationFrame.origin.x -= animationFrame.size.width * deviation;
        fromViewController.view.frame = animationFrame;

    } completion:^(BOOL finished) {
        [transitionContext completeTransition: ! [transitionContext transitionWasCancelled]];
    }];
}

@end
