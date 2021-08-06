//
//  ActivityWorkListVO.h
//  Qingwen
//
//  Created by mumu on 2017/5/2.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "PageVO.h"
#import "ActivityWorkVO.h"
@interface ActivityWorkListVO : PageVO
@property (nonatomic, copy, nullable) NSArray <ActivityWorkVO> *results;
@end
