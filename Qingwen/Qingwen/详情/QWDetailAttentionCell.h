//
//  QWDetailAttentionCell.h
//  Qingwen
//
//  Created by mumu on 17/1/4.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWBaseTVCell.h"

@class QWDetailAttentionCell;

@protocol QWDetailAttentionCellDelegate <NSObject>

- (void)attentionCell:(QWDetailAttentionCell *)attentionCell didClickedAttentionBtn:(id)sender;
@end

@interface QWDetailAttentionCell : QWBaseTVCell

@property (nonatomic, weak) id <QWDetailAttentionCellDelegate> delegate;

- (void)updateAttentionCell:(UserVO *)author attention:(NSNumber *)attention;
@end
