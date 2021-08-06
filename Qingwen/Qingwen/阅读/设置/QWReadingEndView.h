//
//  QWReadingEndView.h
//  Qingwen
//
//  Created by Aimy on 12/11/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QWReadingEndView;

@protocol QWReadingEndViewDelegate <NSObject>

- (void)endView:(QWReadingEndView *)view onPressedChargeBtn:(id)sender;
- (void)endView:(QWReadingEndView *)view onPressedDiscussBtn:(id)sender;
- (void)endView:(QWReadingEndView *)view onPressedHideBtn:(id)sender;

@end


@interface QWReadingEndView : UIView

@property (nonatomic, weak) id <QWReadingEndViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIButton *discussBtn;

- (void)showWithAnimated;
- (void)hideWithAnimated;

@end
