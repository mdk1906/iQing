//
//  QWDetailCategoryCVCell.m
//  Qingwen
//
//  Created by Aimy on 7/23/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWDetailCategoryCVCell.h"

@implementation QWDetailCategoryCVCell

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.categoryBtn.highlighted = highlighted;
}

@end
