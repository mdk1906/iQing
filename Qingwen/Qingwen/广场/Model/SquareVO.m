//
//  SquareVO.m
//  Qingwen
//
//  Created by mumu on 17/3/24.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "SquareVO.h"

@implementation SquareVO

- (NSString *)subTitle {
    return [NSString stringWithFormat:@"＋%@",self.reply];
}

- (NSString *)mainTitle {
    return self.detail.title;
}

- (NSString *)imageView {
    return self.detail.cover;
}

@end
