//
//  QWMessageBookTVCell.h
//  Qingwen
//
//  Created by Aimy on 8/27/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBaseTVCell.h"

#import "MessageVO.h"

@interface QWMessageBookTVCell : QWBaseTVCell

- (void)updateWithMessage:(MessageVO *)itemVO;

@end
