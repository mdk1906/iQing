//
//  QWKeychain.h
//  Qingwen
//
//  Created by Aimy on 14-6-29.
//  Copyright (c) 2014年 Qingwen. All rights reserved.
//

@interface QWKeychain : NSObject

+ (QWKeychain * __nonnull)sharedInstance;

/**
 *  只能set基本数据类型,NSNumber,NSString,NSData,NSDate等,不能set继承的Class
 *
 *  @param value
 *  @param type
 */
+ (void)setKeychainValue:(id<NSCopying, NSObject> __nullable)value forType:(id <NSCopying> __nonnull)type;
+ (id __nullable)getKeychainValueForType:(id <NSCopying> __nonnull)type;
+ (void)reset;

- (id __nullable)objectForKeyedSubscript:(id __nonnull)key;
- (void)setObject:(id __nullable)obj forKeyedSubscript:(id <NSCopying> __nonnull)key;

@end
