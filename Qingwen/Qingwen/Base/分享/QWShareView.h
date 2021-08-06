//
//  QWShareView.h
//  Qingwen
//
//  Created by Aimy on 8/20/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QWShareView : UIView

- (void)showWithCompleteBlock:(void (^)(NSInteger))block;
- (void)hide;

@end
