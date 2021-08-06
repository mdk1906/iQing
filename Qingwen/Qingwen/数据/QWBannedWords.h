//
//  QWBannedWords.h
//  Qingwen
//
//  Created by mumu on 17/1/20.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QWBannedWords : NSObject

+ (QWBannedWords * __nonnull)sharedInstance;

- (void)getBannedWords;


/**
 返回已经屏蔽的String
 */
- (NSString * __nullable)cryptoStringWithText:(NSString *__nullable)text;

@end
