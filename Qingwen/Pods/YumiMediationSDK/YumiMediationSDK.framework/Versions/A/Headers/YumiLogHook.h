//
//  YumiLogHook.h
//  Pods
//
//  Created by d on 26/5/2017.
//
//

#import "YumiLogEntry.h"
#import <Foundation/Foundation.h>

@protocol YumiLogHook <NSObject>

- (void)fire:(YumiLogEntry *_Nonnull)entry;

@end
