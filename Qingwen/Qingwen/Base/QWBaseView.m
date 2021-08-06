//
//  QWBaseView.m
//  Qingwen
//
//  Created by mumu on 2017/8/9.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWBaseView.h"

@implementation QWBaseView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)dismiss:(id)sender {
    [self removeFromSuperview];
}

- (void)dealloc {
    NSLog(@"[%@ call %@]", [self class], NSStringFromSelector(_cmd));
}

@end
