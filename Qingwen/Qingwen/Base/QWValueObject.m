//
//  QWValueObject.m
//  Qingwen
//
//  Created by Aimy on 7/4/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWValueObject.h"

@implementation QWValueObject

- (instancetype)init
{
    if (self = [super init]) {
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            [JSONModel setGlobalKeyMapper:[[JSONKeyMapper alloc] initWithDictionary:@{@"id": @"nid", @"description": @"desc",@"switch":@"toggle"}]];
        });
    }
    return self;
}

/**
 *  重写父类方法，默认可选
 *
 *  @param propertyName 属性名称
 *
 *  @return bool
 */
+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

+ (instancetype)voWithDict:(NSDictionary *)aDict
{
    if (![aDict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    return [[self alloc] initWithDictionary:aDict error:NULL];
}

+ (instancetype)voWithJson:(NSString *)aJson
{
    if (![aJson isKindOfClass:[NSString class]]) {
        return nil;
    }

    return [[self alloc] initWithString:aJson error:NULL];
}

@end
