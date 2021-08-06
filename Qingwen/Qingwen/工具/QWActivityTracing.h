//
//  QWActivityTracing.h
//  Qingwen
//
//  Created by Aimy on 3/24/15.
//  Copyright (c) 2015 Qingwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QWActivityTracing : NSObject

+ (QWActivityTracing * __nonnull)sharedInstance;

/**
 *  往bug线程上设置当前显示的界面
 *
 */
- (void)setCurrentRunningIdentifier:(NSString * __nonnull)name;

/**
 *  模拟一个crash
 */
+ (void)crash;

@end
