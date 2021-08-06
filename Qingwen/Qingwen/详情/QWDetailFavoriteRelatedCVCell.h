//
//  QWDetailFavoriteRelatedCVCell.h
//  Qingwen
//
//  Created by wei lu on 10/02/18.
//  Copyright © 2018 iQing. All rights reserved.
//

#import "QWBaseCVCell.h"

@class FavoriteBooksVO;

@interface QWDetailFavoriteRelatedCVCell : QWBaseCVCell

- (void)updateWithBookVO:(FavoriteBooksVO *)favorite;

@end
