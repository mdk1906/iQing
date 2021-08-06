//
//  DiscussVO.h
//  Qingwen
//
//  Created by Aimy on 8/12/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "PageVO.h"

#import "DiscussItemVO.h"

@interface DiscussVO : PageVO

@property (nonatomic, copy) NSArray<DiscussItemVO> *results;

@end
