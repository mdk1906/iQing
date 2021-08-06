//
//  QWReadingBottomStatusView.m
//  Qingwen
//
//  Created by Aimy on 7/6/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWReadingBottomStatusView.h"

#import "QWDeadtimeTimer.h"
#import "QWReadingConfig.h"
#import "QWReachability.h"

@interface QWReadingBottomStatusView ()

@property (strong, nonatomic) IBOutlet UILabel *networkLabel;
@property (strong, nonatomic) IBOutlet UILabel *progressLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIButton *batteryBtn;

@property (nonatomic, strong) QWDeadtimeTimer *timer;

@end

@implementation QWReadingBottomStatusView

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self updateStyle];

    self.progressLabel.text = nil;

    [UIDevice currentDevice].batteryMonitoringEnabled = YES;

    self.timer = [QWDeadtimeTimer new];
    WEAK_SELF;
    [self.timer runWithDeadtime:[NSDate distantFuture] andBlock:^(NSDateComponents *dateComponents) {
        STRONG_SELF;
        [self updateInfo];
    }];

    [self observeNotification:QWREADING_CHANGED withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }

        KVO_STRONG_SELF;
        [kvoSelf updateStyle];
    }];

    [self observeNotification:NotificationNetworkStatusChange withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }
        
        KVO_STRONG_SELF;
        kvoSelf.networkLabel.text = [QWReachability sharedInstance].currentNetStatusForDisplay;
    }];
}

- (void)updateStyle
{
    self.networkLabel.textColor = [QWReadingConfig sharedInstance].statusColor;
    self.progressLabel.textColor = [QWReadingConfig sharedInstance].statusColor;
    self.timeLabel.textColor = [QWReadingConfig sharedInstance].statusColor;
    [self.batteryBtn setTitleColor:[QWReadingConfig sharedInstance].statusColor forState:UIControlStateNormal];
    self.networkLabel.text = [QWReachability sharedInstance].currentNetStatusForDisplay;
    self.batteryBtn.tintColor = [QWReadingConfig sharedInstance].statusColor;
    [self.batteryBtn setBackgroundImage:[UIImage imageNamed:@"reading_battery_bg"] forState:UIControlStateNormal];    
}

- (void)updateInfo
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    self.timeLabel.text = currentDateStr ?: @"";
    [self.batteryBtn setTitle:[NSString stringWithFormat:@"%d%%", (int)(100 * [UIDevice currentDevice].batteryLevel)] forState:UIControlStateNormal];
}

- (void)updateWithProgress:(NSUInteger)progress
{
    self.progressLabel.text = [NSString stringWithFormat:@"%d%%",(int)progress];
}

- (void)dealloc
{
    [_timer stop];
}
@end
