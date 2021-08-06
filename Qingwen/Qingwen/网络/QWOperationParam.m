//
//  QWOperationParam.m
//  Qingwen
//
//  Created by Aimy on 15/4/7.
//  Copyright (c) 2015年 Qingwen. All rights reserved.
//

#import "QWOperationParam.h"

#import "QWUserDefaultsDefine.h"

NSString *const defaultInterfaceUrlHost = @"https://api.iqing.in";
NSString *const defaultbfHost = @"https://bf.iqing.com";
NSString *const defaultPencilHost = @"https://pencil.iqing.com";
NSString *const defaultPayHost = @"https://pay.iqing.com";
NSString *const defaultfavBooksHost = @"https://index.iqing.com";
@interface QWOperationParam ()

@end

@implementation QWOperationParam

/**
 *  功能:初始化方法
 */
+ (nonnull instancetype)paramWithUrl:(NSString * __nonnull)aUrl
                                type:(QWRequestType)aType
                               param:(NSDictionary * __nonnull)aParam
                            callback:(QWCompletionBlock __nullable)aCallback
{
    QWOperationParam *param = [QWOperationParam new];
    param.printLog = YES;
    param.requestUrl = aUrl;
    param.requestType = aType;
    param.requestParam = aParam;
    param.callbackBlock = aCallback;

    param.timeoutTime = 30;
    param.retryTimes = 1;
    param.intervalInSeconds = 10;

    param.compressLength = 1000 * 1000;

    param.useOrigin = YES;
    
    return param;
}

+ (nonnull instancetype)paramWithMethodName:(NSString * __nonnull)aUrl
                                       type:(QWRequestType)aType
                                      param:(NSDictionary * __nonnull)aParam
                                   callback:(QWCompletionBlock __nullable)aCallback
{
    return [self paramWithUrl:[NSString stringWithFormat:@"%@/%@",[self currentDomain], aUrl] type:aType param:aParam callback:aCallback];
}

/**
 *  功能:当前API域名
 */
+ (nonnull NSString *)currentDomain
{
#ifdef DEBUG
    NSString *currentDomain = [[NSUserDefaults standardUserDefaults] stringForKey:API_ADDRESS];
    if (!currentDomain) {
        currentDomain = defaultInterfaceUrlHost;
        [[NSUserDefaults standardUserDefaults] setValue:currentDomain forKey:API_ADDRESS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    return currentDomain;
#else
    return defaultInterfaceUrlHost;
#endif
}

/**
 *  当前讨论区域名
 */
+ (nonnull NSString *)currentBfDomain {
#ifdef DEBUG
    NSString *currentBfDomain = [[NSUserDefaults standardUserDefaults] stringForKey:BF_API_ADDRESS];
    if (!currentBfDomain) {
        currentBfDomain = defaultbfHost;
        [[NSUserDefaults standardUserDefaults] setValue:currentBfDomain forKey:BF_API_ADDRESS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return currentBfDomain;
#else
    return defaultbfHost;
#endif
}

/**
 *  当前投稿域名
 */
+ (nonnull NSString *)currentPecilDomain {
#ifdef DEBUG
    NSString *currentPecilDomain = [[NSUserDefaults standardUserDefaults] stringForKey:PENCIL_API_ADDRESS];
    if (!currentPecilDomain) {
        currentPecilDomain = defaultPencilHost;
        [[NSUserDefaults standardUserDefaults] setValue:currentPecilDomain forKey:PENCIL_API_ADDRESS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return currentPecilDomain;
#else
    return defaultPencilHost;
#endif
}

/**
 *  功能:当前API域名
 */
+ (nonnull NSString *)currentPayDomain
{
#ifdef DEBUG
    NSString *currentPayDomain = [[NSUserDefaults standardUserDefaults] stringForKey:PAY_API_ADDRESS];
    if (!currentPayDomain) {
        currentPayDomain = defaultPayHost;
        [[NSUserDefaults standardUserDefaults] setValue:currentPayDomain forKey:PAY_API_ADDRESS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return currentPayDomain;
#else
    return defaultPayHost;
#endif
}
/*
 *  当前书单域名
 */
+ (nonnull NSString *)currentFAVBooksDomain {
#ifdef DEBUG
    NSString *currentFavDomain = [[NSUserDefaults standardUserDefaults] stringForKey:FAVBOOKS_API_ADDRESS];
    if (!currentFavDomain) {
        currentFavDomain = defaultfavBooksHost;
        [[NSUserDefaults standardUserDefaults] setValue:currentFavDomain forKey:FAVBOOKS_API_ADDRESS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return currentFavDomain;
#else
    return defaultfavBooksHost;
#endif
}
@end
