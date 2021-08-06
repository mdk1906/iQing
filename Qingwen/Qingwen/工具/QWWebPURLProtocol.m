//
//  QWWebPURLProtocol.m
//  Qingwen
//
//  Created by mumu on 2017/6/21.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWWebPURLProtocol.h"
#import <SDWebImage/UIImage+WebP.h>

static NSString *URLProtocolHandledKey = @"URLHasHandle";

@interface QWWebPURLProtocol()<NSURLSessionDelegate, NSURLSessionDataDelegate,NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLConnection *connection;

@property (strong, nonatomic) NSMutableData *reciveData;

@end

@implementation QWWebPURLProtocol

- (void)dealloc {
    self.reciveData = nil;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    //只处理http和https请求
    NSString *scheme = [[request URL] scheme];
    if ( ([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame ||
          [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame))
    {
        //看看是否已经处理过了，防止无限循环
        if ([NSURLProtocol propertyForKey:URLProtocolHandledKey inRequest:request]) {
            return NO;
        }
        return YES;
    }
    return NO;
}

+ (NSURLRequest *) canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

#pragma mark 通信协议内容实现
- (void)startLoading
{
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    //标示改request已经处理过了，防止无限循环
    [NSURLProtocol setProperty:@YES forKey:URLProtocolHandledKey inRequest:mutableReqeust];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    
    NSString *path = [QWFileManager getWebImagePathWithUrl:self.request.URL.absoluteString];
    if ([QWFileManager isFileExistWithFileUrl:path]) {
        mutableReqeust.URL = [NSURL fileURLWithPath:path];
        [[self.session dataTaskWithRequest:mutableReqeust] resume];

    }
    else {
        [[self.session dataTaskWithRequest:mutableReqeust] resume];
    }
}

- (void)stopLoading
{
    if (self.session) {
        [self.session invalidateAndCancel];
    }
    self.session = nil;
}

#pragma mark dataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    if (completionHandler) {
        completionHandler(NSURLSessionResponseAllow);
    }
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    
    NSData *transData = data;
    
    if ([dataTask.currentRequest.URL.absoluteString containsString:@"webp"]) {
        NSLog(@"webp---%@---替换它",dataTask.currentRequest.URL);
        //采用 SDWebImage 的转换方法
        UIImage *imgData = [UIImage sd_imageWithWebPData:data];
        transData = UIImageJPEGRepresentation(imgData, 1.0f);
        if (!self.reciveData) {
            self.reciveData = [NSMutableData new];
        }
        if (data) {
            [self.reciveData appendData:data];
        }
    }
    else {
        [self.client URLProtocol:self didLoadData:transData];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error{
    
    if (error) {
        [self.client URLProtocol:self didFailWithError:error];
    }
    else{
        if (self.reciveData.length > 0) {
            UIImage *imgData = [UIImage sd_imageWithWebPData:self.reciveData];
            NSData *transData = UIImageJPEGRepresentation(imgData, 1.0f);
            NSString *path = [QWFileManager getWebImagePathWithUrl:task.currentRequest.URL.absoluteString];
            [transData writeToFile:path atomically:YES];
            
            [self.client URLProtocol:self didLoadData:transData];
        }
        [self.client URLProtocolDidFinishLoading:self];
    }
    
}

@end
