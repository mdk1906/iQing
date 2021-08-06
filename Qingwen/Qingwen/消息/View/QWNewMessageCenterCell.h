//
//  QWNewMessageListCell.h
//  Qingwen
//
//  Created by mumu on 17/3/6.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWBaseTVCell.h"

#import "TalkVO.h"

@interface QWNewMessageCenterCell : QWBaseTVCell

- (void)updateCellWithMessageCenterVO:(TalkVO *)talk;

@end
