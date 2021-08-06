//
//  QWGameDetailRelatedCVCell.h
//  Qingwen
//
//  Created by Aimy on 7/3/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBaseCVCell.h"

@class BookVO;

@interface QWGameDetailRelatedCVCell : QWBaseCVCell

- (void)updateWithBookVO:(BookVO *)book;

@end
