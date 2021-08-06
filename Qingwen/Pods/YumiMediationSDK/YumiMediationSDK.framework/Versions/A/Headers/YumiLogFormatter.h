//
//  YumiLogFormatter.h
//  Pods
//
//  Created by d on 26/5/2017.
//
//

#import "YumiLogEntry.h"
#import <Foundation/Foundation.h>

@protocol YumiLogFormatter <NSObject>

- (NSString *_Nonnull)logMessageWithEntry:(YumiLogEntry *_Nonnull)entry;

@end
