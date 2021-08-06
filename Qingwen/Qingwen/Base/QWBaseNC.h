//
//  QWBaseNC.h
//  Qingwen
//
//  Created by Aimy on 7/1/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QWNCDelegate.h"

@interface QWBaseNC : UINavigationController

@property (nonatomic, strong) QWNCDelegate *customAnimationDelegate;

@end
