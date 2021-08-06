//
//  QWTextField.m
//  Qingwen
//
//  Created by Aimy on 8/13/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWTextField.h"

@implementation QWTextField

- (void)setLeftViewInset:(CGFloat)leftViewInset
{
    self.leftViewMode = UITextFieldViewModeAlways;
    self.leftView = [UIView viewWithFrame:CGRectMake(0, 0, leftViewInset, PX1_LINE)];
}

- (CGFloat)leftViewInset
{
    return 0;
}

@end
