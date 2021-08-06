//
//  QWPictureBottomView.m
//  Qingwen
//
//  Created by Aimy on 7/3/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWPictureBottomView.h"

@interface QWPictureBottomView ()

@property (nonatomic) BOOL config;
@property (nonatomic, strong) NSLayoutConstraint *constraint;

@end

@implementation QWPictureBottomView

- (void)didMoveToSuperview
{
    if (!self.config) {
        self.hidden = YES;
        self.config = YES;
        self.constraint = [self autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.superview];
        [self autoConstrainAttribute:ALAttributeVertical toAttribute:ALAttributeVertical ofView:self.superview];
        [self autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.superview];
        [self autoSetDimension:ALDimensionHeight toSize:64];
    }
}

- (void)showWithAnimated
{
    self.hidden = NO;
    [self.superview bringSubviewToFront:self];

    self.constraint.constant = -64;

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

- (IBAction)onPressedRotatingBtn:(id)sender {
    [self.delegate bottomView:self didClickedRotatingBtn:sender];
}

- (IBAction)onPressedSaveBtn:(id)sender {
    [self.delegate bottomView:self didClickedSaveBtn:sender];
}

@end
