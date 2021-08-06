//
//  ActivityListVO.h
//  Qingwen
//
//  Created by mumu on 2017/4/24.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "PageVO.h"
#import "ActivityVO.h"
@interface ActivityListVO : PageVO
@property (nonatomic, copy, nullable) NSArray <ActivityVO> *results;
@end
