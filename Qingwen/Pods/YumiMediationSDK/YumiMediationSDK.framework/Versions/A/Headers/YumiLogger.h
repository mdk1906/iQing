//
//  YumiLogger.h
//  Pods
//
//  Created by d on 26/5/2017.
//
//

#import "YumiLogFormatter.h"
#import "YumiLogHook.h"
#import "YumiLogLevel.h"
#import <Foundation/Foundation.h>

#define YumiStdLogger [YumiLogger stdLogger]

NS_ASSUME_NONNULL_BEGIN

@interface YumiLogger : NSObject

+ (instancetype)stdLogger;

+ (instancetype)loggerWithPrefix:(NSString *)prefix level:(YumiLogLevel)level;

- (void)setLevel:(YumiLogLevel)level;
- (void)setFormatter:(id<YumiLogFormatter>)formatter;

// set metadata that will always be logged
- (void)setMetadata:(NSDictionary<NSString *, id> *)metadata;

- (void)addHook:(id<YumiLogHook>)hook;

- (void)log:(YumiLogLevel)level message:(NSString *)message;
- (void)log:(YumiLogLevel)level message:(NSString *)message extras:(NSDictionary<NSString *, id> *_Nullable)extras;

- (void)debug:(NSString *)message;
- (void)info:(NSString *)message;
- (void)warning:(NSString *)message;
- (void)error:(NSString *)message;

- (void)debug:(NSString *)message extras:(NSDictionary<NSString *, id> *)extras;
- (void)info:(NSString *)message extras:(NSDictionary<NSString *, id> *)extras;
- (void)warning:(NSString *)message extras:(NSDictionary<NSString *, id> *)extras;
- (void)error:(NSString *)message extras:(NSDictionary<NSString *, id> *)extras;

@end

NS_ASSUME_NONNULL_END
