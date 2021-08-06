//
//  FavoriteBooksList.h
//  Qingwen
//
//  Created by wei lu on 11/12/17.
//  Copyright © 2017 iQing. All rights reserved.
//

#import "PageVO.h"
#import "FavoriteBooksVO.h"

@interface FavoriteBooksListVO : PageVO
@property (nonatomic, copy) NSArray <FavoriteBooksVO> *results;

@end
