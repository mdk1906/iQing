//
//  AttentionListVO.h
//  Qingwen
//
//  Created by mumu on 17/4/1.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "PageVO.h"
#import "AttentionVO.h"

@interface AttentionListVO : PageVO
@property (nonatomic, copy) NSArray <AttentionVO> *results;

@end
