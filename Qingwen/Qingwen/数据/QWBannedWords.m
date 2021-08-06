//
//  QWBannedWords.m
//  Qingwen
//
//  Created by mumu on 17/1/20.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWBannedWords.h"
#import "Base64.h"

@interface QWBannedWords ()

@property (nonatomic, copy) NSArray *bannedWords;

@property (nonatomic, strong) QWOperationManager *operationManager;

@end

@implementation QWBannedWords

DEF_SINGLETON(QWBannedWords);


- (QWOperationManager *)operationManager
{
    if (!_operationManager) {
        _operationManager = [[QWNetworkManager sharedInstance] generateoperationManagerWithOwner:self];
        _operationManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        _operationManager.operationQueue.maxConcurrentOperationCount = 1;
    }
    
    return _operationManager;
}

- (void)getBannedWords {

    [[QWTracker sharedInstance] configHeader:self.operationManager.requestSerializer];
    WEAK_SELF;
    [self.operationManager GET:[NSString stringWithFormat:@"%@/shield_word_base64/",[QWOperationParam currentDomain]] parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        STRONG_SELF;
        if (responseObject) {
            [self decodeBandWords:responseObject];
        }
    } failure:nil];
}

- (void)decodeBandWords:(NSData *)data{
    
    if (data == nil) { //迷之Bug  日
        return;
    }
    NSString *decodingStr = [[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] base64DecodedString];
    NSData *jsonData = [decodingStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error;
    
    id array = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    if (array && !error && [array isKindOfClass:[NSArray class]]) {
        self.bannedWords = array;
    } else {
        self.bannedWords = nil;
    }
}

- (NSString *)cryptoStringWithText:(NSString *)text {
    
    __block NSString *orginalText = text;
    [self.bannedWords  enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([orginalText containsString:obj]) {
            NSString *placeholder = @"";
            for (int i = 0; i < obj.length; i ++) {
                placeholder = [placeholder stringByAppendingString:@"*"];
            }
            orginalText = [orginalText stringByReplacingOccurrencesOfString:obj withString:placeholder];
        }
    }];
    return orginalText;
}

@end
