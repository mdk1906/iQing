//
//  QWReadingSettingView.m
//  Qingwen
//
//  Created by Aimy on 7/2/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWReadingSettingView.h"

#import "QWReadingConfig.h"
#import "QWReadingVC.h"
#import "QWReadingPVC.h"

#define kHeight 214

@interface QWReadingPVC ()

- (void)gotoMoreSetting;

@end

@interface QWReadingSettingView ()

@property (nonatomic) BOOL config;

@property (nonatomic, strong) NSLayoutConstraint *constraint;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (strong, nonatomic) IBOutlet UISlider *brightnessSlider;
@property (strong, nonatomic) IBOutlet UIButton *brightnessBtn;
@property (strong, nonatomic) IBOutlet UIButton *traditionalBtn;
@property (strong, nonatomic) IBOutlet UIButton *simplifiedBtn;
@property (strong, nonatomic) IBOutlet UIButton *originalFontBtn;

@property (strong, nonatomic) IBOutlet UIButton *smallerFontBtn;
@property (strong, nonatomic) IBOutlet UIButton *biggerFontBtn;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *bgBtns;

@end

@implementation QWReadingSettingView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self configBtns];
    self.hidden = YES;
}

- (void)dealloc {

}

- (void)configBtns
{
    
    //繁体
    if([QWReadingConfig sharedInstance].originalFont){
        self.originalFontBtn.selected = [QWReadingConfig sharedInstance].originalFont;
        self.traditionalBtn.selected = NO;
        self.simplifiedBtn.selected = NO;
    }else{
        self.traditionalBtn.selected = [QWReadingConfig sharedInstance].traditional;
        self.simplifiedBtn.selected = ![QWReadingConfig sharedInstance].traditional;
    }
    
    
    //背景按钮
    [self.bgBtns makeObjectsPerformSelector:@selector(setSelected:) withObject:nil];
    UIButton *bgBtn = self.bgBtns[[QWReadingConfig sharedInstance].readingBG];
    bgBtn.selected = YES;

    self.smallerFontBtn.enabled = [[QWReadingConfig sharedInstance] canChangeFont:YES];
    self.biggerFontBtn.enabled = [[QWReadingConfig sharedInstance] canChangeFont:NO];
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
    [self configBtns];
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
- (IBAction)onPressedOriginalFontBtn:(UIButton *)sender {
    if ([QWReadingConfig sharedInstance].originalFont) {
        return ;
    }
    QWReadingVC *vc = self.ownerVC.currentVC;
    if (vc.isLoading) {
        return ;
    }
    
    self.originalFontBtn.selected = YES;
    self.traditionalBtn.selected = NO;
    self.simplifiedBtn.selected = NO;
    [QWReadingConfig sharedInstance].originalFont = YES;
    [[QWReadingConfig sharedInstance] saveData];
}

- (IBAction)onPressedTraditionalBtn:(UIButton *)sender {
//    if ([QWReadingConfig sharedInstance].traditional) {
//        return ;
//    }

    QWReadingVC *vc = self.ownerVC.currentVC;
    if (vc.isLoading) {
        return ;
    }

    self.traditionalBtn.selected = YES;
    self.simplifiedBtn.selected = NO;
    self.originalFontBtn.selected = NO;
    [QWReadingConfig sharedInstance].traditional = YES;
    [QWReadingConfig sharedInstance].originalFont = NO;
    [[QWReadingConfig sharedInstance] saveData];
}

- (IBAction)onPressedSimplifiedBtn:(UIButton *)sender {
//    if (![QWReadingConfig sharedInstance].traditional) {
//        return ;
//    }

    QWReadingVC *vc = self.ownerVC.currentVC;
    if (vc.isLoading) {
        return ;
    }

    self.traditionalBtn.selected = NO;
    self.originalFontBtn.selected = NO;
    self.simplifiedBtn.selected = YES;
    [QWReadingConfig sharedInstance].traditional = NO;
    [QWReadingConfig sharedInstance].originalFont = NO;
    [[QWReadingConfig sharedInstance] saveData];
}

- (IBAction)onPressedSmallerFontBtn:(id)sender {

    if (![[QWReadingConfig sharedInstance] canChangeFont:YES]) {
        return ;
    }

    QWReadingVC *vc = self.ownerVC.currentVC;
    if (vc.isLoading) {
        return ;
    }

    [[QWReadingConfig sharedInstance] changeFont:YES];

    self.smallerFontBtn.enabled = [[QWReadingConfig sharedInstance] canChangeFont:YES];
    self.biggerFontBtn.enabled = [[QWReadingConfig sharedInstance] canChangeFont:NO];

    [[QWReadingConfig sharedInstance] saveData];
}

- (IBAction)onPressedBiggerFontBtn:(id)sender {

    if (![[QWReadingConfig sharedInstance] canChangeFont:NO]) {
        return ;
    }

    QWReadingVC *vc = self.ownerVC.currentVC;
    if (vc.isLoading) {
        return ;
    }

    [[QWReadingConfig sharedInstance] changeFont:NO];

    self.smallerFontBtn.enabled = [[QWReadingConfig sharedInstance] canChangeFont:YES];
    self.biggerFontBtn.enabled = [[QWReadingConfig sharedInstance] canChangeFont:NO];
    [[QWReadingConfig sharedInstance] saveData];
}

- (IBAction)onPressedChangeBGBtn:(UIButton *)sender {
    QWReadingVC *vc = self.ownerVC.currentVC;
    if (vc.isLoading) {
        return ;
    }

    if ([QWReadingConfig sharedInstance].readingBG == (QWReadingBG)sender.tag) {
        return ;
    }

    [self.bgBtns makeObjectsPerformSelector:@selector(setSelected:) withObject:nil];
    sender.selected = YES;

    [QWReadingConfig sharedInstance].readingBG = (QWReadingBG)sender.tag;
    [[QWReadingConfig sharedInstance] saveData];
}

- (IBAction)onPressedGotoMoreSettingBtn:(id)sender {
    [self.ownerVC gotoMoreSetting];
}

@end
