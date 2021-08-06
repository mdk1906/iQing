//
//  QWReadingBrightnessView.m
//  Qingwen
//
//  Created by mumu on 2017/6/2.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWReadingBrightnessView.h"

#define kHeight 50

@interface QWReadingBrightnessView()
@property (nonatomic) BOOL config;

@property (nonatomic, strong) NSLayoutConstraint *constraint;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (strong, nonatomic) IBOutlet UISlider *brightnessSlider;
@property (weak, nonatomic) IBOutlet UIButton *sysBrighteness;

@end

@implementation QWReadingBrightnessView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //亮度
    WEAK_SELF;
    [self observeNotification:UIApplicationDidBecomeActiveNotification withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }
        
        KVO_STRONG_SELF;
        
        [QWReadingConfig sharedInstance].systemBrightness = [UIScreen mainScreen].brightness;
        
        if ([QWReadingConfig sharedInstance].useSystemBrightness) {
            kvoSelf.brightnessSlider.value = [UIScreen mainScreen].brightness;
        }
        else {
            [UIScreen mainScreen].brightness = [QWReadingConfig sharedInstance].brightness;
        }
        
        [[QWReadingConfig sharedInstance] saveData];
    }];
    
    [self observeNotification:UIApplicationWillResignActiveNotification withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }
        [UIScreen mainScreen].brightness = [QWReadingConfig sharedInstance].systemBrightness;
    }];
    
    [self configBtns];
    
    self.hidden = YES;
}

- (void)dealloc {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [UIScreen mainScreen].brightness = [QWReadingConfig sharedInstance].systemBrightness;
    [self removeAllObservationsOfObject:self];
}

- (void)configBtns
{
    [QWReadingConfig sharedInstance].systemBrightness = [UIScreen mainScreen].brightness;
    
    if ([QWReadingConfig sharedInstance].useSystemBrightness) { //关闭系统设置亮度
        //[QWReadingConfig sharedInstance].useSystemBrightness = false;
        [QWReadingConfig sharedInstance].brightness = [QWReadingConfig sharedInstance].systemBrightness;
        [[QWReadingConfig sharedInstance] saveData];
        
        self.brightnessSlider.value = [QWReadingConfig sharedInstance].brightness;
    }
    else {
        self.brightnessSlider.value = [QWReadingConfig sharedInstance].brightness;
        [UIScreen mainScreen].brightness = [QWReadingConfig sharedInstance].brightness;
    }
    //常亮
    [UIApplication sharedApplication].idleTimerDisabled = [QWReadingConfig sharedInstance].alwaysBrightness;
    
}

- (void)didMoveToSuperview
{
    if (!self.config) {
        self.config = YES;
        self.constraint = [self autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.superview];
        [self autoConstrainAttribute:ALAttributeVertical toAttribute:ALAttributeVertical ofView:self.superview];
        [self autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.superview];
        self.heightConstraint = [self autoSetDimension:ALDimensionHeight toSize:kHeight];
        
        
    }
}

- (void)showWithAnimated
{
    self.hidden = NO;
    [self.superview bringSubviewToFront:self];
    if (@available(iOS 11.0, *)) {
        self.constraint.constant = -kHeight - self.superview.safeAreaInsets.bottom;
    }else{
        self.constraint.constant = -kHeight;
    }
    
    if(ISIPHONEX){
        if (@available(iOS 11.0, *)) {
            self.heightConstraint.constant = kHeight + self.superview.safeAreaInsets.bottom;
        }
    }
    
    if([QWReadingConfig sharedInstance].useSystemBrightness){
        self.sysBrighteness.selected = YES;
    }else{
        self.sysBrighteness.selected = NO;
    }
    self.brightnessSlider.enabled = !self.sysBrighteness.selected;
    
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
- (IBAction)pressedOnSysBrightenessBtn:(id)sender {
    [UIScreen mainScreen].brightness =  [QWReadingConfig sharedInstance].systemBrightness;
    ;
    
    if(!self.sysBrighteness.selected){
        [QWReadingConfig sharedInstance].useSystemBrightness = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(screenBrightnessDidChange:)
                                                     name:UIScreenBrightnessDidChangeNotification
                                                   object:nil];
    }else{
        [QWReadingConfig sharedInstance].useSystemBrightness = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIScreenBrightnessDidChangeNotification
                                                      object:nil];
    }
    self.sysBrighteness.selected = !self.sysBrighteness.selected;
    self.brightnessSlider.enabled = !self.sysBrighteness.selected;
    [QWReadingConfig sharedInstance].brightness = [UIScreen mainScreen].brightness;
    [[QWReadingConfig sharedInstance] saveData];
    
}

- (IBAction)onBrightnessSliderValueChanged:(UISlider *)sender {
    [UIScreen mainScreen].brightness = sender.value;
    [QWReadingConfig sharedInstance].brightness = sender.value;
//    [[QWReadingConfig sharedInstance] saveData];
}

- (void) screenBrightnessDidChange:(NSNotification *)notification{
    //[UIScreen mainScreen].brightness =  [QWReadingConfig sharedInstance].systemBrightness;
    [QWReadingConfig sharedInstance].brightness = [UIScreen mainScreen].brightness;
    [[QWReadingConfig sharedInstance] saveData];
}
@end
