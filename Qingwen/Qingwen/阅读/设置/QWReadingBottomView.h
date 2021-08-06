//
//  QWReadingBottomView.h
//  Qingwen
//
//  Created by Aimy on 7/2/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QWReadingBottomView, QWReadingPVC;

@protocol QWReadingBottomViewDelegate <NSObject>

- (void)bottomView:(QWReadingBottomView *)view didClickedDirectoryBtn:(id)sender;
- (void)bottomView:(QWReadingBottomView *)view didClickedProgressBtn:(id)sender;
- (void)bottomView:(QWReadingBottomView *)view didClickedChargeBtn:(id)sender;
- (void)bottomView:(QWReadingBottomView *)view didClickedSettingBtn:(id)sender;
- (void)bottomView:(QWReadingBottomView *)view didClickedLightBtn:(id)sender;


- (void)gotoNextChapterClickInProgressView:(QWReadingBottomView *)view;
- (void)gotoPreviousChapterClickInProgressView:(QWReadingBottomView *)view;
- (void)progressView:(QWReadingBottomView *)view changeToPageIndex:(NSInteger)pageIndex;

@end

@interface QWReadingBottomView : UIView

@property (weak, nonatomic) id <QWReadingBottomViewDelegate> delegate;

@property (nonatomic, weak) QWReadingPVC *ownerVC;

- (void)updateWithCurrentPageIndex:(NSInteger)currentPageIndex andPageCount:(NSInteger)count;

- (void)showWithAnimated;
- (void)hideWithAnimated;

@end
