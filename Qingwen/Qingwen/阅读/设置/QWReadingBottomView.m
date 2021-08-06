//
//  QWReadingBottomView.m
//  Qingwen
//
//  Created by Aimy on 7/2/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWReadingBottomView.h"
#import "QWReadingVC.h"
#import "QWReadingPVC.h"

#define kHeight 112
@interface QWReadingBottomView ()<UIGestureRecognizerDelegate>

@property (nonatomic) BOOL config;

@property (nonatomic, strong) NSLayoutConstraint *constraint;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) IBOutlet UIButton *modeBtn;
@property (strong, nonatomic) IBOutlet UILabel *modeLabel;
@property (strong, nonatomic) IBOutlet UIView *modeView;
@property (nonatomic) NSInteger lastPageIndex;

@end

@implementation QWReadingBottomView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.slider setThumbImage:[UIImage imageNamed:@"reading_btn_thumb"] forState:UIControlStateNormal];
    WEAK_SELF;
    [self.modeView bk_whenTapped:^{
        STRONG_SELF;
        [self onPressedChangeModeBtn:self.modeBtn];
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
    if([touch.view isKindOfClass:[UISlider class]])
        return NO;
    else
        return YES;
}

- (void)didMoveToSuperview
{
    if (!self.config) {
        self.hidden = YES;
        self.config = YES;
        self.constraint = [self autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.superview];
        [self autoConstrainAttribute:ALAttributeVertical toAttribute:ALAttributeVertical ofView:self.superview];
        [self autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.superview];
        self.heightConstraint = [self autoSetDimension:ALDimensionHeight toSize:kHeight];
    }
}

- (void)showWithAnimated
{
    //修改了背景 也需要相应修改
//    if ([QWReadingConfig sharedInstance].readingBG == QWReadingBGBlack) {
//        self.modeLabel.text = @"白天";
//        self.modeBtn.selected = false;
//    }
//    else {
//        self.modeLabel.text = @"夜间";
//        self.modeBtn.selected = true;
//    }
    
    self.hidden = NO;
    [self.superview bringSubviewToFront:self];

    if (@available(iOS 11.0, *)) {
        self.constraint.constant = -kHeight - self.superview.safeAreaInsets.bottom;
        if(ISIPHONEX){
            self.heightConstraint.constant = kHeight + self.superview.safeAreaInsets.bottom;
        }
    }else{
        self.constraint.constant = -kHeight;
    }

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

- (IBAction)onPressedDirectoryBtn:(id)sender {
    [self.delegate bottomView:self didClickedDirectoryBtn:sender];
}

- (IBAction)onpressedLightBtn:(id)sender {
    [self.delegate bottomView:self didClickedLightBtn:sender];
}

- (IBAction)onPressedProgressBtn:(id)sender {
    [self.delegate bottomView:self didClickedProgressBtn:sender];
}

- (IBAction)onPressedChargeBtn:(id)sender {
//    [self.delegate bottomView:self didClickedChargeBtn:sender];
    [self.delegate bottomView:self didClickedDirectoryBtn:sender];
}

- (IBAction)onPressedSettingBtn:(id)sender {
    [self.delegate bottomView:self didClickedSettingBtn:sender];
}

- (IBAction)onPressedChangeModeBtn:(UIButton *)sender {
//    sender.selected = !sender.isSelected;
    [self.delegate bottomView:self didClickedChargeBtn:sender];
//    if (sender.selected) {
//        self.modeLabel.text = @"夜间";
//        [QWReadingConfig sharedInstance].readingBG = QWReadingBGDefault;
//    }
//    else {
//        self.modeLabel.text = @"白天";
//        [QWReadingConfig sharedInstance].readingBG = QWReadingBGBlack;
//    }
//
//    [[QWReadingConfig sharedInstance] saveData];
}


#pragma mark - progressview

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
