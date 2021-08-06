//
//  QWSendDanmuView.h
//  Qingwen
//
//  Created by mumu on 16/12/5.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QWSendDanmuViewDelegate <NSObject>
- (void)sendDanmuWithString:(NSString *)string;
@end

@interface QWSendDanmuView : UIView  <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

- (void)showWithAnimated;
- (void)hideWithAnimated;

@property (nonatomic, weak) id <QWSendDanmuViewDelegate>delegate;
@end
