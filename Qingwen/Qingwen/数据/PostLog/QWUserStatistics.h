//
//  QWUserStatistics.h
//  Qingwen
//
//  Created by qingwen on 2018/7/25.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QWUserStatistics : NSObject


/**
 *  初始化配置，一般在launchWithOption中调用
 */
+ (void)configure;

+ (void)sendEventToServer:(NSString *)eventId pageID:(NSString *)pageID extra:(NSMutableDictionary *)extra;

+ (void)postDataToServers;

+ (void)postErrorDataToServers:(NSMutableDictionary *)extra;
@end
