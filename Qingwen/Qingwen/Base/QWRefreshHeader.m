//
//  QWRefreshHeader.m
//  Qingwen
//
//  Created by mumu on 17/3/27.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWRefreshHeader.h"

@implementation QWRefreshHeader

- (void)prepare
{
    [super prepare];
    
    self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.automaticallyChangeAlpha = true;
}

@end
