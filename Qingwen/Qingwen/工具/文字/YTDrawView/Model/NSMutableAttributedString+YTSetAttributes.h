//
//  NSMutableAttributedString+YTSetAttributes.h
//  CoreTextDemo
//
//  Created by aron on 2018/7/17.
//  Copyright © 2018年 aron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSMutableAttributedString (YT_SetAttributes)

- (void)yt_setTextColor:(UIColor*)color;
- (void)yt_setTextColor:(UIColor*)color range:(NSRange)range;

- (void)yt_setFont:(UIFont*)font;
- (void)yt_setFont:(UIFont*)font range:(NSRange)range;

@end
