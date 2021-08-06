//
//  QWWebView.m
//  
//
//  Created by Aimy on 9/7/15.
//
//

#import "QWWebView.h"

#import "QWWeakObjectDeathNotifier.h"
#import "QWTracker.h"

@implementation QWWebView

#pragma mark - cookies
+ (void)setCookie:(NSString *)aDomain name:(NSString *)aName value:(NSString *)aValue
{
    if (!aName) {
        return ;
    }

    if (!aValue) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies.copy enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSHTTPCookie *cookie = obj;
            if ([cookie.properties[NSHTTPCookieName] isEqualToString:aName]) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:obj];
                *stop = YES;
            }
        }];
        return ;
    }

    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    cookieProperties[NSHTTPCookieDomain] = aDomain;
    cookieProperties[NSHTTPCookieName] = aName;
    cookieProperties[NSHTTPCookieValue] = aValue;
    cookieProperties[NSHTTPCookiePath] = @"/";
    cookieProperties[NSHTTPCookieVersion] = @"0";

    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}

+ (void)setCookieName:(NSString *)aName value:(NSString *)aValue
{
    [self setCookie:@".iqing.in" name:aName value:aValue];
    [self setCookie:@".iqing.com" name:aName value:aValue];
}

+ (void)setupDefaultCookies
{
    [[QWTracker sharedInstance] configCookies];
}

+ (void)clearCookies
{
    [[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies.copy enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:obj];
    }];
}

- (void)setDelegate:(id<UIWebViewDelegate>)delegate
{
    [super setDelegate:delegate];

    if (delegate == nil) {
        return;
    }

    QWWeakObjectDeathNotifier *wo = [QWWeakObjectDeathNotifier new];
    [wo setOwner:delegate];
    WEAK_SELF;
    [wo setBlock:^(QWWeakObjectDeathNotifier *sender) {
        STRONG_SELF;
        self.delegate = nil;
    }];
}

@end
