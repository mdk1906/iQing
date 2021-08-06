//
//  QWSendDanmuButton.h
//  Qingwen
//
//  Created by mumu on 16/12/27.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QWSendDanmuButton : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSNumber *count;

- (void)update;

@end
