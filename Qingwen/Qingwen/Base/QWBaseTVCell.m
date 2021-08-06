//
//  QWBaseTVCell.m
//  Qingwen
//
//  Created by Aimy on 7/1/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBaseTVCell.h"

@implementation QWBaseTVCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:HRGBA(0x999999, 0.2f)]];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:HRGBA(0x999999, 0.2f)]];
    return self;
}

- (void)setCustomAccessoryImage:(UIImage *)customAccessoryImage
{
    _customAccessoryImage = customAccessoryImage;
    if (customAccessoryImage) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:customAccessoryImage];
        imageView.enlargeEdge = 20.f;
        imageView.userInteractionEnabled = YES;

        WEAK_SELF;
        [imageView bk_whenTapped:^{
            STRONG_SELF;
            [self onPressedCustomAccessoryImageView];
        }];
        self.accessoryView = imageView;
    }
    else {
        self.accessoryView = nil;
    }
}

- (void)onPressedCustomAccessoryImageView
{

}

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType
{
    if (accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        [self setCustomAccessoryImage:self.customAccessoryImage];
    }
    else {
        self.accessoryView = nil;
        [super setAccessoryType:accessoryType];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+ (CGFloat)heightForCellData:(id)data
{
    return 0;
}

@end
