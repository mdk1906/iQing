//
//  QWQWMymedelTableViewCell.m
//  Qingwen
//
//  Created by qingwen on 2018/9/6.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import "QWQWMymedelTableViewCell.h"

@interface QWQWMymedelTableViewCell ()
{
    UIImageView *wearImg;
}
@end
@implementation QWQWMymedelTableViewCell

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
-(void)setModel:(QWMymedelVO *)model{
    if (model != _model) {
        _model = model;
    }
    CGFloat left = (UISCREEN_WIDTH-240)/3;
    for (int i =0; i<model.dataArr.count; i++) {
        NSMutableDictionary *dict = model.dataArr[i];
        UIImageView *headImg = [UIImageView new];
        headImg.frame = CGRectMake(left/2+i*left+i*80, 10, 80, 80);
        headImg.userInteractionEnabled = YES;
        
        headImg.layer.cornerRadius = 40;
        headImg.layer.masksToBounds = YES;
        [headImg qw_setImageUrlString:[QWConvertImageString convertPicURL:model.avatar imageSizeType:QWImageSizeTypeCover] placeholder:[UIImage imageNamed:@"mycenter_logo2"] animation:YES];
//        [self.contentView addSubview:headImg];
        
        
        
        UIImageView *img = [UIImageView new];
        img.frame = CGRectMake(left/2+i*left+i*80, 20, 80, 24);
        img.tag = i;
        img.userInteractionEnabled = YES;
        if ([model.obtain intValue] == 1) {
            //获取
            [img qw_setImageUrlString:dict[@"medal_icon"] placeholder:[UIImage imageNamed:@"mycenter_logo2"] animation:nil];
        }
        else{
           //未获取
            [img qw_setImageUrlString:dict[@"medal_black_icon"] placeholder:[UIImage imageNamed:@"mycenter_logo2"] animation:nil];
        }
//        [img addTarget:self action:@selector(imgBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:img];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgBtnClick:)];
        [img addGestureRecognizer:tap];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(UISCREEN_WIDTH/3*i, kMaxY(img.frame)+5, UISCREEN_WIDTH/3, 20)];
        titleLab.textColor = HRGB(0x5F5F5F);
        titleLab.font = [UIFont systemFontOfSize:14];
        titleLab.text = dict[@"medal_name"];
        titleLab.textAlignment = 1;
        [self.contentView addSubview:titleLab];
        
        
        wearImg = [UIImageView new];
        wearImg.frame = CGRectMake(kMaxX(img.frame)-20, 5, 36, 16);
        wearImg.image = [UIImage imageNamed:@"佩戴中"];
        wearImg.hidden = YES;
        [wearImg removeFromSuperview];
        [self.contentView addSubview:wearImg];
        if ([[NSString stringWithFormat:@"%@",dict[@"medal_id"]] isEqualToString:model.waerMedalId]) {
            //佩戴中
            wearImg.hidden = NO;
        }
        else{
            wearImg.hidden = YES;
        }
    }
}
-(void)imgBtnClick:(UITapGestureRecognizer *)btn{
    NSDictionary *dict = _model.dataArr[btn.view.tag];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"imgBtnClick" object:dict];
}
@end
