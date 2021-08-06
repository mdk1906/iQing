//
//  BillPageVO.h
//  Qingwen
//
//  Created by Aimy on 11/16/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "PageVO.h"

#import "BillVO.h"

@interface BillPageVO : PageVO

@property (nonatomic, copy) NSArray<BillVO> *results;

@end
