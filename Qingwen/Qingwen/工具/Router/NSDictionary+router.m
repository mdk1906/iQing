//
//  NSDictionary+router.m
//  Qingwen
//
//  Created by mdk mdk on 2018/5/21.
//  Copyright (c) 2014年 Qingwen. All rights reserved.
//

#import "NSDictionary+router.h"

@implementation NSDictionary (router)

- (id)objectForCaseInsensitiveKey:(NSString *)aKey
{
    if (!aKey) {
        return nil;
    }
    
    __block id returnObj = nil;
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *tempKey = key;
        if ([tempKey compare:aKey options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            returnObj = obj;
            *stop = YES;
        }
    }];
    
    return returnObj;
}

@end
