//
//  QWVoteActivityVO.m
//  Qingwen
//
//  Created by qingwen on 2018/3/14.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import "QWVoteActivityVO.h"

@implementation QWVoteActivityVO
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
