//
//  YTBaseDataItem.m
//  CoreTextDemo
//
//  Created by aron on 2018/7/13.
//  Copyright © 2018年 aron. All rights reserved.
//

#import "YTBaseDataItem.h"

@implementation YTBaseDataItem

- (NSMutableArray<NSValue *> *)clickableFrames {
    if (!_clickableFrames) {
        _clickableFrames = [NSMutableArray arrayWithCapacity:2];
    }
    return _clickableFrames;
}

- (void)addFrame:(CGRect)frame {
    [self.clickableFrames addObject:[NSValue valueWithCGRect:frame]];
}

- (BOOL)containsPoint:(CGPoint)point {
    for (NSValue *frameValue in self.clickableFrames) {
        if (CGRectContainsPoint(frameValue.CGRectValue, point)) {
            return YES;
        }
    }
    return false;
}

@end
