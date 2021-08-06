//
//  QWPictureTopView.h
//  Qingwen
//
//  Created by Aimy on 7/3/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QWPictureTopView;

@protocol QWPictureTopViewDelegate <NSObject>

- (void)topView:(QWPictureTopView *)view didClickedBackBtn:(id)sender;

@end

@interface QWPictureTopView : UIView

@property (weak, nonatomic) id <QWPictureTopViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *countLabel;

- (void)showWithAnimated;
- (void)hideWithAnimated;

@end
