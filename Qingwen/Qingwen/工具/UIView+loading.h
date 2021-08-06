//
//  UIView+loading.h
//  Qingwen
//
//  Created by Aimy on 14/10/30.
//  Copyright (c) 2014年 Qingwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (loading)

#pragma mark - loading

/**
 *  功能:显示loading
 */
- (void)showLoading;

/**
 *  功能:显示loading
 */
- (void)showLoadingWithMessage:(NSString *)message;
- (void)showLoadingWithMessageAndAnimate:(NSString *)message;
/**
 *  功能:显示loading
 */
- (void)showLoadingWithMessage:(NSString *)message hideAfter:(NSTimeInterval)second;

/**
 *  功能:显示loading
 */
- (void)showLoadingWithMessage:(NSString *)message onView:(UIView *)aView hideAfter:(NSTimeInterval)second;

/**
 *  功能:隐藏loading
 */
- (void)hideLoading;

/**
 *  功能:隐藏loading
 */
- (void)hideLoadingOnView:(UIView *)aView;

@end
