//
//  QWTracker.m
//  Qingwen
//
//  Created by Aimy on 7/24/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWTracker.h"

#import "QWWebView.h"

@implementation QWTracker

DEF_SINGLETON(QWTracker)

- (instancetype)init
{
    self = [super init];

    _beta = getenv("QW_BETA") != nil;

    _AppVersion = @"v3";

    if (IS_IPHONE_DEVICE) {
        _System = @"iphone";
    }
    else {
        _System = @"ipad";
    }

#ifdef DEBUG
    NSString *model = [UIDevice currentDevice].model;
    if ([model rangeOfString:@"iPhone Simulator"].location != NSNotFound) {
//        _System = @"android";
    }
#endif

    _Version = [UIDevice currentDevice].systemVersion;

    _GUID =
    ({
        NSString *uuid = [QWKeychain getKeychainValueForType:@"UUID"];
        if (!uuid) {
          uuid = [UIDevice currentDevice].identifierForVendor.UUIDString;
          [QWKeychain setKeychainValue:uuid forType:@"UUID"];
        }
        uuid;
    });

    _Build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];

    if (self.isBeta) {
        _channel = @"STORE-BETA";
    }
    else {
        _channel = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"channel"];
    }
    _track = [NSString stringWithFormat:@"%@-%@", _Build, _channel];
    _BuildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    _AppName = @"iqing";
    _Country = @"b3RoZXI=";//other
    return self;
}

- (void)configHeader:(AFHTTPRequestSerializer *)requestSerializer
{
    [requestSerializer setValue:_AppVersion forHTTPHeaderField:@"AppVersion"];
    [requestSerializer setValue:_System forHTTPHeaderField:@"System"];
    [requestSerializer setValue:_Version forHTTPHeaderField:@"Version"];
    [requestSerializer setValue:_GUID forHTTPHeaderField:@"GUID"];
    [requestSerializer setValue:_track forHTTPHeaderField:@"Build"];
    [requestSerializer setValue:_channel forHTTPHeaderField:@"channel"];
    [requestSerializer setValue:_BuildVersion forHTTPHeaderField:@"BuildVersion"];
    [requestSerializer setValue:_Country forHTTPHeaderField:@"Country"];
    if([QWGlobalValue sharedInstance].location){
        NSLog(@"%@", [QWGlobalValue sharedInstance].location);
        [requestSerializer setValue:[QWGlobalValue sharedInstance].location forHTTPHeaderField:@"Country"];
    }
   
    
   
}

- (void)configRequestHeader:(NSMutableURLRequest *)request
{
    [request addValue:_AppVersion forHTTPHeaderField:@"AppVersion"];
    [request addValue:_System forHTTPHeaderField:@"System"];
    [request addValue:_Version forHTTPHeaderField:@"Version"];
    [request addValue:_GUID forHTTPHeaderField:@"GUID"];
    [request addValue:_track forHTTPHeaderField:@"Build"];
    [request addValue:_channel forHTTPHeaderField:@"channel"];
    [request addValue:_BuildVersion forHTTPHeaderField:@"BuildVersion"];
    [request addValue:_Country forHTTPHeaderField:@"Country"];
}

- (void)configCookies
{
    [QWWebView setCookieName:@"ngame" value:@"1"];
    [QWWebView setCookieName:@"AppVersion" value:_AppVersion];
    [QWWebView setCookieName:@"System" value:_System];
    [QWWebView setCookieName:@"Version" value:_Version];
    [QWWebView setCookieName:@"GUID" value:_GUID];
    [QWWebView setCookieName:@"Build" value:_track];
    [QWWebView setCookieName:@"channel" value:_channel];
    [QWWebView setCookieName:@"BuildVersion" value:_BuildVersion];
    [QWWebView setCookieName:@"AppName" value:_AppName];
    [QWWebView setCookieName:@"Country" value:_Country];
}

@end
