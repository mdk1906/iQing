//
//  QWReadingSettingView.h
//  Qingwen
//
//  Created by Aimy on 7/2/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QWReadingPVC;

@interface QWReadingSettingView : UIView

@property (nonatomic, weak) QWReadingPVC *ownerVC;

- (void)showWithAnimated;
- (void)hideWithAnimated;

@end
