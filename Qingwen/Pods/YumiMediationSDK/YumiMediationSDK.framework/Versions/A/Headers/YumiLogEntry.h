//
//  YumiLogEntry.h
//  Pods
//
//  Created by d on 26/5/2017.
//
//

#import "YumiLogLevel.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiLogEntry : NSObject

@property (nonatomic, readonly) NSString *prefix;
@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) NSDate *time;
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, id> *extras;
@property (nonatomic, assign, readonly) YumiLogLevel level;

+ (instancetype)entryWithLevel:(YumiLogLevel)level
                          time:(NSDate *)time
                        prefix:(NSString *)prefix
                       message:(NSString *)message
                        extras:(NSDictionary<NSString *, id> *_Nullable)extras;

@end

NS_ASSUME_NONNULL_END
