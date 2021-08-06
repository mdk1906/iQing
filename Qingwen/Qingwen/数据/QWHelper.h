//
//  QWHelper.h
//  Qingwen
//
//  Created by Aimy on 8/15/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QWHelper : NSObject

+ (NSString *)releaseFullDateToString:(NSDate *)date;

+ (NSString *)countToShortString:(NSNumber *)count;
+ (NSString *)fullDateToString:(NSDate *)date;  //xxxx年xx月xx日 xx:xx
+ (NSString *)fullDate1ToString:(NSDate *)date; //xxxx-xx-xx
+ (NSString *)fullDate2ToString:(NSDate *)date; //xxxx年xx月xx日

+ (NSString *)shortDateToString:(NSDate *)date;
+ (NSString *)shortDate1ToString:(NSDate *)date;
+ (NSString *)longDateToString:(NSDate *)date;
+ (NSString *)countToString:(NSNumber *)count;

+ (NSString *)shortDate2ToString:(NSDate *)date;

+ (NSAttributedString *)attributedStringWithText:(NSString *)text image:(NSString *)image;


/**
 拼接正确的电话号码

 @param state 区号
 @param phone phone
 @return 电话号码
 */
+ (NSString *)phoneNumberWithState:(NSString *)state phone:(NSString *)phone;
@end
