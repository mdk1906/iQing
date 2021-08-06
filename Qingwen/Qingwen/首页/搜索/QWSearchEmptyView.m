//
//  QWSearchEmptyView.m
//  Qingwen
//
//  Created by Aimy on 7/30/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWSearchEmptyView.h"

@interface QWSearchEmptyView ()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@end

@implementation QWSearchEmptyView

- (void)awakeFromNib
{
    [super awakeFromNib];

    if (ISIPHONE3_5) {
        self.topConstraint.constant = 90;
    }
}

@end
