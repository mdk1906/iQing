//
//  QWReadingProgressMessageView.m
//  Qingwen
//
//  Created by Aimy on 7/9/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWReadingProgressMessageView.h"

@interface QWReadingProgressMessageView ()

@property (nonatomic) BOOL config;

@property (strong, nonatomic) IBOutlet UILabel *progressLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation QWReadingProgressMessageView

- (void)didMoveToSuperview
{
    if (!self.config) {
        self.layer.cornerRadius = 5.f;
        self.alpha = 0.f;
        self.config = YES;
        [self autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.superview withOffset: -(64 + 64 + 25)];
        [self autoConstrainAttribute:ALAttributeVertical toAttribute:ALAttributeVertical ofView:self.superview];
        if (IS_IPAD_DEVICE) {
            self.messageLabel.adjustsFontSizeToFitWidth = 420;
            [self autoSetDimension:ALDimensionWidth toSize:420];
            [self autoSetDimension:ALDimensionHeight toSize:100];
        }
        else {
            self.messageLabel.adjustsFontSizeToFitWidth = 270;
            [self autoSetDimension:ALDimensionWidth toSize:270];
            [self autoSetDimension:ALDimensionHeight toSize:80];
        }
    }
}

- (void)showWithAnimated
{
    [self.superview bringSubviewToFront:self];
    WEAK_SELF;
    [UIView animateWithDuration:.3f animations:^{
        STRONG_SELF;
        self.alpha = 1.f;
    }];
}

- (void)hideWithAnimated
{
    WEAK_SELF;
    [UIView animateWithDuration:.3f animations:^{
        STRONG_SELF;
        self.alpha = 0.f;
    }];
}

- (void)updateWithProgress:(NSInteger)progress andMessage:(NSString *)message
{
    self.progressLabel.text = [NSString stringWithFormat:@"%@%%", @(progress)];
    self.messageLabel.text = message;
}

@end
