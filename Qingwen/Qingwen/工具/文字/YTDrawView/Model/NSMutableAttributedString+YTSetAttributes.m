//
//  NSMutableAttributedString+YTSetAttributes.m
//  CoreTextDemo
//
//  Created by aron on 2018/7/17.
//  Copyright © 2018年 aron. All rights reserved.
//

#import "NSMutableAttributedString+YTSetAttributes.h"
#import <CoreText/CoreText.h>

@implementation NSMutableAttributedString (YT_SetAttributes)


- (void)yt_setTextColor:(UIColor*)color {
    [self yt_setTextColor:color range:NSMakeRange(0, [self length])];
}

- (void)yt_setTextColor:(UIColor*)color range:(NSRange)range {
    if (color.CGColor) {
        [self removeAttribute:(NSString *)kCTForegroundColorAttributeName range:range];
        
        [self addAttribute:(NSString *)kCTForegroundColorAttributeName
                     value:(id)color.CGColor
                     range:range];
    }
    
}


- (void)yt_setFont:(UIFont*)font {
    [self yt_setFont:font range:NSMakeRange(0, [self length])];
}

- (void)yt_setFont:(UIFont*)font range:(NSRange)range {
    if (font) {
        [self removeAttribute:(NSString*)kCTFontAttributeName range:range];
        
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, nil);
        if (nil != fontRef) {
            [self addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:range];
            CFRelease(fontRef);
        }
    }
}

@end
