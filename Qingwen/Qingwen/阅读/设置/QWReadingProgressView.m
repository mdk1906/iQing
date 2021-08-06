//
//  QWReadingProgressView.m
//  Qingwen
//
//  Created by Aimy on 7/2/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWReadingProgressView.h"

#import "QWReadingPVC.h"
#import "QWReadingVC.h"

@interface QWReadingProgressView () <UIGestureRecognizerDelegate>

@property (nonatomic) BOOL config;

@property (nonatomic, strong) NSLayoutConstraint *constraint;

@property (nonatomic) NSInteger lastPageIndex;
@property (strong, nonatomic) IBOutlet UISlider *slider;

@end

@implementation QWReadingProgressView

- (void)didMoveToSuperview
{
    if (!self.config) {
        self.hidden = YES;
        self.config = YES;
        self.constraint = [self autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.superview];
        [self autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.superview];
        [self autoSetDimension:ALDimensionHeight toSize:64];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
    if([touch.view isKindOfClass:[UISlider class]])
        return NO;
    else
        return YES;
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

- (IBAction)onPressedPreviousBtn:(id)sender {
    QWReadingVC *vc = self.ownerVC.currentVC;
    if (vc.isLoading) {
        return ;
    }
    
    [self.delegate gotoPreviousChapterClickInProgressView:self];
}

- (IBAction)onPressedNextBtn:(id)sender {
    QWReadingVC *vc = self.ownerVC.currentVC;
    if (vc.isLoading) {
        return ;
    }

    [self.delegate gotoNextChapterClickInProgressView:self];
}

//- (IBAction)onPressedProgressBtn:(UISlider *)sender {
//    if (self.slider.value / 100 == self.lastPageIndex) {
//        return ;
//    }
//
//    self.lastPageIndex = self.slider.value / 100;
//
//    [self.delegate progressView:self changeToPageIndex:self.lastPageIndex];
//}

- (IBAction)onValueChanged:(UISlider *)sender {
    if (self.slider.value / 100 == self.lastPageIndex) {
        return ;
    }

    if (self.lastPageIndex > self.slider.value / 100) {
        self.lastPageIndex = self.slider.value / 100;
    }
    else {
        self.lastPageIndex = ceil(self.slider.value / 100);
    }

    [self.delegate progressView:self changeToPageIndex:self.lastPageIndex];
//    [self.delegate progressView:self previewPageAtIndex:self.slider.value];
}

- (void)updateWithCurrentPageIndex:(NSInteger)currentPageIndex andPageCount:(NSInteger)count
{
    self.lastPageIndex = currentPageIndex;
    if (count > 0) {
        self.slider.maximumValue  = (count - 1) * 100;
    }
    else {
        self.slider.maximumValue = 0;
    }
    self.slider.value = self.lastPageIndex * 100;
}

@end
