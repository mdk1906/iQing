//
//  QWBaseTVCell.h
//  Qingwen
//
//  Created by Aimy on 7/1/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

//IB_DESIGNABLE
@interface QWBaseTVCell : UITableViewCell

@property (nonatomic, copy) IBInspectable UIImage *customAccessoryImage;

@property (nonatomic, strong) UIImage *placeholder;

- (void)onPressedCustomAccessoryImageView;

+ (CGFloat)heightForCellData:(id)data;

@end
