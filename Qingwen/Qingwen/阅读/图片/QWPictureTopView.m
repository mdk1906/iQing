//
//  QWPictureTopView.m
//  Qingwen
//
//  Created by Aimy on 7/3/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWPictureTopView.h"

@interface QWPictureTopView ()

@property (nonatomic) BOOL config;

@property (nonatomic, strong) NSLayoutConstraint *constraint;

@end

@implementation QWPictureTopView

- (IBAction)onPressedBackBtn:(id)sender {
    [self.delegate topView:self didClickedBackBtn:sender];
}

- (void)didMoveToSuperview
{
    if (!self.config) {
        self.hidden = YES;
        self.config = YES;
        self.constraint = [self autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.superview];
        [self autoConstrainAttribute:ALAttributeVertical toAttribute:ALAttributeVertical ofView:self.superview];
        [self autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.superview];
        [self autoSetDimension:ALDimensionHeight toSize:64];
    }
}

- (void)showWithAnimated
{
    self.hidden = NO;
    [self.superview bringSubviewToFront:self];

    self.constraint.constant = 64;

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

@end
