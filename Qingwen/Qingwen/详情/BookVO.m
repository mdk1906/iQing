//
//  BookVO.m
//  Qingwen
//
//  Created by Aimy on 7/6/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "BookVO.h"

@implementation BookVO

- (NSString *)cornerImage {
    if (self.need_pay.boolValue) {
        if (self.discount.integerValue == 0) {
            return @"book_free";
        } else {
            return @"book_pay";
        }
    }
    if (self.rank.integerValue == 4) {
        return @"book_gold";
    }
    if (self.rank.integerValue == 3) {
        return @"book_silver";
    }
    return nil;
}
- (UIImage *)topRightCornerImage {

    if (self.scene_count.integerValue > 0) { //演绘
        return [UIImage imageNamed:@"list_count_bg_3"];

    } else {
        if (self.need_pay.integerValue > 0) {
            switch (self.discount.integerValue) {
                case 0:
                    return [UIImage imageNamed:@"list_count_bg_6"];
                    break;
                case 100:
                    return [UIImage imageNamed:@"list_count_bg"];
                    break;
                default:
                    if(100 < self.discount.integerValue){//price raise
                        return [UIImage imageNamed:@"list_count_bg"];
                    }
                    return [UIImage imageNamed:@"list_count_bg_6"];
                    break;
            }
            
        } else {
            if ((self.scene_count == nil && self.count.integerValue == 0) || (self.scene_count.integerValue == 0 && self.count == nil)) {
                return nil;
            }
            else {
                return [UIImage imageNamed:@"list_count_bg"];
            }
        }
    }
    return nil;
}

- (NSString *)topRightCornerTitle {
    if (self.scene_count.integerValue > 0) { //演绘
        return [NSString stringWithFormat:@" %@幕 ",[QWHelper countToString:self.scene_count]];
    } else {
        if (self.need_pay.integerValue > 0) {
            switch (self.discount.integerValue) {
                case 0:
                    return @" 限时免费 ";
                    break;
                case 100:
                    return [NSString stringWithFormat:@" %@ ",[QWHelper countToString:self.count]];
                    break;
                default:
                {
                    NSInteger value = (100 - self.discount.integerValue);
                    NSString *discount = @"";
                    if(value > 0){
                        discount = [NSString stringWithFormat:@" -%ld％ ",value];
                    }else{
                        return [NSString stringWithFormat:@" %@ ",[QWHelper countToString:self.count]];
                    }
                    
                    return discount;
                    break;
                }
            }
        } else {
            return [NSString stringWithFormat:@" %@ ",[QWHelper countToString:self.count]];
        }
    }
    
    return @"";
}

#pragma mark QWBookTVCellCogig
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
    UserVO *user = self.author.firstObject;
    if (user && user.username.length > 0) {
        return [NSString stringWithFormat:@"作者: %@",user.username];
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
    if (self.count.integerValue > 0) {
        return [self topRightCornerTitle];//[NSString stringWithFormat:@"  %@字",[QWHelper countToShortString:self.count]];
    }
    if (self.scene_count.integerValue > 0) {
        return [NSString stringWithFormat:@"  %@章", self.scene_count];
    }
    return @"";
}

- (UIImage *)topCountbgImage {
    return [self topRightCornerImage];
}
-(UIImage *)vipImg{
    return [UIImage imageNamed:@"vip脚标"];
}
- (NSString *)voteString{
    NSDictionary *dic = self.extra;
    if (dic[@"vote"] != nil) {
        self.vote = dic[@"vote"];
        return self.vote;
        NSLog(@"vote1234 = %@",self.vote);
    }
    else{
        return nil;
    }
}
@end
