//
//  QWDetailHeadTVCell.h
//  Qingwen
//
//  Created by Aimy on 9/29/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWBaseTVCell.h"

#import "BookVO.h"
#import "QWDetailHeadView.h"

@class QWDetailHeadTVCell;

@protocol QWDetailHeadTVCellDelegate <NSObject>

- (void)headCell:(QWDetailHeadTVCell *)headCell didClickedAttentionBtn:(id)sender;
- (void)headCell:(QWDetailHeadTVCell *)headCell didClickedShowAllBtn:(id)sender;
- (void)headCell:(QWDetailHeadTVCell *)headCell didClickedHeavyChargeBtn:(id)sender;
- (void)headCell:(QWDetailHeadTVCell *)headCell didClickedChargeBtn:(id)sender;
- (void)headCell:(QWDetailHeadTVCell *)headCell didClickedDiscussBtn:(id)sender;

- (void)headCell:(QWDetailHeadTVCell *)headCell didClickedDirectoryBtn:(id)sender;
- (void)headCell:(QWDetailHeadTVCell *)headCell didClickedGotoReadingBtn:(id)sender;

@end

@interface QWDetailHeadTVCell : QWBaseTVCell

@property (nonatomic, weak) id <QWDetailHeadTVCellDelegate> delegate;
@property (nonatomic, strong, readonly) QWDetailHeadView *headView;

- (void)updateWithData:(BookVO *)book andAttention:(NSNumber *)attention discussCount:(NSNumber *)discussCount showAll:(BOOL)showAll;

@end
