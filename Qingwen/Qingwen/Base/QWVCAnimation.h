//
//  QWVCAnimation.h
//  Qingwen
//
//  Created by Aimy on 7/30/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QWVCAnimation : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, readonly, getter=isPush) BOOL push;

+ (instancetype)animationWithType:(BOOL)push;

@end