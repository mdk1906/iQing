//
//  UITableView+loadingMore.m
//  Qingwen
//
//  Created by Aimy on 9/15/14.
//  Copyright (c) 2014 Qingwen. All rights reserved.
//

#import "UITableView+loadingMore.h"
#import "UIView+create.h"

@implementation UITableView (loadingMore)

- (void)showLoadingMore
{
    [self showLoadingMoreWithHeight:60.f andEdgeInsets:UIEdgeInsetsZero];
}

- (void)showLoadingMoreWithHeight:(CGFloat)aHeight andEdgeInsets:(UIEdgeInsets)aInsets
{
    CGFloat width = self.frame.size.width;
    CGFloat height = aHeight;
    if (self.tableFooterView == nil || self.tableFooterView.tag == 999) {
        UIView *footerView = [UIView viewWithFrame:CGRectMake(0, 0, width, height)];
        
        UIActivityIndicatorView *indicatorView = [UIActivityIndicatorView autolayoutView];
        [indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [indicatorView startAnimating];
        [footerView addSubview:indicatorView];
        
        UILabel *label = [UILabel autolayoutView];
        label.tag = 999;
        [label setBackgroundColor:[UIColor clearColor]];
        [label setText:@"正在加载"];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]];
        [label setFont:[UIFont systemFontOfSize:15.0]];
        [footerView addSubview:label];
        self.tableFooterView = footerView;
        
        [footerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[indicatorView][label]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(indicatorView, label)]];
        
        [footerView addConstraint:[NSLayoutConstraint constraintWithItem:indicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:footerView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:aInsets.top - aInsets.bottom]];
        
        [footerView addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:footerView attribute:NSLayoutAttributeCenterX multiplier:1.f constant:aInsets.left - aInsets.right]];
    }
}

@end
