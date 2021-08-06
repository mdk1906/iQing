//
//  NSString+router.m
//  Qingwin
//
//  Created by mdk mdk on 2018/5/21.
//  Copyright (c) 2014年 Qingwin. All rights reserved.
//

#import "NSString+router.h"

#import "QWRouter.h"
#import "QWJsonKit.h"

@implementation NSString (router)

+ (NSDictionary *)getDictFromJsonString:(NSString *)aJsonString
{
    //urldecode
    NSString *jsonString = [aJsonString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSArray *subStrings = [jsonString componentsSeparatedByString:@"="];
    if ([QWRouterParamKey isEqualToString:subStrings[0]]) {
        if (subStrings[1]) {
            NSRange range=[jsonString rangeOfString:@"="];
            //除去body＝剩下纯json格式string
            NSString*jsonStr=[jsonString substringFromIndex:range.location+1];
            NSDictionary *resultDict = [QWJsonKit dictFromString:jsonStr];
            dict[QWRouterParamKey] = resultDict;
        }
    }

    [dict.copy enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            dict[key] = [obj stringValue];
        }
    }];
    
    if  (!dict[QWRouterParamKey])
        dict[QWRouterParamKey] = @{};
    return dict;
}

+ (NSString *)getRouterUrlStringFromUrlString:(NSString *)urlString andParams:(NSDictionary *)params
{
    NSString *json = [QWJsonKit stringFromDict:params];
    
    if (!json) {
        return urlString;
    }
    
    NSString *jsonString = [urlString stringByAppendingFormat:@"?%@=%@",QWRouterParamKey,json];
    jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return jsonString;
}

+ (NSString *)getRouterVCUrlStringFromUrlString:(NSString *)urlString andParams:(NSDictionary *)params
{
    return [self getRouterUrlStringFromUrlString:[NSString stringWithFormat:@"%@://%@", QWScheme, urlString] andParams:params];
}

+ (NSString *)getRouterFunUrlStringFromUrlString:(NSString *)urlString andParams:(NSDictionary *)params
{
    return [self getRouterUrlStringFromUrlString:[NSString stringWithFormat:@"%@://%@", QWFuncScheme, urlString] andParams:params];
}

@end
