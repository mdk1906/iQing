//
//  QWUserDefaults.m
//  Qingwen
//
//  Created by Aimy on 7/3/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWUserDefaults.h"

@implementation QWUserDefaults

DEF_SINGLETON(QWUserDefaults);

+ (void)setValue:(id __nullable)anObject forKey:(NSString * __nonnull)aKey
{
    if ( ! aKey || ! [aKey isKindOfClass:[NSString class]]) {
        return ;
    }

    if (anObject)
    {
        [[NSUserDefaults standardUserDefaults] setObject:anObject forKey:aKey];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:aKey];
    }

    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id __nullable)getValueForKey:(NSString * __nonnull)aKey
{
    if ( ! aKey || ! [aKey isKindOfClass:[NSString class]]) {
        return nil;
    }

    return [[NSUserDefaults standardUserDefaults] objectForKey:aKey];
}

- (id __nullable)objectForKeyedSubscript:(NSString * __nonnull)key
{
    return [self.class getValueForKey:key];
}

- (void)setObject:(id __nullable)obj forKeyedSubscript:(NSString * __nonnull)key
{
    [self.class setValue:obj forKey:key];
}

@end
