//
//  QWGameSettingView.h
//  Qingwen
//
//  Created by Aimy on 5/13/16.
//  Copyright © 2016 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QWGameSettingView;

@protocol QWGameSettingViewDelegate <NSObject>

- (void)settingView:(QWGameSettingView *)view didClickedCancelBtn:(id)sender;
- (void)settingView:(QWGameSettingView *)view didClickedBackBtn:(id)sender;
- (void)settingView:(QWGameSettingView *)view didClickedShareBtn:(id)sender;
- (void)settingView:(QWGameSettingView *)view didClickedDiscussBtn:(id)sender;
- (void)settingView:(QWGameSettingView *)view didClickedSendBtn:(id)sender;

- (void)settingView:(QWGameSettingView *)view didClickOrientationBtn:(id)sender;

- (void)settingView:(QWGameSettingView *)view didClickedProgressSlider:(UISlider *)sender;

- (void)settingView:(QWGameSettingView *)view didClickedResolutionBtn:(UIButton *)sender;

- (void)settingView:(QWGameSettingView *)view didClickedPauseBtn:(UIButton *)sender;

- (void)askSuperVCChangeStatusBarWithState:(BOOL)state;

@end

@interface QWGameSettingView : UIView

@property (weak, nonatomic) id <QWGameSettingViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIButton *shareBtn;
@property (strong, nonatomic) IBOutlet UIButton *discussBtn;
@property (strong, nonatomic) IBOutlet UITextField *contentTV;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *orientationBtn;

@property (strong, nonatomic) IBOutlet UISlider *progressSlider;
@property (strong, nonatomic) IBOutlet UILabel *progressLabel;

- (void)updateProgress:(float)progress;

/**
    切换横竖屏
 */
- (IBAction)onPressedOrientationBtn:(UIButton *)sender;

- (void)changeConstraint;
@end
