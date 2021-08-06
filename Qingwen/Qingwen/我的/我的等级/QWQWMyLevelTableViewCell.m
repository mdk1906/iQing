//
//  QWQWMyLevelTableViewCell.m
//  Qingwen
//
//  Created by qingwen on 2018/10/15.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import "QWQWMyLevelTableViewCell.h"
@interface QWQWMyLevelTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *levellab;
@property (weak, nonatomic) IBOutlet UIImageView *levelImg;

@end
@implementation QWQWMyLevelTableViewCell

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
-(void)setModel:(QWMyLevelVO *)model{
    if (model != _model) {
        _model = model;
    }
    self.levellab.text = model.level_brief_text;
    self.levelImg.backgroundColor = HRGB(0xffac46);
    self.levelImg.layer.masksToBounds = YES;
    self.levelImg.layer.cornerRadius = 2;
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 42, 20)];
    titleLab.textColor = HRGB(0xffffff);
    titleLab.font = [UIFont systemFontOfSize:14];
    titleLab.text = model.level_name;
    titleLab.textAlignment = 1;
    [self.levelImg addSubview:titleLab];
}
@end
