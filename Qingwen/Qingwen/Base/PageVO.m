//
//  PageVO.m
//  Qingwen
//
//  Created by Aimy on 7/4/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "PageVO.h"

@implementation PageVO

- (instancetype)addResultsWithNewPage:(PageVO *)page
{
    self.next = page.next;
    self.previous = page.previous;
    self.results = [self.results arrayByAddingObjectsFromArray:page.results];

    return self;
}

@end
