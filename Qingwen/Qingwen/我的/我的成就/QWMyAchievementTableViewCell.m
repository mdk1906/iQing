//
//  QWMyAchievementTableViewCell.m
//  Qingwen
//
//  Created by qingwen on 2018/9/7.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import "QWMyAchievementTableViewCell.h"

@interface QWMyAchievementTableViewCell ()
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *rewardLab;
@property (weak, nonatomic) IBOutlet UILabel *additionalRewardLab;
@property (weak, nonatomic) IBOutlet UIImageView *finishImg;

@end
@implementation QWMyAchievementTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
