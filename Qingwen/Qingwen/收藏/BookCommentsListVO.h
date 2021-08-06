//
//  BookCommentsListVO.h
//  Qingwen
//
//  Created by wei lu on 6/01/18.
//  Copyright © 2018 iQing. All rights reserved.
//

#import "PageVO.h"
#import "BookCommentsVO.h"

@interface BookCommentsListVO : PageVO
@property (nonatomic, copy) NSArray <BookCommentsVO> *results;

@end
