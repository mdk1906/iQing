//
//  PromotionListVO.h
//  Qingwen
//
//  Created by Aimy on 12/7/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "PageVO.h"

#import "PromotionVO.h"

@interface PromotionListVO : PageVO

@property (nonatomic, copy) NSArray<PromotionVO> *results;

@end
