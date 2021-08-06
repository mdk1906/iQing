//
//  QWKeychain.m
//  Qingwen
//
//  Created by Aimy on 14-6-29.
//  Copyright (c) 2014年 Qingwen. All rights reserved.
//

#import "QWKeychain.h"

#import "KeychainItemWrapper.h"

#define QW_KEYCHAIN_IDENTITY @"Qingwen"

#define QW_KEYCHAIN_GROUP @"group.iqing"

#define QW_KEYCHAIN_DICT_ENCODE_KEY_VALUE @"QW_KEYCHAIN_DICT_ENCODE_KEY_VALUE"

@interface QWKeychain ()

@property (nonatomic, strong) KeychainItemWrapper *item;

@property (nonatomic, strong) NSArray *commonClasses;

@end

@implementation QWKeychain

DEF_SINGLETON(QWKeychain);

- (instancetype)init
{
    if (self = [super init]) {
        self.commonClasses = @[[NSNumber class],
                               [NSString class],
                               [NSMutableString class],
                               [NSData class],
                               [NSMutableData class],
                               [NSDate class],
                               [NSValue class]];

        [self setup];
    }
    return self;
}

- (void)setup
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:QW_KEYCHAIN_IDENTITY accessGroup:nil];
    self.item = wrapper;
}

- (id __nullable)objectForKeyedSubscript:(id __nonnull)key
{
    return [self.class getKeychainValueForType:key];
}

- (void)setObject:(id __nullable)obj forKeyedSubscript:(id <NSCopying> __nonnull)key;
{
    [self.class setKeychainValue:obj forType:key];
}

+ (void)setKeychainValue:(id<NSCopying, NSObject> __nullable)value forType:(id <NSCopying> __nonnull)type
{
    QWKeychain *keychain = [QWKeychain sharedInstance];

    __block BOOL find = NO;
    [keychain.commonClasses enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Class class = obj;
        if ([value isKindOfClass:class]) {
            find = YES;
            *stop = YES;
        }

    }];

    if (!find && value) {
        NSLog(@"error set keychain type [%@], value [%@]",type ,value);
        return ;
    }

    if (!type || !keychain.item) {
        return ;
    }

    id data = [keychain.item objectForKey:(__bridge id)kSecValueData];
    NSMutableDictionary *dict = nil;
    if (data && [data isKindOfClass:[NSMutableData class]]) {
        dict = [keychain decodeDictWithData:data];
    }

    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }

    if (value) {
        dict[type] = value;
    }
    else {
        [dict removeObjectForKey:type];
    }

    data = [keychain encodeDict:dict];

    if (data && [data isKindOfClass:[NSMutableData class]]) {
        [keychain.item setObject:QW_KEYCHAIN_IDENTITY forKey:(__bridge id)(kSecAttrAccount)];
        [keychain.item setObject:data forKey:(__bridge id)kSecValueData];
    }
}

+ (id __nullable)getKeychainValueForType:(id <NSCopying> __nonnull)type
{
    QWKeychain *keychain = [QWKeychain sharedInstance];
    if (!type || !keychain.item) {
        return nil;
    }

    id data = [keychain.item objectForKey:(__bridge id)kSecValueData];
    NSMutableDictionary *dict = nil;
    if (data && [data isKindOfClass:[NSMutableData class]]) {
        dict = [keychain decodeDictWithData:data];
    }

    return dict[type];
}

+ (void)reset
{
    QWKeychain *keychain = [QWKeychain sharedInstance];
    if (!keychain.item) {
        return ;
    }

    id data = [keychain encodeDict:[NSMutableDictionary dictionary]];

    if (data && [data isKindOfClass:[NSMutableData class]]) {
        [keychain.item setObject:QW_KEYCHAIN_IDENTITY forKey:(__bridge id)(kSecAttrAccount)];
        [keychain.item setObject:data forKey:(__bridge id)kSecValueData];
    }
}

- (NSMutableData *)encodeDict:(NSMutableDictionary *)dict
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dict forKey:QW_KEYCHAIN_DICT_ENCODE_KEY_VALUE];
    [archiver finishEncoding];
    return data;
}

- (NSMutableDictionary *)decodeDictWithData:(NSMutableData *)data
{
    NSMutableDictionary *dict = nil;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    if ([unarchiver containsValueForKey:QW_KEYCHAIN_DICT_ENCODE_KEY_VALUE]) {
        @try {
            dict = [unarchiver decodeObjectForKey:QW_KEYCHAIN_DICT_ENCODE_KEY_VALUE];
        }
        @catch (NSException *exception) {
            NSLog(@"keychain 解析错误");
            [QWKeychain reset];
        }
    }
    [unarchiver finishDecoding];

    return dict;
}

@end
