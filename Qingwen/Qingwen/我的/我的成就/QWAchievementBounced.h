//
//  QWAchievementBounced.h
//  Qingwen
//
//  Created by qingwen on 2018/9/17.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QWAchievementBounced : UIView
-(instancetype)initWithFrame:(CGRect)frame dict:(NSDictionary *)data;
- (void)showWithAchievementDedail:(NSDictionary *)achievementDedail;
@end
