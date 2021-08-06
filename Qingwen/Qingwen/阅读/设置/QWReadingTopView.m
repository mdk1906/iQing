//
//  QWReadingTopView.m
//  Qingwen
//
//  Created by Aimy on 7/2/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWReadingTopView.h"

#import "QWReadingPVC.h"
#import "QWReadingVC.h"
#import "QWReadingManager.h"
@interface QWReadingTopView ()

@property (nonatomic) BOOL config;

@property (nonatomic, strong) NSLayoutConstraint *constraint;

@property (strong, nonatomic) IBOutlet UIButton *pictureBtn;
@property (strong, nonatomic) IBOutlet UIButton *DisscussBtn;
@property (weak, nonatomic) IBOutlet UIButton *aloudBtn;


@end

@implementation QWReadingTopView

- (IBAction)onPressedBackBtn:(id)sender {
    [self.delegate topView:self didClickedBackBtn:sender];
}

- (IBAction)onPressedPictureBtn:(id)sender {
    [self.delegate topView:self didClickedPictureBtn:sender];
}

- (IBAction)onPressedDiscussBtn:(id)sender {
    [self.delegate topView:self didClickedDiscussBtn:sender];
}
- (IBAction)onPressedAloudBtn:(id)sender {
    [self.delegate topView:self didClickedAloudBtn:sender];
}
- (IBAction)newPressedDiscussBtn:(id)sender {
    [self.delegate topView:self didClickedDiscussBtn:sender];
}
- (IBAction)onPressedDownBtn:(id)sender {
    [self.delegate topView:self didClickedDownload:sender];
    
}

- (void)didMoveToSuperview
{
    
    if (!self.config) {
        self.hidden = YES;
        self.config = YES;
        self.constraint = [self autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.superview];
        [self autoConstrainAttribute:ALAttributeVertical toAttribute:ALAttributeVertical ofView:self.superview];
        [self autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.superview];
        
        if(ISIPHONEX){
            [self autoSetDimension:ALDimensionHeight toSize:108];
            [self.discussCountLab autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self withOffset:40];
            [self.discussCountLab autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self withOffset:-31];
        }else{
            [self autoSetDimension:ALDimensionHeight toSize:64];
        }
    }
}

- (void)showWithAnimated
{
    //外部设置修改了
    WEAK_SELF;
    
    [self observeNotification:@"QWREADING_PICTURE" withBlock:^(__weak id self, NSNotification *notification) {
        KVO_STRONG_SELF;
        if (!notification) {
            return ;
        }
        
        QWReadingVC *vc = kvoSelf.ownerVC.currentVC;
        kvoSelf.pictureBtn.hidden = (!vc.isPicture || !vc.pictureName);
        
        if (!kvoSelf.pictureBtn.hidden) {
            [QWPictureIntroView showOnView:kvoSelf.ownerVC.view];
        }
    }];

    self.hidden = NO;
    [self.superview bringSubviewToFront:self];
    if(ISIPHONEX){
        self.constraint.constant = 108;
    }else{
        self.constraint.constant = 64;
    }
    [UIView animateWithDuration:.3f animations:^{
        STRONG_SELF;
        [self layoutIfNeeded];
    }];
    
    QWReadingVC *vc = self.ownerVC.currentVC;
    self.pictureBtn.hidden = (!vc.isPicture || !vc.pictureName);
    if (!self.pictureBtn.hidden) {
        [QWPictureIntroView showOnView:self.ownerVC.view];
    }
    if ([QWReadingManager sharedInstance].offline == true) {
//        self.aloudBtn.hidden = YES;
        self.downLoadBtnh.hidden = YES;
    }
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
