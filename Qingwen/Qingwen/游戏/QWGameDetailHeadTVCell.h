//
//  QWGameDetailHeadTVCell.h
//  Qingwen
//
//  Created by Aimy on 9/29/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWBaseTVCell.h"

#import "BookVO.h"

@class QWGameDetailHeadTVCell;

@protocol QWGameDetailHeadTVCellDelegate <NSObject>

- (void)headCell:(QWGameDetailHeadTVCell *)headCell didClickedAttentionBtn:(id)sender;
- (void)headCell:(QWGameDetailHeadTVCell *)headCell didClickedShowAllBtn:(id)sender;

@end

@interface QWGameDetailHeadTVCell : QWBaseTVCell

@property (nonatomic, weak) id <QWGameDetailHeadTVCellDelegate> delegate;

- (void)updateWithData:(BookVO *)book andAttention:(NSNumber *)attention isMyself:(NSNumber *)myself discussCount:(NSNumber *)discussCount showAll:(BOOL)showAll;

- (CGFloat)heightWithBook:(BookVO *)book;
+ (CGFloat)minHeightWithBook:(BookVO *)book;

@end
