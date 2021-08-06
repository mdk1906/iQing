//
//  UIView+create.h
//  Qingwen
//
//  Created by Aimy on 14-7-14.
//  Copyright (c) 2014年 Qingwen. All rights reserved.
//

//block tool
#import <Block-KVO/MTKObserving.h>
#import <PureLayout/PureLayout.h>
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/BlocksKit+UIKit.h>

@interface UIView (create)

/**
 *  快捷创建UIView及其子类,backgroundcolor=[uicolor clear]
 *
 *  @param frame 大小
 *
 *  @return kind of UIView
 */
+ (instancetype)viewWithFrame:(CGRect)frame;
/**
 *  快捷创建UIView及其子类
 *
 *  @param aNibName nib名称 = self.class
 *
 *  @return kind of UIView
 */
+ (instancetype)createWithNib;
/**
 *  快捷创建UIView及其子类
 *
 *  @param aNibName nib名称
 *
 *  @return kind of UIView
 */
+ (instancetype)createWithNibName:(NSString *)aXibName;
/**
 *  快捷创建UIView
 *
 *  @param aBundleName res bundle name，NibName = self.class
 *
 *  @return QWBaseVC
 */
+ (instancetype)createFromNibWithBundleName:(NSString *)aBundleName;
/**
 *  快捷创建UIView及其子类
 *
 *  @param aNibName nib名称
 *  @param aBundleName bundle名称
 *
 *  @return kind of UIView
 */
+ (instancetype)createWithNibName:(NSString *)aXibName bundleName:(NSString *)aBundleName;

/**
 *  生成一个frame = CGRectZero的 View，并设置translatesAutoresizingMaskIntoConstraints = NO
 *  backgroundcolor=[uicolor clear]
 *  @return view
 */
+ (instancetype)autolayoutView;

/**
 *  完全复制一个view
 *
 *  @param view 需要复制的view
 *
 *  @return 复制的view
 */
+ (UIView *)duplicate:(UIView *)view;

@end
