//
//  ActivityWorkVO.m
//  Qingwen
//
//  Created by mumu on 2017/5/2.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "ActivityWorkVO.h"

@implementation ActivityWorkVO

- (NSString *)coverImageString {
    return  self.cover;
}

- (NSString *)titleString {
    if (self.title.length > 0) {
        return self.title;
    }
    return @"";
}

- (NSString *)authorString {
    if (self.author_name.length > 0) {
        return [NSString stringWithFormat:@"作者: %@",self.author_name];
    }
    return @"作者: ";
}

- (NSString *)combatString {
    if (self.combat.integerValue > 0) {
        return [NSString stringWithFormat:@"战力: %@",[QWHelper countToShortString:self.combat]];
    }
    return @"战力: 0";
}

- (NSString *)beliefString {
    if (self.belief.integerValue > 0) {
        return [NSString stringWithFormat:@"信仰: %@",[QWHelper countToShortString:self.belief]];
    }
    return @"信仰: 0";
}

- (NSString *)countString {
    if (self.count.integerValue > 0 && self.work_type == QWReadingTypeBook) {
        return [NSString stringWithFormat:@"  %@字",[QWHelper countToShortString:self.count]];
    }
    if (self.count.integerValue > 0 && self.work_type == QWReadingTypeGame) {
        return [NSString stringWithFormat:@"  %@章", self.count];
    }
    return @"";
}
- (UIImage *)topCountbgImage {
    if (self.count.integerValue == 0) {
        return nil;
    }
    
    if (self.count.integerValue > 0 && self.work_type == QWReadingTypeGame) {
        return [UIImage imageNamed:@"list_count_bg_3"];
    }
    else {
        return [UIImage imageNamed:@"list_count_bg"];
    }
}
@end
