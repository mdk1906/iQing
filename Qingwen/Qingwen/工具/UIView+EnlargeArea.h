//
//  UIView+EnlargeArea.h
//  Qingwen
//
//  Created by Aimy on 8/26/14.
//  Copyright (c) 2014 Qingwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (EnlargeArea)

@property (nonatomic) IBInspectable CGFloat enlargeEdge;

/**
 *  设置需要扩大的范围
 *
 *  @param top    上边
 *  @param right  右边
 *  @param bottom 底边
 *  @param left   左边
 */
- (void)setEnlargeEdgeWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left;

@end