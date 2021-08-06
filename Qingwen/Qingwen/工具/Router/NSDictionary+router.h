//
//  NSDictionary+router.h
//  Qingwen
//
//  Created by mdk mdk on 2018/5/21.
//  Copyright (c) 2014年 Qingwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (router)

/**
 *  忽略key大小写查询字典
 *
 *  @param aKey
 *
 *  @return
 */
- (id)objectForCaseInsensitiveKey:(NSString *)aKey;

@end
