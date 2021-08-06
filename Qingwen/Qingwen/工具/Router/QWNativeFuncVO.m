//
//  QWNativeFuncVO.m
//  OneStoreFramework
//
//  Created by Aimy on 10/7/14.
//  Copyright (c) 2014 OneStore. All rights reserved.
//

#import "QWNativeFuncVO.h"

@implementation QWNativeFuncVO

+ (instancetype)createWithBlock:(QWNativeFuncVOBlock)block
{
    QWNativeFuncVO *vo = [self new];
    vo.block = block;
    return vo;
}

@end
