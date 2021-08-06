//
//  QWReadingTopNameView.m
//  Qingwen
//
//  Created by mumu on 16/12/19.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import "QWReadingTopNameView.h"

@interface QWReadingTopNameView ()

@property (strong, nonatomic) IBOutlet UILabel *chapterNameLabel;


@end

@implementation QWReadingTopNameView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self updateStyle];
    
    self.chapterNameLabel.text = nil;
    WEAK_SELF;
    [self observeNotification:QWREADING_CHANGED withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }
        
        KVO_STRONG_SELF;
        [kvoSelf updateStyle];
    }];
}

- (void)updateStyle {
    self.chapterNameLabel.textColor = [QWReadingConfig sharedInstance].statusColor;
}

- (void)updateWithChapterTitle:(NSString *)title {
    
    self.chapterNameLabel.text = title;
}
@end
