//
//  QWShareManager.h
//  Qingwen
//
//  Created by Aimy on 8/20/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QWWXLoginDelegate <NSObject>

- (void)loginWXSuccessWithCode:(NSString * __nullable)code;

@end

@protocol QWQQLoginDelegate <NSObject>

- (void)loginQQSuccessWithJsonResponse:(NSDictionary * __nullable)jsonResponse;

@end

@protocol QWWBLoginDelegate <NSObject>

- (void)loginWBSuccessWithJsonResponse:(NSDictionary *__nullable)jsonResponse;

@end

@interface QWShareManager : NSObject

+ (QWShareManager * __nonnull)sharedInstance;

+ (BOOL)handleOpenUrl:(nullable NSURL *)url sourceApplication:(nullable NSString *)sourceApplication;

- (void)showWithTitle:(NSString * __nullable)aTitle image:(NSString * __nullable)aImage intro:(NSString * __nullable)aIntro url:(NSString * __nullable)aUrl dataDic:(NSDictionary * __nullable)adataDic;

- (void)sendMessageWithqq:(NSString * __nonnull)qqNumber;

- (void)qqLogin;

- (void)wxLogin;

- (void)wbLogin;
@property (nonatomic, weak) __nullable id <QWWXLoginDelegate> wxLoginDelegate;

@property (nonatomic, weak) __nullable id <QWQQLoginDelegate> qqLoginDelegate;

@property (nonatomic, weak) __nullable id <QWWBLoginDelegate> wbLoginDelegate;

@end
