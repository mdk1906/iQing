//
//  QWGameSettingView.m
//  Qingwen
//
//  Created by Aimy on 5/13/16.
//  Copyright © 2016 iQing. All rights reserved.
//

#import "QWGameSettingView.h"

@interface QWGameSettingView ()

@property (strong, nonatomic) IBOutlet UIView *coverView;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIView *choiceResolutionView;

@property (strong, nonatomic) IBOutlet UIButton *currentSelectedBtn;

@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (strong, nonatomic) IBOutlet UIButton *sendDanmuBtn;
@property (strong, nonatomic) IBOutlet UIButton *resolutionBtn; //分辨率

@property (strong, nonatomic) IBOutlet UIButton *pauseBtn;

@property (strong, nonatomic) IBOutlet UIView *progressSuperView;
@property (strong, nonatomic) IBOutlet UIButton *bottomCancelBtn;

//Constraint

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomViewLeading;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *progressLabelTop; //百分比向上约束

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentTVLeading; //弹幕框左侧
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentTVTrailling; //弹幕右侧

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *progressLabelTrailing; //进度条右侧

@end

@implementation QWGameSettingView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentTV.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"轻吐槽。。ψ(｀∇´)ψ" attributes:@{NSForegroundColorAttributeName: HRGB(0xc2c2c2), NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    self.contentTV.font = [UIFont systemFontOfSize:14];
    self.contentTV.textColor = HRGB(0xc2c2c2);
    self.contentTV.backgroundColor = HRGB(0x666666);

    WEAK_SELF;
    [self observeNotification:UIKeyboardWillShowNotification fromObject:nil withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }

        KVO_STRONG_SELF;
        if (!kvoSelf.contentTV.isFirstResponder) {
            return ;
        }
        NSDictionary *info = [notification userInfo];
        NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGSize keyboardSize = [value CGRectValue].size;
        
        if (kvoSelf.orientationBtn.selected) {
            kvoSelf.bottomCancelBtn.hidden = false;
            kvoSelf.sendDanmuBtn.hidden = false;
            kvoSelf.progressLabel.hidden = true;
            kvoSelf.progressSlider.hidden = true;
            kvoSelf.resolutionBtn.hidden = true;
            kvoSelf.orientationBtn.hidden = true;
            kvoSelf.topView.hidden = true;
            kvoSelf.pauseBtn.hidden = true;
            
            kvoSelf.coverView.backgroundColor = [UIColor blackColor];
            kvoSelf.coverView.alpha= 0.8;
            kvoSelf.coverView.userInteractionEnabled = false;
            
            [kvoSelf.delegate askSuperVCChangeStatusBarWithState:false];
            
            [kvoSelf.sendDanmuBtn setTitle:@"发送" forState:UIControlStateNormal];
            kvoSelf.bottomViewLeading.constant = 0;
            kvoSelf.bottomConstraint.constant = UISCREEN_HEIGHT -  44;
            kvoSelf.contentTVLeading.constant = 55;
            kvoSelf.contentTVTrailling.constant = 20;

        } else {
            kvoSelf.bottomConstraint.constant = keyboardSize.height;
        }
        NSNumber *during = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        [UIView animateWithDuration:during.doubleValue animations:^{
            KVO_STRONG_SELF;
            [kvoSelf.superview layoutIfNeeded];
        }];
    }];

    [self observeNotification:UIKeyboardWillHideNotification fromObject:nil withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }

        KVO_STRONG_SELF;
        if (!kvoSelf.contentTV.isFirstResponder) {
            return ;
        }
        if (kvoSelf.orientationBtn.selected) {
            kvoSelf.bottomCancelBtn.hidden = true;
            kvoSelf.sendDanmuBtn.hidden = true;
            kvoSelf.progressLabel.hidden = false;
            kvoSelf.progressSlider.hidden = false;
            kvoSelf.resolutionBtn.hidden = false;
            kvoSelf.orientationBtn.hidden = false;
            kvoSelf.topView.hidden = false;
            kvoSelf.pauseBtn.hidden = false;
            
            kvoSelf.coverView.backgroundColor = [UIColor clearColor];
            kvoSelf.coverView.userInteractionEnabled = true;
            
            [kvoSelf.delegate askSuperVCChangeStatusBarWithState:true];
            
            [kvoSelf changeConstraint];
        } else {
            kvoSelf.bottomConstraint.constant = 0.f;
        }
        NSDictionary *info = [notification userInfo];
        NSNumber *during = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        [UIView animateWithDuration:during.doubleValue animations:^{
            KVO_STRONG_SELF;
            [kvoSelf.superview layoutIfNeeded];
        }];
    }];

    [self observeNotification:UIApplicationWillChangeStatusBarOrientationNotification withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }

        KVO_STRONG_SELF;
        if (kvoSelf.contentTV.isFirstResponder) {
            [kvoSelf.contentTV resignFirstResponder];
        }

        kvoSelf.bottomConstraint.constant = 0.f;
        
        NSNumber *orientation = notification.userInfo[UIApplicationStatusBarOrientationUserInfoKey];
        if (orientation.integerValue == 1) { //竖屏
            if (kvoSelf.orientationBtn.selected == true) {
                kvoSelf.orientationBtn.selected = false;
                [kvoSelf changeConstraint];
            }
        } else { //横屏
            if (kvoSelf.orientationBtn.selected == false) {
                kvoSelf.orientationBtn.selected = true;
                [kvoSelf changeConstraint];
            }
        }
    }];
}

- (void)updateProgress:(float)progress {
    WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        STRONG_SELF;
        self.progressLabel.text = [NSString stringWithFormat:@"%d％",(int)(progress * 100)];
        self.progressSlider.value = progress;
    });
}


- (void)changeConstraint {
//    CGFloat contentTVWidth = UISCREEN_WIDTH * 878 / 1920;  //横屏的时候固定长度
    
    if (self.orientationBtn.selected) { //竖屏
        
        CGFloat scrrenWidth = (UISCREEN_WIDTH > UISCREEN_HEIGHT) ? UISCREEN_WIDTH : UISCREEN_HEIGHT;
        CGFloat progressViewWidth = scrrenWidth * 210 / 736;

        self.sendDanmuBtn.hidden = true;
        self.bottomViewHeight.constant = 44;
        self.bottomViewLeading.constant = 0;
        self.bottomConstraint.constant = 0;
        self.progressLabelTop.constant = 12;
        CGFloat lanscape = (scrrenWidth - progressViewWidth - self.progressLabel.frame.size.width - 10 - 8 - self.orientationBtn.frame.size.width - self.resolutionBtn.frame.size.width - self.pauseBtn.frame.size.width - 20 - 13 - 20 - 13 - 18);
        self.progressLabelTrailing.constant =  lanscape + 13 + 20;
        
        self.contentTVLeading.constant = (progressViewWidth + self.progressLabel.frame.size.width + self.pauseBtn.frame.size.width + 20 + 13);
        self.contentTVTrailling.constant = (self.resolutionBtn.frame.size.width + self.orientationBtn.frame.size.width - self.sendDanmuBtn.frame.size.width + 40);
    }
    else {
        self.sendDanmuBtn.hidden = false;
        
        self.bottomViewHeight.constant = 80;
        self.bottomViewLeading.constant = 0;
        self.bottomConstraint.constant = 0;
        
        self.progressLabelTop.constant = 7;
        self.progressLabelTrailing.constant =  15;
        self.contentTVLeading.constant = 10;
        self.contentTVTrailling.constant = 10;
    }
}

- (IBAction)onPressedBackBtn:(id)sender {
    [self.delegate settingView:self didClickedBackBtn:sender];
}

- (IBAction)onPressedDiscussBtn:(id)sender {
    [self.delegate settingView:self didClickedDiscussBtn:sender];
}

- (IBAction)onPressedShareBtn:(id)sender {
    [self.delegate settingView:self didClickedShareBtn:sender];
}

- (IBAction)onPressedCancelBtn:(id)sender {
    [self.delegate settingView:self didClickedCancelBtn:sender];
}

- (IBAction)onPressedSendBtn:(id)sender {
    if (self.orientationBtn.selected) {
        [self onPressedCancelBtn:nil];
    }
    
    [self.delegate settingView:self didClickedSendBtn:sender];
}
- (IBAction)onPressedOrientationBtn:(UIButton *)sender {
    self.orientationBtn.selected = !sender.isSelected;
    [self.delegate settingView:self didClickOrientationBtn:sender];
    [self changeConstraint];
}

- (IBAction)onPressedSlider:(UISlider *)sender {
    self.progressLabel.text = [NSString stringWithFormat:@"%d％",(int)(sender.value * 100)];
    [self.delegate settingView:self didClickedProgressSlider:sender];
}

- (IBAction)onPressedResolutionBtn:(id)sender {
    self.choiceResolutionView.hidden = !self.choiceResolutionView.hidden;

}

- (IBAction)onPressedSelectResolutionBtn:(UIButton *)sender {
    if (self.currentSelectedBtn == sender) {
        self.choiceResolutionView.hidden = true;
        return;
    }
    self.currentSelectedBtn.selected = false;
    self.currentSelectedBtn = sender;
    self.currentSelectedBtn.selected = true;
    [self.resolutionBtn setTitle:sender.titleLabel.text forState:UIControlStateNormal];
    
    [self.delegate settingView:self didClickedResolutionBtn:sender];
    self.choiceResolutionView.hidden = true;
}
- (IBAction)onPressedPauseBtn:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    [self.delegate settingView:self didClickedPauseBtn:sender];
}

- (void)dealloc {
    NSLog(@"%@-%@",[self class],NSStringFromSelector(_cmd));
}
@end
