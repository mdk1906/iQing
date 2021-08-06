//
//  QWGenerateTool.m
//  Qingwen
//
//  Created by mumu on 17/3/6.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWRandomGenerateTool.h"

#define kRandomLength 10
static const NSString *kRandomAlphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

@implementation QWRandomGenerateTool

+ (NSString *)generateRandomString {
    NSMutableString *randomString = [NSMutableString stringWithCapacity:kRandomLength];
    @autoreleasepool {
        // insert code here...
        for (int i = 0; i < kRandomLength; i++) {
            [randomString appendFormat: @"%C", [kRandomAlphabet characterAtIndex:arc4random_uniform((u_int32_t)[kRandomAlphabet length])]];
        }
        NSLog(@"randomString = %@", randomString);
    }
    return randomString;
}

+ (NSNumber *)generateRandomNumber {
    return @(arc4random());
}

+ (NSDate *)gengerateRandomDate {
    long long second = arc4random() % 10000000000 + 1000 * 3600 * 24;
    
    return [NSDate dateWithTimeIntervalSinceNow:second];
}

+ (bool)generateRandomBoolen {
    int random = arc4random() % 2;
    if (random == 0) {
        return false;
    } else {
        return YES;
    }
}
//
//
///**
// 自动生成Model 并转换为Json
// */
//+ (NSString *)generateRandomJsonWithModel:(id)model {
//    
//}
@end
