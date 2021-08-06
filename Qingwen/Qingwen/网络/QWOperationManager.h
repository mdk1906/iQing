//
//  QWOperationManager.h
//  Qingwen
//
//  Created by Aimy on 15/4/7.
//  Copyright (c) 2015年 Qingwen. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@class QWOperationParam;

@interface QWOperationManager : AFHTTPSessionManager

/**
 *  功能:取消当前manager queue中所有网络请求
 */
- (void)cancelAllOperations;

/**
 *  功能:发送请求
 */
- (NSURLSessionDataTask *)requestWithParam:(QWOperationParam *)aParam;

- (NSURLSessionDownloadTask *)downloadFileWithParam:(QWOperationParam *)aParam;

- (NSProgress *)uploadWithParam:(QWOperationParam *)aParam;

/**
 *  初始化函数,宿主owner
 */
+ (instancetype)managerWithOwner:(id)owner;

@end
