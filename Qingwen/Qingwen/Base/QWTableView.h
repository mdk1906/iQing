//
//  QWTableView.h
//  Qingwen
//
//  Created by Aimy on 7/23/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QWEmptyView.h"

@interface QWTableView : UITableView

@property (nonatomic, strong, readonly) QWEmptyView *emptyView;
@property (nonatomic) IBInspectable BOOL useDarkEmptyView;

@end
