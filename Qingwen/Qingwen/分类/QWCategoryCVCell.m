//
//  QWCategoryCVCell.m
//  Qingwen
//
//  Created by Aimy on 7/1/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWCategoryCVCell.h"

@implementation QWCategoryCVCell

- (void)prepareForReuse
{
    self.imageView.image = nil;
    self.titleLabel.text = nil;
}

@end
