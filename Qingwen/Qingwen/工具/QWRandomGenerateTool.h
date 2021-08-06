//
//  QWGenerateTool.h
//  Qingwen
//
//  Created by mumu on 17/3/6.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QWRandomGenerateTool : NSObject

+ (NSString *)generateRandomString;

+ (NSNumber *)generateRandomNumber;

+ (NSDate *)gengerateRandomDate;

+ (bool)generateRandomBoolen;


/**
 自动生成Model 并转换为Json
 */
//+ (NSString *)generateRandomJsonWithModel:(id)model;

@end
