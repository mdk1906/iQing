//
//  QWReadingTopView.h
//  Qingwen
//
//  Created by Aimy on 7/2/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QWReadingTopView;
@class QWReadingPVC;

@protocol QWReadingTopViewDelegate <NSObject>

- (void)topView:(QWReadingTopView *)view didClickedBackBtn:(id)sender;
- (void)topView:(QWReadingTopView *)view didClickedPictureBtn:(id)sender;
- (void)topView:(QWReadingTopView *)view didClickedDiscussBtn:(id)sender;
- (void)topView:(QWReadingTopView *)view didClickedAloudBtn:(id)sender;
- (void)topView:(QWReadingTopView *)view didClickedDownload:(id)sender;
@end

@interface QWReadingTopView : UIView

@property (weak, nonatomic) id <QWReadingTopViewDelegate> delegate;
@property (nonatomic, weak) QWReadingPVC *ownerVC;
@property (strong, nonatomic) IBOutlet UIButton *discussBtn;
@property (weak, nonatomic) IBOutlet UILabel *discussCountLab;
@property (weak, nonatomic) IBOutlet UIButton *aloudBtnh;
@property (weak, nonatomic) IBOutlet UIButton *downLoadBtnh;
@property (strong,nonatomic)NSString* ishidden;
- (void)showWithAnimated;
- (void)hideWithAnimated;

@end
