//
//  QWActivityTracing.m
//  Qingwen
//
//  Created by Aimy on 3/24/15.
//  Copyright (c) 2015 Qingwen. All rights reserved.
//

#import "QWActivityTracing.h"

#ifndef DEBUG

#import <Crashlytics/Crashlytics.h>

#endif

#define TRACING_THREAD_COUNT 5

@interface QWActivityTracing ()

@property (nonatomic, strong) NSMutableArray *tracingThreads;

@end

@implementation QWActivityTracing

DEF_SINGLETON(QWActivityTracing)

- (instancetype)init
{
    self = [super init];
    _tracingThreads = @[].mutableCopy;
    return self;
}

- (void)setCurrentRunningIdentifier:(NSString *)name
{
#ifndef DEBUG
    [_tracingThreads insertObject:name atIndex:0];

    if (_tracingThreads.count > TRACING_THREAD_COUNT) {
        [_tracingThreads removeLastObject];
    }

    NSString *tracingString = [_tracingThreads componentsJoinedByString:@"\n"];
    if (tracingString) {
        [[Crashlytics sharedInstance] setObjectValue:tracingString forKey:@"extraData"];
    }
#endif
}

+ (void)crash
{
#ifndef DEBUG
    [[Crashlytics sharedInstance] crash];
#endif
}

@end
