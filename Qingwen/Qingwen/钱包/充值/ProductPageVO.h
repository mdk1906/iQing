//
//  ProductPageVO.h
//  Qingwen
//
//  Created by Aimy on 3/17/16.
//  Copyright © 2016 iQing. All rights reserved.
//

#import "PageVO.h"

#import "ProductVO.h"

@interface ProductPageVO : PageVO

@property (nonatomic, copy) NSArray<ProductVO> *results;

@end
