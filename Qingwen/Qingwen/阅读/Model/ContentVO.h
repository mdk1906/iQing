//
//  ContentVO.h
//  Qingwen
//
//  Created by Aimy on 7/6/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "PageVO.h"

#import "ContentItemVO.h"

@interface ContentVO : PageVO

@property (nonatomic, copy) NSArray<ContentItemVO> *results;

@end
