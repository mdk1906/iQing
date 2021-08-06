//
//  QWNativeFuncVO.h
//  Qingwin
//
//  Created by Aimy on 10/7/14.
//  Copyright (c) 2014 Qingwin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QWMappingVO.h"

typedef NS_ENUM(NSUInteger, QWNativeFuncVOPlatformType)
{
    QWNativeFuncVOPlatformTypeUniversal = 0,//任何平台都加载此func
    QWNativeFuncVOPlatformTypePhone     = 1,//只在iPhone上加载此func
    QWNativeFuncVOPlatformTypePad       = 2,//只在iPad上加载此func
};

typedef id (^QWNativeFuncVOBlock)(NSDictionary<NSString *, id> *params);

@interface QWNativeFuncVO : NSObject
/**
 *  调用的方法,默认传送一个参数，为NSDictionary
 */
@property (nonatomic, copy) QWNativeFuncVOBlock block;
/**
 *  func过滤
 */
@property (nonatomic) QWMappingClassPlatformType funcFilterType;
/**
 *  调用此方法需要先登陆
 */
@property (nonatomic) BOOL needLogin;

+ (instancetype)createWithBlock:(QWNativeFuncVOBlock)block;

@end
