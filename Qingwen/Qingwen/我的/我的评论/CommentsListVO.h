//
//  CommentsListVO.h
//  Qingwen
//
//  Created by qingwen on 2018/5/2.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import "PageVO.h"

#import "CommentsListVO.h"
#import "CommentsVO.h"
@interface CommentsListVO : PageVO

@property (nonatomic, copy) NSArray<CommentsVO> *results;

@end

