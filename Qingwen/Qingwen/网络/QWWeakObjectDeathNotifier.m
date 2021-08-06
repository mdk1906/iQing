//
//  QWWeakObjectDeathNotifier.m
//  OneStoreFramework
//
//  Created by Aimy on 15/3/10.
//  Copyright (c) 2015年 OneStore. All rights reserved.
//

#import "QWWeakObjectDeathNotifier.h"

#import "NSObject+category.h"

@interface QWWeakObjectDeathNotifier ()

@property (nonatomic, copy) QWWeakObjectDeathNotifierBlock aBlock;

@end

@implementation QWWeakObjectDeathNotifier

- (void)setBlock:(QWWeakObjectDeathNotifierBlock)block
{
    self.aBlock = block;
}

- (void)dealloc
{
    if (self.aBlock) {
        self.aBlock(self);
    }

    self.aBlock = nil;
}

- (void)setOwner:(id)owner
{
    _owner = owner;
    
    [owner objc_setAssociatedObject:[NSString stringWithFormat:@"observerOwner_%p",self] value:self policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

@end
