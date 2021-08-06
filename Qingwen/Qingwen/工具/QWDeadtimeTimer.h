//
//  QWDeadtimeTimer.h
//  Qingwen
//
//  Created by Aimy on 14/12/24.
//  Copyright (c) 2014年 Qingwen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  为nil则表示已经倒计时完成了
 *
 *  @param dateComponents 
 */
typedef void(^QWDeadtimeTimerBlock)(NSDateComponents *dateComponents);

@interface QWDeadtimeTimer : NSObject

- (void)runWithDeadtime:(NSDate *)deadtime andBlock:(QWDeadtimeTimerBlock)aBlock;
- (void)stop;

@end
