//
//  BooksListContentVO.h
//  Qingwen
//
//  Created by wei lu on 30/12/17.
//  Copyright © 2017 iQing. All rights reserved.
//

#import "PageVO.h"
#import "BooksListVO.h"
@interface FavoriteBooksInListVO : PageVO
@property (nonatomic, copy) NSArray <BooksListVO> *results;

@end
