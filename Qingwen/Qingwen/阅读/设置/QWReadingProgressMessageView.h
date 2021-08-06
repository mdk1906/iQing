//
//  QWReadingProgressMessageView.h
//  Qingwen
//
//  Created by Aimy on 7/9/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QWReadingProgressMessageView : UIView

- (void)updateWithProgress:(NSInteger)progress andMessage:(NSString *)message;

- (void)showWithAnimated;
- (void)hideWithAnimated;

@end
