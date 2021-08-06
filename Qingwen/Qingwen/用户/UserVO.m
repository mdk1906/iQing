//
//  UserVO.m
//  Qingwen
//
//  Created by Aimy on 7/18/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "UserVO.h"

@implementation UserVO

- (NSNumber *)fans_count
{
    if (!_fans_count) {
        if (self.count) {
            return self.count;
        }
    }

    return _fans_count;
}

@end
