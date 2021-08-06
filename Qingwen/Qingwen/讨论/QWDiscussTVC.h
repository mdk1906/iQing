//
//  QWDiscussTVC.h
//  Qingwen
//
//  Created by Aimy on 8/11/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBaseVC.h"

#import "QWTableView.h"

@interface QWDiscussTVC : QWBaseVC

@property (strong, nonatomic, readonly) QWTableView *tableView;
@property (nonatomic, copy) NSString *discussUrl;
@property (assign) BOOL isChild;  //是否作为子控制器
@property (nonatomic,copy) NSString *inId;
- (void)toNewDiscuss;
- (void)getData;

@end
