//
//  YTBaseDataItem.h
//  CoreTextDemo
//
//  Created by aron on 2018/7/13.
//  Copyright © 2018年 aron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^ClickActionHandler)(id obj);

@interface YTBaseDataItem : NSObject

@property (nonatomic, strong) NSMutableArray<NSValue *> *clickableFrames;
@property (nonatomic, copy) ClickActionHandler clickActionHandler;

- (void)addFrame:(CGRect)frame;
- (BOOL)containsPoint:(CGPoint)point;

@end
