//
//  QWActivityWebVC.h
//  Qingwen
//
//  Created by mumu on 2017/4/24.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWWebVC.h"

@interface QWActivityWebVC : QWWebVC

@property (assign) BOOL needLogin;

- (void)getCookie;
@end
