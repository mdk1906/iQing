//
//  QWDetailHeadView.h
//  Qingwen
//
//  Created by Aimy on 9/9/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BookVO.h"

@class QWDetailHeadView;

@protocol QWDetailHeadViewDelegate <NSObject>

- (void)headView:(QWDetailHeadView *)view didClickedChargeBtn:(id)sender;
- (void)headView:(QWDetailHeadView *)view didClickedHeavyChargeBtn:(id)sender;

- (void)headView:(QWDetailHeadView *)view didClickedDirectoryBtn:(id)sender;
- (void)headView:(QWDetailHeadView *)view didClickedGotoReadingBtn:(id)sender;

- (void)headView:(QWDetailHeadView *)view didClickedShowAllBtn:(id)sender;


@end

@interface QWDetailHeadView : UIView

@property (nonatomic, weak) id <QWDetailHeadViewDelegate> delegate;

- (void)updateWithBook:(BookVO *)book andAttention:(NSNumber *)attention showAll:(BOOL)showAll;

- (CGFloat)heightWithBook:(BookVO *)book;
+ (CGFloat)minHeightWithBook:(BookVO *)book;

@end
