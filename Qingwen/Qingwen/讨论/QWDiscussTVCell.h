//
//  QWDiscussTVCell.h
//  Qingwen
//
//  Created by Aimy on 8/11/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBaseTVCell.h"

@class DiscussItemVO;

@interface QWDiscussTVCell : QWBaseTVCell

- (void)updateWithDiscussItemVO:(DiscussItemVO *)vo;

@end
