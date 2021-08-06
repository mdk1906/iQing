//
//  QWPictureGestureDelegate.m
//  Qingwen
//
//  Created by Aimy on 8/3/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWPictureGestureDelegate.h"

#import "QWPictureVC.h"

@interface QWPictureVC ()

@property (nonatomic) BOOL showSetting;

- (void)backToReadingVC;
- (void)showSettingViews;
- (void)hideAllSettingViews;

@end

@interface QWPictureGestureDelegate () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet QWPictureVC *ownerPVC;

@end

@implementation QWPictureGestureDelegate

- (IBAction)onTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        if (self.ownerPVC.showSetting) {
            [self.ownerPVC hideAllSettingViews];
            self.ownerPVC.showSetting = NO;
        }
        else {
            [self.ownerPVC showSettingViews];
            self.ownerPVC.showSetting = YES;
        }
    }
    else if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            [self.ownerPVC backToReadingVC];
        }
    }
}

@end
