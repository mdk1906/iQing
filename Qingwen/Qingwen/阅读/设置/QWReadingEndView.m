//
//  QWReadingEndView.m
//  Qingwen
//
//  Created by Aimy on 12/11/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWReadingEndView.h"

@interface QWReadingEndView ()

@property (nonatomic) BOOL config;

@property (nonatomic, strong) NSLayoutConstraint *constraint;

@end

@implementation QWReadingEndView

- (void)didMoveToSuperview
{
    if (!self.config) {
        self.hidden = YES;
        self.config = YES;
        self.constraint = [self autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.superview];
        [self autoConstrainAttribute:ALAttributeVertical toAttribute:ALAttributeVertical ofView:self.superview];
        [self autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.superview];
        [self autoSetDimension:ALDimensionHeight toSize:200];
    }
}

- (void)showWithAnimated
{
    self.hidden = NO;
    [self.superview bringSubviewToFront:self];

    self.constraint.constant = -200;

    WEAK_SELF;
    [UIView animateWithDuration:.3f animations:^{
        STRONG_SELF;
        [self layoutIfNeeded];
    }];
}

- (void)hideWithAnimated
{
    self.constraint.constant = 0;

    WEAK_SELF;
    [UIView animateWithDuration:.3f animations:^{
        STRONG_SELF;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        STRONG_SELF;
        self.hidden = YES;
    }];
}

- (IBAction)onPressedChargeBtn:(id)sender {
    [self.delegate endView:self onPressedChargeBtn:sender];
}

- (IBAction)onPressedDiscussBtn:(id)sender {
    [self.delegate endView:self onPressedDiscussBtn:sender];
}

- (IBAction)onPressedHideBtn:(id)sender {
    [self.delegate endView:self onPressedHideBtn:sender];
}

@end
