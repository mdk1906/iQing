//
//  QWPictureBottomView.h
//  Qingwen
//
//  Created by Aimy on 7/3/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QWPictureBottomView;

@protocol QWPictureBottomViewDelegate <NSObject>

- (void)bottomView:(QWPictureBottomView *)view didClickedRotatingBtn:(id)sender;
- (void)bottomView:(QWPictureBottomView *)view didClickedSaveBtn:(id)sender;

@end

@interface QWPictureBottomView : UIView

@property (weak, nonatomic) id <QWPictureBottomViewDelegate> delegate;

- (void)showWithAnimated;
- (void)hideWithAnimated;

@end
