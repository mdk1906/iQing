//
//  RichTextData.m
//  CoreTextDemo
//
//  Created by aron on 2018/7/12.
//  Copyright © 2018年 aron. All rights reserved.
//

#import "RichTextData.h"

@implementation RichTextData

- (NSMutableArray *)images {
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
}

- (void)dealloc {
    if (_ctFrame != nil) {
        CFRelease(_ctFrame);
    }
}

@end
