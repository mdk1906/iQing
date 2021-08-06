//
//  QWSendDanmuButton.m
//  Qingwen
//
//  Created by mumu on 16/12/27.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import "QWSendDanmuButton.h"

@interface QWSendDanmuButton ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UILabel *countLabel;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleLeading;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *countLabelTrailing;

@end

@implementation QWSendDanmuButton

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)update {
    self.borderColor = [QWReadingConfig sharedInstance].readingColor;
    self.titleLabel.textColor = [QWReadingConfig sharedInstance].readingColor;
    
    [self updateCountLabelColor];
    
    if ([QWReadingConfig sharedInstance].showDanmu) {
        self.titleLeading.constant = 0;
        self.countLabel.hidden = true;
        self.titleLabel.text = @"发送弹幕";
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    } else {
        self.countLabel.hidden = false;
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        
        if (self.count.integerValue == 0) {
            self.titleLeading.constant = 0;
            self.titleLabel.text = @"开启弹幕";
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            self.countLabel.hidden = true;
        }
        else if (self.count.integerValue < 10) {
            self.titleLabel.text = @"开启弹幕";
            self.titleLeading.constant = 10;
            
            self.countLabel.text = [NSString stringWithFormat:@" %@ ",self.count.stringValue];
            self.countLabelTrailing.constant = 10;
        }
        else if (self.count.integerValue < 100) {
            self.titleLabel.text = @"开启弹幕";
            self.titleLeading.constant = 7;
            
            self.countLabel.text = [NSString stringWithFormat:@" %@ ",self.count.stringValue];
            self.countLabelTrailing.constant = 7;
        }
        else {
            self.titleLabel.text = @"开启弹幕";
            self.titleLeading.constant = 7;
            
            self.countLabel.text = @" 99 ";
            self.countLabelTrailing.constant = 7;
        }
    }
    [self layoutIfNeeded];
}
- (void)updateCountLabelColor
{
    switch ([QWReadingConfig sharedInstance].readingBG) {
        case QWReadingBGDefault:
            self.countLabel.textColor = [UIColor whiteColor];
            self.countLabel.backgroundColor = HRGB(0x99825A);
            break;
        case QWReadingBGBlack:
            self.countLabel.textColor = HRGB(0xcccccc);
            self.countLabel.backgroundColor = HRGB(0x61615E);
            break;
        case QWReadingBGGreen:
            self.countLabel.textColor = [UIColor whiteColor];
            self.countLabel.backgroundColor = HRGB(0x86bd86);
            break;
        case QWReadingBGPink:
            self.countLabel.textColor = [UIColor whiteColor];
            self.countLabel.backgroundColor = HRGB(0xD46D85);
            break;
        default:
            self.countLabel.textColor = [UIColor whiteColor];
            self.countLabel.backgroundColor = HRGB(0x99825A);
            break;
    }
}
@end
