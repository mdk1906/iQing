//
//  NSObject+category.m
//  OneStore
//
//  Created by Aimy on 14-3-23.
//  Copyright (c) 2014年 OneStore. All rights reserved.
//

#import "NSObject+category.h"

@implementation NSObject (category)

static char associatedObjectNamesKey;

- (void)setAssociatedObjectNames:(NSMutableDictionary *)associatedObjectNames
{
    objc_setAssociatedObject(self, &associatedObjectNamesKey, associatedObjectNames,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)associatedObjectNames
{
    NSMutableDictionary *dict = objc_getAssociatedObject(self, &associatedObjectNamesKey);
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
        [self setAssociatedObjectNames:dict];
    }
    return dict;
}

- (void)objc_setAssociatedObject:(NSString *)propertyName value:(id)value policy:(objc_AssociationPolicy)policy
{
    NSString *key = self.associatedObjectNames[propertyName];
    if (!key) {
        key = propertyName;
        self.associatedObjectNames[propertyName] = propertyName;
    }
    objc_setAssociatedObject(self, (__bridge const void *)(key), value, policy);
}

- (id)objc_getAssociatedObject:(NSString *)propertyName
{
    NSString *key = self.associatedObjectNames[propertyName];
    return objc_getAssociatedObject(self, (__bridge const void *)(key));
}

- (void)objc_removeAssociatedObjects
{
    [self.associatedObjectNames removeAllObjects];
    objc_removeAssociatedObjects(self);
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"setValue %@ forUndefinedKey %@",value,key);
}

- (void)setNilValueForKey:(NSString *)key
{
    NSLog(@"setNilValue forKey %@",key);
}

@end
