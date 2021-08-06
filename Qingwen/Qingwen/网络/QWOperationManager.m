//
//  QWOperationManager.m
//  Qingwen
//
//  Created by Aimy on 15/4/7.
//  Copyright (c) 2015年 Qingwen. All rights reserved.
//

#import "QWOperationManager.h"
#import "QWNetworkManager.h"
#import "QWOperationParam.h"
#import "QWWeakObjectDeathNotifier.h"
#import "QWTracker.h"
#import <AFNetworking+AutoRetry/AFHTTPSessionManager+AutoRetry.h>
#import "QWGlobalValue.h"
#import "WebPImageSerialization.h"
#import <SDWebImage/UIImage+MultiFormat.h>

@interface QWOperationManager ()

@property (nonatomic, strong) NSString *hostClassName;

@end

@implementation QWOperationManager

+ (instancetype)manager
{
    return [self managerWithOwner:nil];
}

+ (instancetype)managerWithOwner:(id)owner
{
    QWOperationManager *operationManager = [super manager];
    operationManager.hostClassName = NSStringFromClass([owner class]);
    operationManager.operationQueue.maxConcurrentOperationCount = 1;
    
    if (owner) {
        //dealloc
        QWWeakObjectDeathNotifier *wo = [QWWeakObjectDeathNotifier new];
        [wo setOwner:owner];
        [wo setBlock:^(QWWeakObjectDeathNotifier *sender) {
            [operationManager cancelOperationsAndRemoveFromNetworkManager];
        }];
    }
    
    //缓存策略
    operationManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    [operationManager.requestSerializer setHTTPShouldHandleCookies:NO];
    operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    operationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"image/jpeg",@"text/html", nil];
    
    return operationManager;
}

- (void)dealloc
{
    NSLog(@"[%@ call %@ --> %@]", [self class], NSStringFromSelector(_cmd), _hostClassName);
}

/**
 *  功能:发送请求
 */
- (NSURLSessionDataTask *)requestWithParam:(QWOperationParam *)aParam
{
    if (aParam == nil) {
        return nil;
    }
    
    if (![NSURL URLWithString:aParam.requestUrl]) {
        return nil;
    }
    
    //特殊处理iOS7上传图片
    if (aParam.uploadImage && IOS_SDK_LESS_THAN(8.0)) {
        // Create manager
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"token"] = [QWGlobalValue sharedInstance].token;
        NSString *url = @"https://api.iqing.in/avatar/";
        if (aParam.uploadBookImage) {
            url = @"https://api.iqing.in/tunnel/";
            params[@"type"] = @"book";
        }
        // Form Multipart Body
        
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            
            NSData *imageData = UIImageJPEGRepresentation(aParam.uploadImage, 0.86);
            
            if (aParam.compressimage && imageData.length > aParam.compressLength) {
                CGFloat compress = (CGFloat)imageData.length / aParam.compressLength * 0.9;
                imageData = UIImageJPEGRepresentation(aParam.uploadImage, compress);
            }
            
            if (imageData) {
                [formData appendPartWithFileData:imageData name:@"file" fileName:@"file" mimeType:@"image/jpeg"];
            }
            
            for (NSString *key in aParam.requestParam.allKeys) {
                NSData *data = [[[aParam.requestParam objectForKey:key] description] dataUsingEncoding:NSUTF8StringEncoding];
                [formData appendPartWithFormData:data name:key];
            }
        } error:NULL];
        
        // Add Headers
        [request setValue:[QWTracker sharedInstance].AppVersion forHTTPHeaderField:@"AppVersion"];
        [request setValue:[QWTracker sharedInstance].System forHTTPHeaderField:@"System"];
        [request setValue:[QWTracker sharedInstance].Version forHTTPHeaderField:@"Version"];
        [request setValue:[QWTracker sharedInstance].GUID forHTTPHeaderField:@"GUID"];
        [request setValue:[QWTracker sharedInstance].track forHTTPHeaderField:@"Build"];
        [request setValue:[QWTracker sharedInstance].channel forHTTPHeaderField:@"channel"];
        [request setValue:[QWTracker sharedInstance].BuildVersion forHTTPHeaderField:@"BuildVersion"];
        
        // Fetch Request
        WEAK_SELF;
        AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request
                                                                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                 STRONG_SELF;
                                                                                 //json
                                                                                 
                                                                                 if (aParam.printLog) {
                                                                                     if (aParam.requestType != QWRequestTypeGet) {
                                                                                         NSLog(@"\n\nrequest url is:\n\n\t%@\n\nparams is:\n\n\t%@\n\nrespponse is:\n\n\t%@\n\n",[operation.response.URL.absoluteString stringByRemovingPercentEncoding], aParam.requestParam, responseObject);
                                                                                     }
                                                                                     else {
                                                                                         NSLog(@"\n\nrequest url is:\n\n\t%@\n\nrespponse is:\n\n\t%@\n\n",[operation.response.URL.absoluteString stringByRemovingPercentEncoding], responseObject);
                                                                                     }
                                                                                 }
                                                                                 if (aParam.callbackBlock) {
                                                                                     aParam.callbackBlock(responseObject, nil);
                                                                                 }
                                                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                 STRONG_SELF;
                                                                                 if (aParam.printLog) {
                                                                                     if (aParam.requestType != QWRequestTypeGet) {
                                                                                         NSLog(@"\n\nrequest url is:\n\n\t%@\n\nparams is:\n\n\t%@\n\nerror is:\n\n\t%@\n\n",[operation.request.URL.absoluteString stringByRemovingPercentEncoding], aParam.requestParam, error);
                                                                                     }
                                                                                     else {
                                                                                         NSLog(@"\n\nrequest url is:\n\n\t%@\n\nerror is:\n\n\t%@\n\n",[operation.request.URL.absoluteString stringByRemovingPercentEncoding], error);
                                                                                     }
                                                                                 }
                                                                                 
                                                                                 if ([operation.response isKindOfClass:[NSHTTPURLResponse class]]) {
                                                                                     NSHTTPURLResponse *res = (id)operation.response;
                                                                                     if (res.statusCode == 403) {//token失效
                                                                                         NSLog(@"lookup 403");
//                                                                                         [[QWGlobalValue sharedInstance] clear];
//                                                                                         [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_STATE_CHANGED object:nil];
                                                                                     }
                                                                                 }
                                                                                 
                                                                                 if (aParam.callbackBlock) {
                                                                                     aParam.callbackBlock(nil, error);
                                                                                 }
                                                                             }];
        
        [manager.operationQueue addOperation:operation];
        return nil;
    }
    
    self.requestSerializer.timeoutInterval = aParam.timeoutTime;
    
    //设置http头
    [[QWTracker sharedInstance] configHeader:self.requestSerializer];
    
    if (aParam.useOrigin) {
        self.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    }
    else {
        self.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    self.securityPolicy.validatesDomainName = NO;
    if (aParam.useV4) {
        if ([QWGlobalValue sharedInstance].token) {
            [self.requestSerializer setValue:[NSString stringWithFormat:@"token %@",[QWGlobalValue sharedInstance].token] forHTTPHeaderField:@"Authorization"];
            NSLog(@"token\n:%@",[QWGlobalValue sharedInstance].token);
        }
        [self.requestSerializer setValue:@"v4" forHTTPHeaderField:@"AppVersion"];
    }
    
    NSMutableURLRequest *request = nil;
    NSString *method = nil;
    
    switch (aParam.requestType) {
        case QWRequestTypePost:
            method = @"POST";
            break;
        case QWRequestTypeGet:
            method = @"GET";
            break;
        case QWRequestTypePatch:
            method = @"PATCH";
            break;
        case QWRequestTypePut:
            method = @"PUT";
            break;
        case QWRequestTypeDelete:
            method = @"DELETE";
            break;
        default:
            break;
    }
    
    if (aParam.paramsUseForm) {
        request = [self.requestSerializer multipartFormRequestWithMethod:method URLString:aParam.requestUrl parameters:aParam.requestParam constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            NSData *imageData = UIImageJPEGRepresentation(aParam.uploadImage,0.75);
            
            if (aParam.compressimage && imageData.length > aParam.compressLength) {
                CGFloat compress = (CGFloat)imageData.length / aParam.compressLength * 0.9;
                imageData = UIImageJPEGRepresentation(aParam.uploadImage,compress);
            }
            
            if (imageData) {
                [formData appendPartWithFileData:imageData name:@"file" fileName:@"file" mimeType:@"image/jpeg"];
            }
            
            for (NSString *key in aParam.requestParam.allKeys) {
                NSData *data = [[[aParam.requestParam objectForKey:key] description] dataUsingEncoding:NSUTF8StringEncoding];
                [formData appendPartWithFormData:data name:key];
            }
            
        } error:NULL];
    }
    else {
        request = [self.requestSerializer requestWithMethod:method URLString:aParam.requestUrl parameters:aParam.requestParam error:NULL];
    }
    
    if (aParam.paramsUseData) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSString *paramString = aParam.requestParam[@"data"];
        request.HTTPBody = [paramString dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    WEAK_SELF;
    NSURLSessionDataTask *dataTask = [self requestUrlWithAutoRetry:aParam.retryTimes retryInterval:aParam.intervalInSeconds originalRequestCreator:^NSURLSessionDataTask *(void (^retryBlock)(NSURLSessionDataTask *, NSError *)) {
        __strong typeof(weakSelf)self = weakSelf;
        
        NSURLSessionDataTask *task = nil;
        
        task = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nonnull responseObject, NSError * _Nonnull error) {
            STRONG_SELF;
            
            if (error) {
                if (aParam.printLog) {
                    if (aParam.requestType != QWRequestTypeGet) {
                        NSLog(@"\n\nrequest url is:\n\n\t%@\n\nparams is:\n\n\t%@\n\nerror is:\n\n\t%@\n\n",[response.URL.absoluteString stringByRemovingPercentEncoding], aParam.requestParam, error);
                    }
                    else {
                        NSLog(@"\n\nrequest url is:\n\n\t%@\n\nerror is:\n\n\t%@\n\n",[response.URL.absoluteString stringByRemovingPercentEncoding], error);
                    }
                }
                
                [self handlePostErrorWithResponse:response error:error];
                
                if (aParam.callbackBlock) {
                    aParam.callbackBlock(nil, error);
                }
            }
            else {
                responseObject = [self convertDataToObject:task responseObject:responseObject];
                
                if (aParam.printLog) {
                    if (aParam.requestType != QWRequestTypeGet) {
                        NSLog(@"\n\nrequest url is:\n\n\t%@\n\nparams is:\n\n\t%@\n\nrespponse is:\n\n\t%@\n\n",[response.URL.absoluteString stringByRemovingPercentEncoding], aParam.requestParam, responseObject);
                    }
                    else {
                        NSLog(@"\n\nrequest url is:\n\n\t%@\n\nrespponse is:\n\n\t%@\n\n",[response.URL.absoluteString stringByRemovingPercentEncoding], responseObject);
                    }
                }
                if (aParam.callbackBlock) {
                    aParam.callbackBlock(responseObject, nil);
                }
            }
        }];
        [task resume];
        return task;
        
    } originalFailure:^(NSURLSessionDataTask *task, NSError *error) {
        STRONG_SELF;
        if (aParam.printLog) {
            if (aParam.requestType != QWRequestTypeGet) {
                NSLog(@"\n\nrequest url is:\n\n\t%@\n\nparams is:\n\n\t%@\n\nerror is:\n\n\t%@\n\n",[task.currentRequest.URL.absoluteString stringByRemovingPercentEncoding], aParam.requestParam, error);
            }
            else {
                NSLog(@"\n\nrequest url is:\n\n\t%@\n\nerror is:\n\n\t%@\n\n",[task.currentRequest.URL.absoluteString stringByRemovingPercentEncoding], error);
            }
        }
        
        [self handlePostErrorWithTask:task error:error];
        
        if (aParam.callbackBlock) {
            aParam.callbackBlock(nil, error);
        }
    }];
    
    return dataTask;
}

- (NSURLSessionDownloadTask *)downloadFileWithParam:(QWOperationParam *)aParam
{
    if (aParam == nil) {
        return nil;
    }
    
    if (![NSURL URLWithString:aParam.requestUrl]) {
        return nil;
    }
    
    self.requestSerializer.timeoutInterval = aParam.timeoutTime;
    
    //设置http头
    [[QWTracker sharedInstance] configHeader:self.requestSerializer];
    
    NSURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:aParam.requestUrl parameters:aParam.requestParam error:NULL];
    
    NSProgress *progress = nil;
    
    NSURLSessionDownloadTask *task = nil;
    if (aParam.resumeData.length) {
        WEAK_SELF;
        task = [self downloadTaskWithResumeData:aParam.resumeData progress:&progress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [[NSURL alloc] initFileURLWithPath:aParam.filePath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath, NSError * _Nonnull error) {
            STRONG_SELF;
            if (aParam.requestType != QWRequestTypeGet) {
                NSLog(@"\n\nrequest url is:\n\n\t%@\n\nparams is:\n\n\t%@\n\nerror is:\n\n\t%@\n\n",[response.URL.absoluteString stringByRemovingPercentEncoding], aParam.requestParam, error);
            }
            else {
                NSLog(@"\n\nrequest url is:\n\n\t%@\n\nerror is:\n\n\t%@\n\n",[response.URL.absoluteString stringByRemovingPercentEncoding], error);
            }
            
            if (error) {
                
                [self handlePostErrorWithResponse:response error:error];
                
                if (aParam.callbackBlock) {
                    aParam.callbackBlock(nil, error);
                }
            }
            else {
                if (aParam.callbackBlock) {
                    aParam.callbackBlock(filePath, error);
                }
            }
        }];
    }
    else {
        WEAK_SELF;
        task = [self downloadTaskWithRequest:request progress:&progress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [[NSURL alloc] initFileURLWithPath:aParam.filePath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath, NSError * _Nonnull error) {
            STRONG_SELF;
            if (aParam.requestType != QWRequestTypeGet) {
                NSLog(@"\n\nrequest url is:\n\n\t%@\n\nparams is:\n\n\t%@\n\nerror is:\n\n\t%@\n\n",[response.URL.absoluteString stringByRemovingPercentEncoding], aParam.requestParam, error);
            }
            else {
                NSLog(@"\n\nrequest url is:\n\n\t%@\n\nerror is:\n\n\t%@\n\n",[response.URL.absoluteString stringByRemovingPercentEncoding], error);
            }
            
            if (error) {
                
                [self handlePostErrorWithResponse:response error:error];
                
                if (aParam.callbackBlock) {
                    aParam.callbackBlock(nil, error);
                }
            }
            else {
                if (aParam.callbackBlock) {
                    aParam.callbackBlock(filePath, error);
                }
            }
        }];
    }
    
    aParam.progress = progress;
    
    [task resume];
    return task;
}

- (NSProgress *)uploadWithParam:(QWOperationParam *)aParam
{
    NSURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:aParam.requestUrl parameters:aParam.requestParam constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *imageData = UIImageJPEGRepresentation(aParam.uploadImage, 0.75);
        if (imageData) {
            [formData appendPartWithFileData:imageData name:@"file" fileName:@"file" mimeType:@"image/jpeg"];
        }
        
        for (NSString *key in aParam.requestParam.allKeys) {
            NSData *data = [[[aParam.requestParam objectForKey:key] description] dataUsingEncoding:NSUTF8StringEncoding];
            [formData appendPartWithFormData:data name:key];
        }
        
    } error:NULL];
    
    NSProgress *temp = nil;
    
    WEAK_SELF;
    __block  NSURLSessionUploadTask *task = [self uploadTaskWithStreamedRequest:request progress:&temp completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        STRONG_SELF;
        if (error) {
            if (aParam.printLog) {
                if (aParam.requestType != QWRequestTypeGet) {
                    NSLog(@"\n\nrequest url is:\n\n\t%@\n\nparams is:\n\n\t%@\n\nerror is:\n\n\t%@\n\n",[response.URL.absoluteString stringByRemovingPercentEncoding], aParam.requestParam, error);
                }
                else {
                    NSLog(@"\n\nrequest url is:\n\n\t%@\n\nerror is:\n\n\t%@\n\n",[response.URL.absoluteString stringByRemovingPercentEncoding], error);
                }
            }
            
            [self handlePostErrorWithResponse:response error:error];
            
            if (aParam.callbackBlock) {
                aParam.callbackBlock(nil, error);
            }
        }
        else {
            responseObject = [self convertDataToObject:task responseObject:responseObject];
            
            if (aParam.printLog) {
                if (aParam.requestType != QWRequestTypeGet) {
                    NSLog(@"\n\nrequest url is:\n\n\t%@\n\nparams is:\n\n\t%@\n\nrespponse is:\n\n\t%@\n\n",[response.URL.absoluteString stringByRemovingPercentEncoding], aParam.requestParam, responseObject);
                }
                else {
                    NSLog(@"\n\nrequest url is:\n\n\t%@\n\nrespponse is:\n\n\t%@\n\n",[response.URL.absoluteString stringByRemovingPercentEncoding], responseObject);
                }
            }
            if (aParam.callbackBlock) {
                aParam.callbackBlock(responseObject, nil);
            }
        }
    }];
    
    [task resume];
    return temp;
}

/**
 *  功能:取消当前manager queue中所有网络请求
 */

- (void)cancelAllOperations
{
    NSArray *tasks = self.tasks.copy;
    for (NSURLSessionDataTask *task in tasks) {
        [task cancel];
    }
}

/**
 *  功能:取消当前manager queue中所有网络请求，并从network manager中移除
 */
- (void)cancelOperationsAndRemoveFromNetworkManager
{
    [self cancelAllOperations];
    
    [self invalidateSessionCancelingTasks:YES];
    
    [[QWNetworkManager sharedInstance] removeoperationManager:self];
}

- (id)convertDataToObject:(NSURLSessionDataTask *)task responseObject:(id)responseObject
{
    //json
    id object = [[AFJSONResponseSerializer serializer] responseObjectForResponse:task.response data:responseObject error:nil];
    
    if (!object) {
        //image
        object = [[AFImageResponseSerializer serializer] responseObjectForResponse:task.response data:responseObject error:nil];
    }
    
    return object;
}

- (void)handlePostErrorWithTask:(NSURLSessionTask *)task error:(NSError *)error
{
    [self handlePostErrorWithResponse:task.response error:error];
}

- (void)handlePostErrorWithResponse:(NSURLResponse *)response error:(NSError *)error
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *res = (id)response;
        if (res.statusCode == 403) {//token失效
            NSLog(@"登陆失效");
            [[QWGlobalValue sharedInstance] clear];
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_STATE_CHANGED object:nil];
        }
    }
}

@end
