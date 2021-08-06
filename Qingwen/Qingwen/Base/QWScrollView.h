//
//  QWScrollView.h
//  Qingwen
//
//  Created by Aimy on 8/8/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QWEmptyView.h"

@interface QWScrollView : UIScrollView

@property (nonatomic, strong, readonly) QWEmptyView *emptyView;
@property (nonatomic) IBInspectable BOOL useDarkEmptyView;

@end
