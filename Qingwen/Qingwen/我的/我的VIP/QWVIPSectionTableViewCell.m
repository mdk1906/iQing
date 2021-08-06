//
//  QWVIPSectionTableViewCell.m
//  Qingwen
//
//  Created by qingwen on 2018/10/17.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import "QWVIPSectionTableViewCell.h"
@interface QWVIPSectionTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *bookImgView;
@property (weak, nonatomic) IBOutlet UILabel *bookNameLab;
@property (weak, nonatomic) IBOutlet UILabel *bookAuthorLab;
@property (weak, nonatomic) IBOutlet UILabel *bookContontLab;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *vipImg;

@end
@implementation QWVIPSectionTableViewCell

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
-(void)setModel:(BookVO *)model{
    if (model != _model) {
        _model = model;
    }
    _backView.layer.cornerRadius = 2;
    _backView.layer.masksToBounds = YES;
    _backView.layer.shadowColor = HRGB(0xC3C3C3).CGColor;
    _backView.layer.shadowOpacity = 0.5f;
    _backView.layer.shadowRadius = 4.f;
    _backView.layer.shadowOffset = CGSizeMake(0,0);
    self.contentView.backgroundColor = HRGB(0xf9f9f9);
    self.backView.layer.cornerRadius = 3;
    self.backView.layer.masksToBounds = YES;
    [_bookImgView qw_setImageUrlString:model.coverImageString placeholder:nil animation:YES];
    _bookNameLab.text = model.title;
    UserVO *author = model.author.firstObject;
    _bookAuthorLab.text = [NSString stringWithFormat:@"作者：%@",author.username];
    _bookContontLab.text = [NSString stringWithFormat:@"简介：%@",model.intro];
    CGFloat labelHeight = [_bookContontLab sizeThatFits:CGSizeMake(_bookContontLab.frame.size.width, MAXFLOAT)].height;
    
    NSInteger count = (labelHeight) / _bookContontLab.font.lineHeight;
    if (count == 1) {
        _bookContontLab.frame = CGRectMake(kMaxX(_bookImgView.frame)+10, 110-10-20, UISCREEN_WIDTH-20-98, 20);
    }
    
    if ([model.is_vip isEqualToString:@"1"]) {
        //是vip
//        [_vipImg qw_setImageUrlString:model.vip_mark placeholder:nil animation:YES];
        _vipImg.image = [UIImage imageNamed:@"vip_work"];
    }
    else{
        //不是vip
        UIButton *countBtn = [UIButton new];
        [_bookImgView addSubview:countBtn];
        countBtn.frame = CGRectMake(_bookImgView.frame.size.width-50, 0, 50, 15);
//        countLab.backgroundColor =
        [countBtn setBackgroundImage:[UIImage imageNamed:@"list_count_bg"] forState:0];
        [countBtn setTitle:[NSString stringWithFormat:@" %@ ",[QWHelper countToString:model.count]] forState:UIControlStateNormal];
        countBtn.titleLabel.font = FONT(10);
        [countBtn setTitleColor:[UIColor whiteColor] forState:0];
        _vipImg.hidden = YES;
        
    }
}
@end
