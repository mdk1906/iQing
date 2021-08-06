//
//  QWPatch.m
//  Qingwen
//
//  Created by Aimy on 7/20/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWPatch.h"

#import <JSPatch/JPEngine.h>
#import "QWFileManager.h"
#import "QWNetworkManager.h"
#import "QWOperationManager.h"

@interface QWPatch ()

@property (nonatomic, strong) QWOperationManager *operationManager;

@end

@implementation QWPatch

DEF_SINGLETON(QWPatch);

- (QWOperationManager *)operationManager
{
    if (!_operationManager) {
        _operationManager = [[QWNetworkManager sharedInstance] generateoperationManagerWithOwner:self];
        _operationManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        _operationManager.operationQueue.maxConcurrentOperationCount = 1;
    }

    return _operationManager;
}

- (void)config
{
    [JPEngine startEngine];
    [JPEngine context][@"clientAppVersion"] = [QWTracker sharedInstance].Build;
    [self.class doPatch];

    [self observeNotification:UIApplicationDidBecomeActiveNotification withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }
        
        [QWPatch getPatch];
    }];
}

+ (void)getPatch
{
    QWPatch *patch = [QWPatch sharedInstance];
    NSString *path = [NSString stringWithFormat:@"%@/%@-patch.js", [QWFileManager qingwenPath], [QWTracker sharedInstance].Build];
    NSString *tempPath = [NSString stringWithFormat:@"%@/%@-patch-temp.js", [QWFileManager qingwenPath], [QWTracker sharedInstance].Build];

    NSString *url = [NSString stringWithFormat:@"https://www.iqing.in/ios/v%@/patch.js", [QWTracker sharedInstance].Build];
    NSURLSessionDownloadTask *task = [patch.operationManager downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return [[NSURL alloc] initFileURLWithPath:tempPath];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"patch get file = %@, error = %@", filePath, error);
        if (!error && filePath) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            [[NSFileManager defaultManager] moveItemAtPath:tempPath toPath:path error:nil];
            [self doPatch];
        }
        else {
            [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
        }
    }];

    [task resume];
}

+ (void)doPatch
{
    NSString *sourcePath = [NSString stringWithFormat:@"%@/%@-patch.js", [QWFileManager qingwenPath], [QWTracker sharedInstance].Build];
//    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"patch" ofType:@"js"];
    NSString *script = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
    if (script && [script rangeOfString:@"404"].location == NSNotFound) {
        [JPEngine evaluateScript:script];
    }
}

@end
