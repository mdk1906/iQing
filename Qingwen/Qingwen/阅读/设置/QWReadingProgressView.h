//
//  QWReadingProgressView.h
//  Qingwen
//
//  Created by Aimy on 7/2/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QWReadingProgressView, QWReadingPVC;

@protocol QWReadingProgressViewDelegate <NSObject>

- (void)gotoNextChapterClickInProgressView:(QWReadingProgressView *)view;
- (void)gotoPreviousChapterClickInProgressView:(QWReadingProgressView *)view;
- (void)progressView:(QWReadingProgressView *)view changeToPageIndex:(NSInteger)pageIndex;
//- (void)progressView:(QWReadingProgressView *)view previewPageAtIndex:(NSInteger)pageIndex;

@end

@interface QWReadingProgressView : UIView

@property (nonatomic, weak) id <QWReadingProgressViewDelegate> delegate;
@property (nonatomic, weak) QWReadingPVC *ownerVC;

- (void)updateWithCurrentPageIndex:(NSInteger)currentPageIndex andPageCount:(NSInteger)count;

- (void)showWithAnimated;
- (void)hideWithAnimated;

@end
