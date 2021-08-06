//
//  QWDetailFavoriteRelatedTVCell.h
//  Qingwen
//
//  Created by wei lu on 10/02/18.
//  Copyright © 2018 iQing. All rights reserved.
//

#import "QWBaseTVCell.h"

@class FavoriteBooksListVO;

@interface QWDetailFavoriteRelatedTVCell : QWBaseTVCell

- (void)updateWithListVO:(FavoriteBooksListVO *)vo;

@end
