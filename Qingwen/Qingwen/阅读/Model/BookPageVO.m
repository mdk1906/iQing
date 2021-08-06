//
//  BookPageVO.m
//  Qingwen
//
//  Created by Aimy on 7/7/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "BookPageVO.h"

@implementation BookPageVO

- (instancetype)copyWithZone:(NSZone *)zone
{
    BookPageVO *copy = [[BookPageVO allocWithZone:zone] init];
    copy.chapterIndex = self.chapterIndex;
    copy.pageIndex = self.pageIndex;
    copy.range = self.range;
    copy.volumeId = self.volumeId;
    return copy;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"《卷%@,第%d章,第%d页,偏移%d,字数%d》", self.volumeId, (int)self.chapterIndex, (int)self.pageIndex, (int)self.range.location, (int)self.range.length];
}

@end
