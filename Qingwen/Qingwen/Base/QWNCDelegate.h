//
//  QWNCDelegate.h
//  Qingwen
//
//  Created by Aimy on 7/30/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QWNCDelegate : NSObject <UINavigationControllerDelegate>

//进度动画
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactivePopTransition;
//nc
@property (nonatomic, weak) UINavigationController *ownerNC;

@end
