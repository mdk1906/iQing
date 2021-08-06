//
//  QWMyMissionTableViewCell.m
//  Qingwen
//
//  Created by qingwen on 2018/9/4.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import "QWMyMissionTableViewCell.h"

@interface QWMyMissionTableViewCell ()
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *rewardLab;
@property (weak, nonatomic) IBOutlet UILabel *additionalRewardLab;
@property (weak, nonatomic) IBOutlet UIImageView *finishImg;

@end

@implementation QWMyMissionTableViewCell



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}
-(void)setModel:(MyMissionVO *)model{
    if (model != _model) {
        _model = model;
    }
    _backView.layer.cornerRadius = 3;
    _backView.layer.masksToBounds = YES;
    _titleLab.text = model.task_name;
    _rewardLab.text = model.task_instruction;
    _additionalRewardLab.text = model.task_vip_instruction;
    
    CGFloat weight = UISCREEN_WIDTH - 24*2;
    UIView *huiView = [UIView new];
    huiView.frame = CGRectMake(10, 83, weight, 10);
    huiView.layer.cornerRadius = 5;
    huiView.layer.masksToBounds = YES;
    huiView.backgroundColor = HRGB(0xefefef);
    [_backView addSubview:huiView];
    
    UIImageView *img = [UIImageView new];
    CGFloat progress = (CGFloat)[model.done intValue]/[model.all intValue];
    img.frame = CGRectMake(0, 0, weight*progress, 10);
    img.image = [UIImage imageNamed:@"进度条完成"];
    [huiView addSubview:img];
    
    UILabel *progressLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, weight, 10)];
    progressLab.textColor = HRGB(0x6B6B6B);
    progressLab.font = [UIFont systemFontOfSize:8];
    progressLab.text = [NSString stringWithFormat:@"%@/%@",model.done,model.all];
    progressLab.textAlignment = 1;
    [huiView addSubview:progressLab];
    if (model.status == [NSNumber numberWithInteger:1]) {
        _finishImg.image = [UIImage imageNamed:@"已完成"];
        
    }
    else{
        _finishImg.image = [UIImage imageNamed:@"待完成"];
    }
    
    
    
}
-(void)createProgress{
    
}
@end
