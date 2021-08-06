//
//  CategoryVO.h
//  Qingwen
//
//  Created by Aimy on 7/4/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "PageVO.h"

#import "CategoryItemVO.h"

@interface CategoryVO : PageVO

@property (nonatomic, copy) NSArray<CategoryItemVO> *results;

@end
