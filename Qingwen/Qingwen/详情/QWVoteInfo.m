//
//  QWVoteInfo.m
//  Qingwen
//
//  Created by qingwen on 2018/3/14.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import "QWVoteInfo.h"

@implementation QWVoteInfo
- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
@end
