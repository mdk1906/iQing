//
//  QWHelper.m
//  Qingwen
//
//  Created by Aimy on 8/15/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWHelper.h"

#import "NSDate+Utilities.h"

@implementation QWHelper

+ (NSString *)fullDateToString:(NSDate *)date
{
    static NSDateFormatter *dateFormatter = nil;
    if ( ! dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }

    [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    return currentDateStr ?: @" ";
}
+ (NSString *)fullDate1ToString:(NSDate *)date
{
    static NSDateFormatter *dateFormatter = nil;
    if ( ! dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    return currentDateStr ?: @" ";
}

+ (NSString *)fullDate2ToString:(NSDate *)date
{
    static NSDateFormatter *dateFormatter = nil;
    if ( ! dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    return currentDateStr ?: @" ";
}

+ (NSString *)releaseFullDateToString:(NSDate *)date
{
    static NSDateFormatter *dateFormatter = nil;
    if ( ! dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }

    [dateFormatter setDateFormat:@"MM-dd HH:mm"];
    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    return currentDateStr ?: @" ";
}

+ (NSString *)shortDate2ToString:(NSDate *)date {
    
    static NSDateFormatter *dateFormatter = nil;
    if ( ! dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    
    NSDate *now = [NSDate date];
    
    if ([now timeIntervalSinceDate:date] <= 15) {
        [dateFormatter setDateFormat:@"刚刚"];
    }
    else if ([now timeIntervalSinceDate:date] <= 30) {
        [dateFormatter setDateFormat:@"30秒前"];
    }
    else if ([now minutesAfterDate:date] <= 30) {
        NSInteger minutes = [now minutesAfterDate:date] + 1;
        [dateFormatter setDateFormat:[NSString stringWithFormat:@"%@分钟前", @(minutes)]];
    }
    else if ([now hoursAfterDate:date] <= 12) {
        NSInteger hours = [now hoursAfterDate:date] + 1;
        [dateFormatter setDateFormat:[NSString stringWithFormat:@"%@小时前", @(hours)]];
    }
    else {
        NSInteger days = ABS([now distanceInDaysToDate:date] - 1);
        if (days < 30) {
            [dateFormatter setDateFormat:[NSString stringWithFormat:@"%@天前", @(days)]];
        }else {
            [dateFormatter setDateFormat:@"1个月前"];
        }
    }
    
    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    return currentDateStr ?: @" ";

}
+ (NSString *)shortDate1ToString:(NSDate *)date
{
    static NSDateFormatter *dateFormatter = nil;
    if ( ! dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }

    NSDate *now = [NSDate date];

    if ([now timeIntervalSinceDate:date] <= 15) {
        [dateFormatter setDateFormat:@"刚刚"];
    }
    else if ([now timeIntervalSinceDate:date] <= 30) {
        [dateFormatter setDateFormat:@"30秒前"];
    }
    else if ([now minutesAfterDate:date] <= 30) {
        NSInteger minutes = [now minutesAfterDate:date] + 1;
        [dateFormatter setDateFormat:[NSString stringWithFormat:@"%@分钟前", @(minutes)]];
    }
    else if ([now hoursAfterDate:date] <= 12) {
        NSInteger hours = [now hoursAfterDate:date] + 1;
        [dateFormatter setDateFormat:[NSString stringWithFormat:@"%@小时前", @(hours)]];
    }
    else if ([date isToday]) {
        [dateFormatter setDateFormat:@"今天 HH:mm"];
    }
    else if ([date isYesterday]) {
        [dateFormatter setDateFormat:@"昨天 HH:mm"];
    }
    else {
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }

    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    return currentDateStr ?: @" ";
}

+ (NSString *)shortDateToString:(NSDate *)date
{
    static NSDateFormatter *dateFormatter = nil;
    if ( ! dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }

    NSDate *now = [NSDate date];

    if ([now timeIntervalSinceDate:date] <= 15) {
        [dateFormatter setDateFormat:@"刚刚"];
    }
    else if ([now timeIntervalSinceDate:date] <= 30) {
        [dateFormatter setDateFormat:@"30秒前"];
    }
    else if ([now minutesAfterDate:date] <= 30) {
        NSInteger minutes = [now minutesAfterDate:date] + 1;
        [dateFormatter setDateFormat:[NSString stringWithFormat:@"%@分钟前", @(minutes)]];
    }
    else if ([now hoursAfterDate:date] <= 12) {
        NSInteger hours = [now hoursAfterDate:date] + 1;
        [dateFormatter setDateFormat:[NSString stringWithFormat:@"%@小时前", @(hours)]];
    }
    else if ([date isToday]) {
        [dateFormatter setDateFormat:@"今天 HH:mm"];
    }
    else if ([date isYesterday]) {
        [dateFormatter setDateFormat:@"昨天 HH:mm"];
    }
    else {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }

    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    return currentDateStr ?: @" ";
}

+ (NSString *)longDateToString:(NSDate *)date
{
    static NSDateFormatter *dateFormatter = nil;
    if ( ! dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }

    NSDate *now = [NSDate date];

    if ([date isToday]) {
        [dateFormatter setDateFormat:@"今天 HH:mm"];
    }
    else if ([date isYesterday]) {
        [dateFormatter setDateFormat:@"昨天 HH:mm"];
    }
    else {
        NSInteger days = ABS([now distanceInDaysToDate:date] - 1);
        [dateFormatter setDateFormat:[NSString stringWithFormat:@"%@天前", @(days)]];
    }

    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    return currentDateStr ?: @" ";
}

+ (NSString *)countToString:(NSNumber *)count
{
    if (count.integerValue < 1000) {
        return [NSString stringWithFormat:@"%@字", count];
    }
    else if (count.integerValue < 10000) {
        CGFloat temp = count.floatValue;
        temp /= 1000;
        return [NSString stringWithFormat:@"%.1f千字", temp];
    }
    else {
        CGFloat temp = count.floatValue;
        temp /= 10000;
        return [NSString stringWithFormat:@"%.1f万字", temp];
    }
}

+ (NSString *)countToShortString:(NSNumber *)count
{
    count = count ?: @0;
    if (count.integerValue < 10000) {
        return [NSString stringWithFormat:@"%@", count];
    }
    else {
        CGFloat temp = count.floatValue;
        temp /= 10000;
        return [NSString stringWithFormat:@"%.1f万", temp];
    }
}

+ (NSAttributedString *)attributedStringWithText:(NSString *)text image:(NSString *)image {
    
    NSMutableAttributedString *mutableAttribute = [[NSMutableAttributedString alloc]init];
    NSMutableDictionary *attriDic = @{}.mutableCopy;
//    attriDic[NSFontAttributeName] = [UIFont systemFontOfSize:14];
//    attriDic[NSForegroundColorAttributeName] = HRGB(0x333333);
    
    if (image) {
        NSTextAttachment *attachment = [[NSTextAttachment alloc]init];
        attachment.image = [UIImage imageNamed:image];
        NSAttributedString *imageAttribute = [NSAttributedString attributedStringWithAttachment:attachment];
        attachment.bounds = CGRectMake(0, 0, 15, 13);
        [mutableAttribute appendAttributedString:imageAttribute];
        attriDic[NSBaselineOffsetAttributeName] = @(2);
    }
    
    NSMutableAttributedString *textAttr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",text] attributes:attriDic];
    [mutableAttribute appendAttributedString:textAttr];

    return mutableAttribute.copy;
}

+ (NSString *)phoneNumberWithState:(NSString *)state phone:(NSString *)phone {

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d+" options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:state options:0 range:NSMakeRange(0, state.length)];
    if (match) {
        state = [NSString stringWithFormat:@"+%@",[state substringWithRange:match.range]];
    }
    if ( ! [state isEqualToString:@"+86"]) {
        phone = [NSString stringWithFormat:@"%@%@", state, phone];
    }
    else if ( [state isEqualToString:@"+86"]){
        phone = [NSString stringWithFormat:@"%@", phone];
    }
    return phone;
}

@end
