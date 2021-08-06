//
//  RecommendBooksList.h
//  Qingwen
//
//  Created by wei lu on 12/12/17.
//  Copyright © 2017 iQing. All rights reserved.
//

#import "PageVO.h"
#import "RecommendBooksVO.h"

@interface RecommendsBooksListVO : PageVO
@property (nonatomic, copy) NSArray <RecommendBooksVO> *results;

@end
