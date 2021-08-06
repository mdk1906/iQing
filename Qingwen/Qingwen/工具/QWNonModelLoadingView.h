//
//  QWNonModelLoadingView.h
//  Qingwen
//
//  Created by Aimy on 14-4-14.
//  Copyright (c) 2014年 Qingwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QWNonModelLoadingView : UIView

+ (instancetype)showLoadingAddedTo:(UIView *)view animated:(BOOL)animated;

+ (void)hideLoadingForView:(UIView *)view animated:(BOOL)animated;

@end
