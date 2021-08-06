//
//  NewMessageListVO.m
//  Qingwen
//
//  Created by mumu on 17/3/3.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "NewMessageListVO.h"

@implementation NewMessageListVO

- (instancetype)addResultsWithNewPage:(NewMessageListVO *)page {
    
    self.message_list = (NSArray <NewMessageVO> *) [page.message_list arrayByAddingObjectsFromArray:self.message_list];
    return self;
}

@end
