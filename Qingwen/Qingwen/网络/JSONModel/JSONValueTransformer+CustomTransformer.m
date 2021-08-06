//
//  JSONValueTransformer+CustomTransformer.m
//  Qingwen
//
//  Created by Aimy on 14-9-22.
//  Copyright (c) 2014年 Qingwen. All rights reserved.
//

#import <JSONModel/JSONModel.h>

#import "NSObject+swizzle.h"

@implementation JSONValueTransformer(CustomTransformer)

+ (void)load
{
    [self exchangeMethod:@selector(NSDateFromNSNumber:) withMethod:@selector(NSDateFromNSNumberDivide1000:)];
}

#pragma mark - number <-> date
- (NSDate *)NSDateFromNSNumberDivide1000:(NSNumber *)number;
{
	return [NSDate dateWithTimeIntervalSince1970:number.doubleValue / 1000];
}

@end
