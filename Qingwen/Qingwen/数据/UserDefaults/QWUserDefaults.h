//
//  QWUserDefaults.h
//  Qingwen
//
//  Created by Aimy on 7/3/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWUserDefaultsDefine.h"

@interface QWUserDefaults : NSObject

+ (QWUserDefaults * __nonnull)sharedInstance;

/**
 *  存储数据到userdefault
 *
 *  @param anObject 数据
 *  @param aKey     标识
 */
+ (void)setValue:(id __nullable)anObject forKey:(NSString * __nonnull)aKey;
/**
 *  从userdefault获取数据
 *
 *  @param aKey 标识
 *
 *  @return 数据
 */
+ (id __nullable)getValueForKey:(NSString * __nonnull)aKey;

- (id __nullable)objectForKeyedSubscript:(NSString * __nonnull)key;
- (void)setObject:(id __nullable)obj forKeyedSubscript:(NSString * __nonnull)key;

@end
