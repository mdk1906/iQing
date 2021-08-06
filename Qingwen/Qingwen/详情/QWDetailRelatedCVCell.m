//
//  QWDetailRelatedCVCell.m
//  Qingwen
//
//  Created by Aimy on 7/3/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWDetailRelatedCVCell.h"

#import "BookVO.h"

@interface QWDetailRelatedCVCell ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation QWDetailRelatedCVCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.placeholder = [UIImage imageNamed:@"placeholder114x152"];
}

- (void)updateWithBookVO:(BookVO *)book
{
    self.titleLabel.text = book.title;

    [self.imageView qw_setImageUrlString:[QWConvertImageString convertPicURL:book.cover imageSizeType:QWImageSizeTypeCoverThumbnail] placeholder:self.placeholder animation:YES];
}

@end
