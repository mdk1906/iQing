//
//  UINib+create.m
//  Qingwen
//
//  Created by Aimy on 8/26/14.
//  Copyright (c) 2014 Qingwen. All rights reserved.
//

#import "UINib+create.h"

@implementation UINib (create)

+ (instancetype)createWithNibName
{
    return [self createWithNibName:[NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject];
}

+ (instancetype)createWithNibName:(NSString *)aNibName
{
    return [self createWithNibName:aNibName bundleName:nil];
}

+ (instancetype)createWithNibName:(NSString *)aNibName bundleName:(NSString *)aBundleName
{
    NSBundle *bundle = [NSBundle mainBundle];
    if (aBundleName.length) {
        bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:aBundleName withExtension:@"bundle"]];
    }
    
    return [UINib nibWithNibName:aNibName bundle:bundle];
}

@end
