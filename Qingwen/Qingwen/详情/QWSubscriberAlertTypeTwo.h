//
//  QWSubscriberAlertTypeTwo.h
//  Qingwen
//
//  Created by mumu on 16/9/30.
//  Copyright © 2016年 mumu. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "QWSubscriberAlertTypeOne.h"
//#import "ChapterVO.h"
@interface QWSubscriberAlertTypeTwo : UIView

+ (instancetype)alertViewWithButtonAction:(QWSubscriberActionBlock)actionBlock;

- (void)updateAlertWithChapter:(ChapterVO *)chapter;

- (void)show;

@end
