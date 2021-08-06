//
//  BestItemVO.m
//  Qingwen
//
//  Created by Aimy on 7/4/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "BestItemVO.h"

@implementation BestItemVO

- (ListVO *)toListVO
{
    ListVO *listVO = [ListVO new];
//    if (self.book) {
//        listVO.results = self.book;
//        listVO.count = @(self.book.count);
//    }
//    if (self.game) {
//        listVO.results = self.game;
//        listVO.count = @(self.game.count);
//    }
    
    return listVO;
}

@end
