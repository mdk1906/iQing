//
//  QWReadingAloudSettingView.h
//  Qingwen
//
//  Created by qingwen on 2018/5/23.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QWReadingPVC;


@interface QWReadingAloudSettingView : UIView

@property (nonatomic, weak) QWReadingPVC *ownerVC;

- (void)showWithAnimated;
- (void)hideWithAnimated;
@end
