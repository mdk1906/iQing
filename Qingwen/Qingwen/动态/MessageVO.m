//
//  MessageVO.m
//  Qingwen
//
//  Created by Aimy on 12/3/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "MessageVO.h"

@implementation MessageVO

- (BOOL)isValid
{
    if (self.type.integerValue == 1) {
        return self.user.username.length && self.data.title.length && self.data.sub_title.length && self.description.length;
    }
    else if (self.type.integerValue == 3){
        return self.user.username.length && self.data.content && self.description.length;
    }
    
    return NO;
}

@end
