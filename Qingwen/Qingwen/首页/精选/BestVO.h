//
//  BestVO.h
//  Qingwen
//
//  Created by Aimy on 7/4/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "PageVO.h"

#import "BestItemVO.h"

@interface BestVO : PageVO

@property (nonatomic, copy, nullable) NSArray<BestItemVO> *results;

@end
