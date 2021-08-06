//
//  GoldBillPageVO.h
//  Qingwen
//
//  Created by Aimy on 3/21/16.
//  Copyright © 2016 iQing. All rights reserved.
//

#import "PageVO.h"

#import "GoldBillVO.h"

@interface GoldBillPageVO : PageVO

@property (nonatomic, copy) NSArray<GoldBillVO> *results;

@end
