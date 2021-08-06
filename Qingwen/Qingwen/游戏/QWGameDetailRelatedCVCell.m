//
//  QWGameDetailRelatedCVCell.m
//  Qingwen
//
//  Created by Aimy on 7/3/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWGameDetailRelatedCVCell.h"

#import "BookVO.h"

@interface QWGameDetailRelatedCVCell ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *countBtn;

@end

@implementation QWGameDetailRelatedCVCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.placeholder = [UIImage imageNamed:@"placeholder114x152"];
}

- (void)updateWithBookVO:(BookVO *)book
{
    self.titleLabel.text = book.title;

    [self.imageView qw_setImageUrlString:[QWConvertImageString convertPicURL:book.cover imageSizeType:QWImageSizeTypeGameCover] placeholder:self.placeholder animation:YES];
    if (book.cost_price.integerValue > 0) {
        [self.countBtn setTitle:[NSString stringWithFormat:@"%@重石",book.cost_price] forState:UIControlStateNormal];
    }else {
        self.countBtn.hidden = true;
    }
    
}

@end
