//
//  QWUserStatistics.m
//  Qingwen
//
//  Created by qingwen on 2018/7/25.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import "QWUserStatistics.h"
#import "PostLogModel+CoreDataModel.h"
#import "Log+CoreDataClass.h"
#import <AFNetworking.h>

@interface QWUserStatistics(){
    
}

@end

@implementation QWUserStatistics

DEF_SINGLETON(QWUserStatistics);

/**
 *  初始化配置，一般在launchWithOption中调用
 */
+ (void)configure
{
    
}

#pragma mark -- 自定义事件统计部分


+ (void)sendEventToServer:(NSString *)eventId pageID:(NSString *)pageID extra:(NSMutableDictionary *)extra{
//    NSLog(@"***模拟发送事件给服务端，页面ID:%@ 事件ID:%@ extra = %@", pageID,eventId,extra);
    Log *log = [Log MR_createEntity];
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    
    if (extra == nil) {
        
        log.extra = @"";
        log.type = eventId;
        log.name = pageID;
        
        log.timestamp = timeSp;
        log.udid = [[NSUUID UUID] UUIDString];
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    else{
        if ([pageID isEqualToString:@"ViewDisappear"]) {
            if ([QWGlobalValue sharedInstance].viewApperDate != nil) {
                NSString *view_time = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSinceDate:[QWGlobalValue sharedInstance].viewApperDate]];
                extra[@"view_time"] = view_time;
                
            }
            
        }
        NSString *jsonString = nil;
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:extra
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        if (! jsonData) {
            NSLog(@"Got an error: %@", error);
        } else {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n"
                                                           withString:@""];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@" "
                                                           withString:@""];
        log.extra = jsonString;
        log.type = eventId;
        log.name = pageID;
        
        log.timestamp = timeSp;
        log.udid = [[NSUUID UUID] UUIDString];
        //    NSLog(@"原始数据 =  %@",log);
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    
    
}

+(void)postDataToServers{
    NSArray *dataArr = [Log MR_findAll];
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    params[@"timestamp"] = timeSp;
    if ([[QWGlobalValue sharedInstance] nid] != nil) {
        int nid = [[[QWGlobalValue sharedInstance] nid] intValue];
        params[@"user_id"] = @(nid);
        
    }
    else{
        params[@"user_id"] = @(0);
    }
    params[@"udid"] = [QWTracker sharedInstance].GUID;
    params[@"id"] = [[NSUUID UUID] UUIDString];
    params[@"channel"] = @"AppStore";
    params[@"version"] = [QWTracker sharedInstance].Build;
    params[@"platform"] = @"iOS";
    params[@"bundle_id"] = @"com.iqing.qingwen";
    params[@"api_version"] = @"v1.0.2";
    params[@"system_version"] = [QWTracker sharedInstance].Version;
    params[@"app_id"] = @(82313);
    params[@"app_key"] = @"817b60e4aa6511e895db0242ac151a05";
#ifdef DEBUG
    params[@"environment"] = @"Dev";
#else
    params[@"environment"] = @"Prd";
#endif
    
    NSMutableArray *arrayM = [[NSMutableArray alloc] init];
    NSMutableArray *arrayMItem = [[NSMutableArray alloc] init];
    for (int i = 0; i < dataArr.count; i++) {
        [arrayMItem addObject:dataArr[i]];
        if (i % 10 == 9) {
            NSMutableArray *arrayItemItem = [[NSMutableArray alloc] init];
            for (int j =0; j<arrayMItem.count; j++) {
                [arrayItemItem addObject:arrayMItem[j]];
            }
            [arrayM addObject:arrayItemItem];
            [arrayMItem removeAllObjects];
        }

    }
    [arrayM addObject:arrayMItem];
//    NSLog(@"发送原始数据数组 = %@",arrayM);
    
    for (NSArray *arr in arrayM) {
        NSMutableArray *logArr = [[NSMutableArray alloc] init];
        for (int i = 0; i<arr.count; i++) {
            Log *data = arr[i];
            NSMutableDictionary * dic = [NSMutableDictionary new];
            //            dic[@"id"] = data.udid;
            dic[@"type"] = data.type;
            dic[@"name"] = data.name;
            dic[@"timestamp"] = data.timestamp;
            dic[@"data"] = data.extra;
            [logArr addObject:dic];
        }
        params[@"log"] = logArr;
//        NSLog(@"发送原始数据字典 = %@",params);
        NSString *jsonString = nil;
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        if (! jsonData) {
            NSLog(@"Got an error: %@", error);
        } else {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n"
                                                           withString:@""];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@" "
                                                           withString:@""];
        
#ifdef DEBUG
        NSString *utfUrl = [[NSString stringWithFormat:@"http://sea-gate.iqing.com/sea.jpg?json=%@",jsonString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#else
        NSString *utfUrl = [[NSString stringWithFormat:@"http://sea.iqing.com/sea.jpg?json=%@",jsonString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#endif
        
//        NSLog(@"发送数据1234 = %@",utfUrl);
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        AFHTTPResponseSerializer *serializer=[AFHTTPResponseSerializer serializer];
        
        serializer.acceptableContentTypes = [NSSet setWithObject:@"image/jpeg"]; // 设置相应的 http header Content-Type
        
        manager.responseSerializer=serializer;
        
        [manager GET:utfUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            NSHTTPURLResponse * responses = (NSHTTPURLResponse *)task.response;
            if (responses.statusCode == 200) {
//                NSLog(@"成功dic = %ld",(long)responses.statusCode);
                for (Log *log in dataArr) {
                    [log MR_deleteEntity];
                }
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            }
            else{
                
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"失败 = %@",error);
            for (Log *log in dataArr) {
                [log MR_deleteEntity];
            }
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }];
    }
    
    
}

+ (void)postErrorDataToServers:(NSMutableDictionary *)extra{
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    params[@"timestamp"] = timeSp;
    if ([[QWGlobalValue sharedInstance] nid] != nil) {
        int nid = [[[QWGlobalValue sharedInstance] nid] intValue];
        params[@"user_id"] = @(nid);
        
    }
    else{
        params[@"user_id"] = @(0);
    }
    params[@"udid"] = [QWTracker sharedInstance].GUID;
    params[@"id"] = [[NSUUID UUID] UUIDString];
    params[@"channel"] = @"AppStore";
    params[@"version"] = [QWTracker sharedInstance].Build;
    params[@"platform"] = @"iOS";
    params[@"bundle_id"] = @"com.iqing.qingwen";
    params[@"api_version"] = @"v1.0.2";
    params[@"system_version"] = [QWTracker sharedInstance].Version;
    params[@"app_id"] = @(82313);
    params[@"app_key"] = @"817b60e4aa6511e895db0242ac151a05";
#ifdef DEBUG
    params[@"environment"] = @"Dev";
#else
    params[@"environment"] = @"Prd";
#endif
    
    NSMutableArray *logArr = [NSMutableArray new];
    
    NSMutableDictionary * dic = [NSMutableDictionary new];
    dic[@"type"] = @"ErrorEvent";
    dic[@"name"] = @"CarshError";
    dic[@"timestamp"] = timeSp;
    dic[@"data"] = extra;
    [logArr addObject:dic];
    
    params[@"log"] = logArr;
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n"
                                                       withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@" "
                                                       withString:@""];
    
#ifdef DEBUG
    NSString *utfUrl = [[NSString stringWithFormat:@"https://sea-gate.iqing.com/sea.jpg?json=%@",jsonString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#else
    NSString *utfUrl = [[NSString stringWithFormat:@"https://sea.iqing.com/sea.jpg?json=%@",jsonString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#endif
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    AFHTTPResponseSerializer *serializer=[AFHTTPResponseSerializer serializer];
    
    serializer.acceptableContentTypes = [NSSet setWithObject:@"image/jpeg"]; // 设置相应的 http header Content-Type
    
    manager.responseSerializer=serializer;
    
    [manager GET:utfUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSHTTPURLResponse * responses = (NSHTTPURLResponse *)task.response;
        if (responses.statusCode == 200) {
            NSLog(@"成功dic = %ld",(long)responses.statusCode);
            
        }
        else{
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"失败 = %@",error);
        
    }];
}
@end
