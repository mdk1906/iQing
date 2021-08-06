//
//  UIView+create.m
//  Qingwen
//
//  Created by Aimy on 14-7-14.
//  Copyright (c) 2014年 Qingwen. All rights reserved.
//

#import "UIView+create.h"

#import "UINib+create.h"

@implementation UIView (create)

+ (instancetype)viewWithFrame:(CGRect)frame
{
    UIView *view = [[self alloc] initWithFrame:frame];
    return view;
}

+ (instancetype)createWithNib
{
    return [self createWithNibName:[NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject];
}

+ (instancetype)createWithNibName:(NSString *)aNibName
{
    return [self createWithNibName:aNibName bundleName:nil];
}

+ (instancetype)createFromNibWithBundleName:(NSString *)aBundleName
{
    return [self createWithNibName:[NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject bundleName:aBundleName];
}

+ (instancetype)createWithNibName:(NSString *)aXibName bundleName:(NSString *)aBundleName
{
    UINib *nib = [UINib createWithNibName:aXibName bundleName:aBundleName];
    NSArray *views = [nib instantiateWithOwner:nil options:nil];
    
    __block UIView *returnView = nil;
    [views enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id view = obj;
        if ([view isKindOfClass:self]) {
            *stop = YES;
            returnView = view;
            return ;
        }
    }];
    
    return returnView;
}

+ (instancetype)autolayoutView
{
    UIView *view = [[self alloc] initWithFrame:CGRectZero];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.backgroundColor = [UIColor clearColor];
    return view;
}

+ (UIView *)duplicate:(UIView *)view
{
    NSData *tempArchive = [NSKeyedArchiver archivedDataWithRootObject:view];
    return [NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
}

@end
