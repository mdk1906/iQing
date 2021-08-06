//
//  YTAttachmentItem.m
//  CoreTextDemo
//
//  Created by aron on 2018/7/12.
//  Copyright © 2018年 aron. All rights reserved.
//

#import "YTAttachmentItem.h"

@implementation YTAttachmentItem

- (UIImage *)image {
    if ([_attachment isKindOfClass:[UIImage class]]) {
        return _attachment;
    }
    return nil;
}

- (UIView *)view {
    if ([_attachment isKindOfClass:[UIView class]]) {
        return _attachment;
    }
    return nil;
}

@end
