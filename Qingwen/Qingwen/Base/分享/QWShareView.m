//
//  QWShareView.m
//  Qingwen
//
//  Created by Aimy on 8/20/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWShareView.h"

@interface QWShareView ()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (strong, nonatomic) IBOutlet UIView *bgView;
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;

@property (nonatomic, copy) void (^block)(NSInteger);

@property (nonatomic, copy) NSArray *resources;

@end

@implementation QWShareView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.bottomConstraint.constant = -200;

    self.bgView.layer.cornerRadius = 5.f;
    self.bgView.layer.masksToBounds = YES;

    self.cancelBtn.layer.cornerRadius = 5.f;
    self.cancelBtn.layer.masksToBounds = YES;

    self.resources = @[
                       @[@"微博", @"share_icon0"],
                       @[@"微信", @"share_icon1"],
                       @[@"QQ", @"share_icon2"],
                       @[@"朋友圈", @"share_icon3"],
                       ];
}

- (void)showWithCompleteBlock:(void (^)(NSInteger))block;
{
    self.block = block;
    [self layoutIfNeeded];
    self.bottomConstraint.constant = 0;
    WEAK_SELF;
    [UIView animateWithDuration:.3f animations:^{
        STRONG_SELF;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3f];
        [self layoutIfNeeded];
    }];
}

- (void)hide
{
    self.bottomConstraint.constant = -200;
    WEAK_SELF;
    [UIView animateWithDuration:.3f animations:^{
        STRONG_SELF;
        self.backgroundColor = [UIColor clearColor];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        STRONG_SELF;
        [self removeFromSuperview];
    }];
}

- (IBAction)onTap:(id)sender {
    [self hide];
}

- (IBAction)onPressedShareBtn:(UIButton *)sender {
    if (self.block) {
        self.block(sender.tag);
    }

    [self hide];
}

@end
