//
//  NSString+router.h
//  Qingwin
//
//  Created by mdk mdk on 2018/5/21.
//  Copyright (c) 2014年 Qingwin. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface NSString (router)

/**
 *  解析params
 *
 *  @param aJsonString string
 *
 *  @return dict
 */
+ (NSDictionary *)getDictFromJsonString:(NSString * _Nullable)aJsonString;
/**
 *  组装router url,需要带上url scheme
 *
 *  @param urlString string(yhd://home,yhdiosfun://back)
 *  @param params    dict
 *
 *  @return string,已经url encoded,无需再编码
 */
+ (NSString *)getRouterUrlStringFromUrlString:(NSString *)urlString andParams:(NSDictionary<NSString *, id> * _Nullable)params;
/**
 *  组装vc跳转url，yhd://home,无需带上url scheme
 *
 *  @param urlString string(home)
 *  @param params    dict,如无参数，填nil
 *
 *  @return stirng,已经url encoded,无需再编码
 */
+ (NSString *)getRouterVCUrlStringFromUrlString:(NSString *)urlString andParams:(NSDictionary<NSString *, id> * _Nullable)params;
/**
 *  组装本地方法url，yhdiosfun://back,无需带上url scheme
 *
 *  @param urlString string(back)
 *  @param params    dict,如无参数，填nil
 *
 *  @return string,已经url encoded,无需再编码
 */
+ (NSString *)getRouterFunUrlStringFromUrlString:(NSString *)urlString andParams:(NSDictionary<NSString *, id> * _Nullable)params;

@end

NS_ASSUME_NONNULL_END
