//
//  QWMyCenterLogic.m
//  Qingwen
//
//  Created by Aimy on 7/10/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWMyCenterLogic.h"

#import "UserVO.h"
#import "QWInterface.h"

@implementation QWMyCenterLogic

- (void)appWasPublished:(QWCompletionBlock)block
{
    NSMutableDictionary *params = @{}.mutableCopy;
    QWOperationParam *param = [QWInterface getWithDomainUrl:@"visitor/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (block) {
            block(aResponseObject, anError);
        }
    }];
    [self.operationManager requestWithParam:param];
}

- (void)loginByVistor:(QWCompletionBlock)block
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"uuid"] = [QWTracker sharedInstance].GUID;
    QWOperationParam *param = [QWInterface getWithDomainUrl:@"visitor/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (block) {
            block(aResponseObject, anError);
        }
    }];
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}


- (void)loginWithName:(NSString *)phone password:(NSString *)password andCompleteBlock:(QWCompletionBlock)block
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"mobile"] = phone;
    params[@"password"] = password;

    QWOperationParam *param = [QWInterface loginWithParam:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (block) {
            block(aResponseObject, anError);
            //查询全局广告设置

        }
    }];

    [self.operationManager requestWithParam:param];
    
}

- (void)logout
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;

    QWOperationParam *param = [QWInterface getWithDomainUrl:@"logout/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        //查询全局广告设置
        

    }];
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
    
    
}

- (void)checkCodeWithPhone:(NSString *)phone code:(NSString *)code registe:(BOOL)registe andCompleteBlock:(QWCompletionBlock)block {
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"mobile"] = phone;
    params[@"code"] = code;
    if (registe) {
        params[@"type"] = @"register";
    }
    else {
        params[@"type"] = @"check_user";
    }
    
    QWOperationParam *param = [QWInterface getWithDomainUrl:@"v3/check_code/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (block) {
            block(aResponseObject, anError);
        }
    }];
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

- (void)checkCodeWithPhone:(NSString *)phone code:(NSString *)code registe:(BOOL)registe
                    save:(BOOL)save andCompleteBlock:(QWCompletionBlock)block {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"mobile"] = phone;
    params[@"code"] = code;
    if (registe) {
        params[@"type"] = @"register";
    }
    else {
        params[@"type"] = @"check_user";
    }
    if (save) {
        params[@"delete"] = @0;
    }
    
    QWOperationParam *param = [QWInterface getWithDomainUrl:@"v3/check_code/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (block) {
            block(aResponseObject, anError);
        }
    }];
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

- (void)registWithName:(NSString *)phone password:(NSString *)password code:(NSString *)code username:(NSString *)username invite:(NSString *)invite andCompleteBlock:(QWCompletionBlock)block
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"mobile"] = phone;
    params[@"password"] = password;
    params[@"code"] = code;
//    params[@"username"] = @"";
    params[@"quick"] = @"1";
    if (invite.length) {
        params[@"uid"] = invite;
    }

    QWOperationParam *param = [QWInterface registWithParam:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (block) {
            block(aResponseObject, anError);
        }
    }];

    [self.operationManager requestWithParam:param];
}

- (void)resetPasswordWithPhone:(NSString *)mobile password:(NSString *)password code:(NSString *)code andCompleteBlock:(QWCompletionBlock)block
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"mobile"] = mobile;
    params[@"password"] = password;
    params[@"code"] = code;

    QWOperationParam *param = [QWInterface resetPasswordWithParam:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (block) {
            block(aResponseObject, anError);
        }
    }];

    [self.operationManager requestWithParam:param];
}

- (void)sendVerificationCodeToPhone:(NSString *)phone registe:(QWVerificationType)registe andCompleteBlock:(QWCompletionBlock)block
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"mobile"] = phone;
    switch (registe) {
        case QWVerificationTypeRegiste:
            params[@"type"] = @"register";
            break;
        case QWVerificationTypeResetPassword:
            params[@"type"] = @"reset_password";
            break;
        case QWVerificationTypeCheck:
            params[@"type"] = @"check_user";
    }
    QWOperationParam *param = [QWInterface sendVerificationCodeWithParam:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (block) {
            block(aResponseObject, anError);
            
        }
    }];

    [self.operationManager requestWithParam:param];
}

- (void)getUserInfoWithCompleteBlock:(QWCompletionBlock)block
{
    if (![QWGlobalValue sharedInstance].isLogin) {
        //如果为空，代表未登录，不需要获取个人信息
        return ;
    }

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;

    QWOperationParam *param = [QWInterface getUserInfoWithParam:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                if (code.integerValue == 13) {
                    [[QWGlobalValue sharedInstance] clear];
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_STATE_CHANGED object:nil];
                }
            }
            else {
                UserVO *user = [UserVO voWithDict:aResponseObject];
                [QWGlobalValue sharedInstance].user = user;
                [QWGlobalValue sharedInstance].channel_token = [aResponseObject objectForKey:@"channel_token"];
                [[QWGlobalValue sharedInstance] save];
            }
        }
        if (block) {
            block(aResponseObject, anError);
        }
    }];

    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

- (void)updateUserWithSex:(NSInteger)sex birthday:(NSDate *)date andCompleteBlock:(QWCompletionBlock)block
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"sex"] = @(sex);
    params[@"birth_day"] = @((long long)(date.timeIntervalSince1970) * 1000);

    QWOperationParam *param = [QWInterface updateUserInfoWithParam:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (block) {
            block(aResponseObject, anError);
        }
    }];

    [self.operationManager requestWithParam:param];
}

- (void)uploadAvatar:(UIImage *)image andCompleteBlock:(QWCompletionBlock)block
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;

    QWOperationParam *param = [QWInterface updateAvatarWithParam:params image:image andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (block) {
            block(aResponseObject, anError);
        }
    }];

    [self.operationManager requestWithParam:param];
}

- (void)migrateWithBookIds:(NSArray *)ids andCompleteBlock:(QWCompletionBlock)block
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;

    if (ids.count > 200) {
        ids = [ids subarrayWithRange:NSMakeRange(0, 200)];
    }

    params[@"books"] = [ids componentsJoinedByString:@","];
    
    QWOperationParam *param = [QWInterface getWithUrl:[QWGlobalValue sharedInstance].user.book_sync_url params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (block) {
            block(aResponseObject, anError);
        }
    }];
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

- (void)registPushWithCompleteBlock:(QWCompletionBlock)block
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"registration_id"] = [QWGlobalValue sharedInstance].pushId;
    params[@"device_code"] = [QWGlobalValue sharedInstance].deviceToken;

    QWOperationParam *param = [QWInterface getWithDomainUrl:@"device_signup/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (block) {
            block(aResponseObject, anError);
        }
    }];
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

- (void)checkinWithCompleteBlock:(QWCompletionBlock)block
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;

    QWOperationParam *param = [QWInterface getWithUrl:[QWGlobalValue sharedInstance].user.check_in_url params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (block) {
            block(aResponseObject, anError);
        }
    }];
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}


- (void)getPushSettingCompleteBlock:(QWCompletionBlock)block
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"registration_id"] = [QWGlobalValue sharedInstance].pushId;

    QWOperationParam *param = [QWInterface getWithDomainUrl:@"push_settings/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                
            }
            else {
                [QWUserDefaults sharedInstance][@"bookpush"] = aResponseObject[@"book"];
                [QWUserDefaults sharedInstance][@"discusspush"] = aResponseObject[@"bf"];
            }
        }

        if (block) {
            block(aResponseObject, anError);
        }
    }];
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

- (void)setPushSettingWithType:(NSInteger)type open:(BOOL)open andCompleteBlock:(QWCompletionBlock)block
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"registration_id"] = [QWGlobalValue sharedInstance].pushId;

    if (type == 0) {
        params[@"book"] = open ? @"true": @"false";
    }
    else if (type == 1) {
        params[@"bf"] = open ? @"true": @"false";
    }

    QWOperationParam *param = [QWInterface getWithDomainUrl:@"update_push_settings/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误

            }
            else {
                if (type == 0) {
                    [QWUserDefaults sharedInstance][@"bookpush"] = @(open);
                }
                else if (type == 1) {
                    [QWUserDefaults sharedInstance][@"discusspush"] = @(open);
                }
            }
        }

        if (block) {
            block(aResponseObject, anError);
        }
    }];
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

- (void)getSubscriberListCompleteBlock:(QWCompletionBlock)block
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    
    QWOperationParam *param = [QWInterface getWithDomainUrl:@"subscriber/auto_purchase_list/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            NSLog(@"result :%@",code);
            if (code && ! [code isEqualToNumber:@0]) {//有错误

            }
            else {

            }
        }
        
        if (block) {
            block(aResponseObject, anError);
        }
    }];
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

- (void)setSubscribedBookCompleteBlock:(NSNumber *)book isSub:(BOOL)isOn CompleteBlock:(QWCompletionBlock)block
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"book"] = book;
    params[@"switch"] = isOn ? @"1": @"0";
    QWOperationParam *param = [QWInterface getWithDomainUrl:@"subscriber/book_auto_switch/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        
        if (block) {
            block(aResponseObject, anError);
        }
    }];
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

- (void)getUnreadMessageWithCompleteBlock:(QWCompletionBlock)block
{
    if (![QWGlobalValue sharedInstance].isLogin) {
        //如果为空，代表未登录，不需要获取个人信息
        return ;
    }

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"get_all_unread_num"] = @(1);
    QWOperationParam *param = [QWInterface getWithDomainUrl:@"messages/message_interface/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误

            }
            else {

            }
        }

        if (block) {
            block(aResponseObject, anError);
        }
    }];
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

#pragma mark 第三方登录

- (void)getCheckUserMobileWithCompleteBlock:(QWCompletionBlock)block {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    QWOperationParam *param = [QWInterface getWithDomainUrl:@"v3/user_mobile/" params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (!anError && aResponseObject) {
            if (block) {
                block(aResponseObject, anError);
            }
        }else {
            if (block) {
                block(nil, anError);
            }
        }
    }];
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

- (void)checkOlderBindCodeWithCode:(NSString *)code type:(NSString *)type CompleteBlock:(QWCompletionBlock)block {
    
}

//微信登录
- (void)registWithWXCode:(NSString *)code andCompleteBlock:(QWCompletionBlock)block {
    WEAK_SELF;
    [self getWXAccessTokenAndOpenIdWithCode:code andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (aResponseObject && !anError) {
            NSLog(@"WX返回的－%@",aResponseObject);
            
            NSMutableDictionary *params = @{}.mutableCopy;
            params[@"state"] = @"weixin";
            params[@"access_token"] = [aResponseObject objectForKey:@"access_token"];
            params[@"openid"] = [aResponseObject objectForKey:@"openid"];
            params[@"username"] = [aResponseObject objectForKey:@"nickname"];
            params[@"sex"] = [aResponseObject objectForKey:@"sex"];
            params[@"headimgurl"] = [aResponseObject objectForKey:@"headimgurl"];
            params[@"unionid"] = [aResponseObject objectForKey:@"unionid"];
            params[@"code"] = code;

            QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/third_party_login/",[QWOperationParam currentDomain]] params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
                if (!anError && aResponseObject) {
                    if (block) {
                        block(aResponseObject, anError);
                    }
                }else {
                    if (block) {
                        block(nil, anError);
                    }
                }
            }];
            param.requestType = QWRequestTypePost;
            [self.operationManager requestWithParam:param];
        }
    }];
}
- (void)registWithQQJsonResponse:(NSDictionary *)jsonResponse andCompleteBlock:(QWCompletionBlock)block {
    if (jsonResponse) {
        
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"state"] = @"qq";
        params[@"access_token"] = [jsonResponse objectForKey:@"access_token"];
        params[@"openid"] = [jsonResponse objectForKey:@"openid"];
        params[@"username"] = [jsonResponse objectForKey:@"nickname"];
        NSString *sex = [jsonResponse objectForKey:@"gender"];
        if ([sex isEqualToString:@"男"]) {
            params[@"sex"] = @1;
        } else {
            params[@"sex"] = @2;

        }
        params[@"headimgurl"] = [jsonResponse objectForKey:@"figureurl_qq_2"];
        
        QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/third_party_login/",[QWOperationParam currentDomain]] params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            if (!anError && aResponseObject) {
                if (block) {
                    block(aResponseObject, anError);
                }
            }else {
                if (block) {
                    block(nil, anError);
                }
            }
        }];
        param.requestType = QWRequestTypePost;
        [self.operationManager requestWithParam:param];
    }
}
- (void)registWithWBJsonResponse:(NSDictionary *)jsonResponse andCompleteBlock:(QWCompletionBlock)block {
    if (jsonResponse) {
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"state"] = @"weibo";
        params[@"access_token"] = [jsonResponse objectForKey:@"access_token"];
        params[@"refresh_token"] = [jsonResponse objectForKey:@"refresh_token"];
        params[@"uid"] = [jsonResponse objectForKey:@"uid"];
        params[@"expires_in"] = [jsonResponse objectForKey:@"expires_in"];
        
        QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/third_party_login/",[QWOperationParam currentDomain]] params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            if (!anError && aResponseObject) {
                if (block) {
                    block(aResponseObject, anError);
                }
            }else {
                if (block) {
                    block(nil, anError);
                }
            }
        }];
        param.requestType = QWRequestTypePost;
        [self.operationManager requestWithParam:param];
    }
}
//绑定列表
- (void)getBindingListWithCompleteBlock:(QWCompletionBlock)block {
    if (![QWGlobalValue sharedInstance].isLogin) {
        return;
    }
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    
    QWOperationParam *param = [QWInterface getWithDomainUrl:@"bind_list/" params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (aResponseObject && !anError) {
            NSDictionary *dic = [aResponseObject lastObject];
            self.bindingList = [BindingVO arrayOfModelsFromDictionaries:aResponseObject error:nil].copy;
            self.authorVO = [AuthenticationVO voWithDict:dic];
            if (block) {
                block(self.bindingList, anError);
            }
        }else {
            if (block) {
                block(nil, anError);
            }
        }
    }];
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

//绑定微信
- (void)boundWithWXCode:(NSString *)code check:(BOOL)check andCompleteBlock:(QWCompletionBlock)block{
    WEAK_SELF;
    [self getWXAccessTokenAndOpenIdWithCode:code andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (aResponseObject && !anError) {
            NSLog(@"WX返回的－%@",aResponseObject);
            
            NSMutableDictionary *params = @{}.mutableCopy;
            params[@"platform"] = @"weixin";
            params[@"access_token"] = [aResponseObject objectForKey:@"access_token"];
            params[@"openid"] = [aResponseObject objectForKey:@"openid"];
            params[@"token"] = [QWGlobalValue sharedInstance].token;
            params[@"unionid"] = [aResponseObject objectForKey:@"unionid"];
            params[@"code"] = code;
            if (check) {
                params[@"inquire"] = @(-1);
            }
            QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/account_binding/",[QWOperationParam currentDomain]] params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
                if (!anError && aResponseObject) {
                    if (block) {
                        block(aResponseObject, anError);
                    }
                } else {
                    if (block) {
                        block(aResponseObject, anError);
                    }
                }
            }];
            param.requestType = QWRequestTypePost;
            [self.operationManager requestWithParam:param];
        }
    }];
}
//绑定QQ
- (void)boundWithQQJsonResponse:(NSDictionary *)jsonResponse check:(BOOL)check andCompleteBlock:(QWCompletionBlock)block; {
    if (jsonResponse) {
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"platform"] = @"qq";
        params[@"access_token"] = [jsonResponse objectForKey:@"access_token"];
        params[@"token"] = [QWGlobalValue sharedInstance].token;
        if (check) {
            params[@"inquire"] = @(-1);
        }
        QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/account_binding/",[QWOperationParam currentDomain]] params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            if (!anError && aResponseObject) {
                if (block) {
                    block(aResponseObject, anError);
                }
            }else {
                if (block) {
                    block(aResponseObject, anError);
                }
            }
        }];
        param.requestType = QWRequestTypePost;
        [self.operationManager requestWithParam:param];
    }
}
- (void)boundWithWbJsonResponse:(NSDictionary *)jsonResponse check:(BOOL)check andCompleteBlock:(QWCompletionBlock)block {
    if (jsonResponse) {
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"platform"] = @"weibo";
        params[@"access_token"] = [jsonResponse objectForKey:@"access_token"];
        params[@"refresh_token"] = [jsonResponse objectForKey:@"refresh_token"];
        params[@"uid"] = [jsonResponse objectForKey:@"uid"];
        params[@"expires_in"] = [jsonResponse objectForKey:@"expires_in"];
        params[@"token"] = [QWGlobalValue sharedInstance].token;
        if (check) {
            params[@"inquire"] = @(-1);
        }
        QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/account_binding/",[QWOperationParam currentDomain]] params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            if (!anError && aResponseObject) {
                if (block) {
                    block(aResponseObject, anError);
                }
            }else {
                if (block) {
                    block(nil, anError);
                }
            }
        }];
        param.requestType = QWRequestTypePost;
        [self.operationManager requestWithParam:param];
    }
}
//解绑
- (void)cancelBoundWithThirdState:(NSString *)state andCompleteBlock:(QWCompletionBlock)block {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"state"] = state;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/account_unbundling/",[QWOperationParam currentDomain]] params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (!anError && aResponseObject) {
            if (block) {
                block(aResponseObject, anError);
            }
        } else {
            if (block) {
                block(aResponseObject, anError);
            }
        }
    }];
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}
//绑定手机
- (void)boundWithPhone:(NSString *)phone password:(NSString *)password code:(NSString *)code andCompleteBlock:(QWCompletionBlock)block {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"phone"] = phone;
    params[@"code"] = code;
//    if (password) {
//        params[@"password"] = password;
//    }
    QWOperationParam *param = [QWInterface getWithDomainUrl:@"change_phone" params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (!anError && aResponseObject) {
            if (block) {
                block(aResponseObject, anError);
            }
        }else {
            if (block) {
                block(nil, anError);
            }
        }
    }];
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

- (void)getWXAccessTokenAndOpenIdWithCode:(NSString *)code andCompleteBlock:(QWCompletionBlock)block{
    NSString *url = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",WeixinAppKey,WeixinAppSecret,code];
    QWOperationParam *param = [QWInterface getWithUrl:url andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        //获得access_token，然后根据access_token获取用户信息请求。
        if (aResponseObject && !anError) {
            NSString *accessToken = [aResponseObject objectForKey:@"access_token"];
            NSString *openId = [aResponseObject objectForKey:@"openid"];
            [self getWXUserInfoWithAccessToken:accessToken openId:openId andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
                if (block) {
                    block(aResponseObject, nil);
                }
            }];
        }else {
            NSLog(@"微信返回错误code－%ld",anError.code);
            if (block) {
                block(nil, anError);
            }
        }
    }];
    self.operationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json", nil];
    [self.operationManager requestWithParam:param];
}

- (void)getWXUserInfoWithAccessToken:(NSString *)accessToken openId:(NSString *)openId andCompleteBlock:(QWCompletionBlock)block {
    NSString *url = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",accessToken,openId];
    QWOperationParam *param = [QWInterface getWithUrl:url andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        NSMutableDictionary *dic = @{}.mutableCopy;
        [dic addEntriesFromDictionary:aResponseObject];
        dic[@"access_token"] = accessToken;
        dic[@"openid"] = openId;
        if (aResponseObject && !anError) {
            if (block) {
                block(dic, nil);
            }
        }else {
            if (block) {
                NSLog(@"微信返回错误code－%ld",anError.code);
                block(nil, anError);
            }
        }
    }];
    [self.operationManager requestWithParam:param];
}

- (void)getUserLocation:(QWCompletionBlock)block {
    NSMutableDictionary *params = @{}.mutableCopy;
    QWOperationParam *param = [QWInterface getWithDomainUrl:@"lookup/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (block) {
            block(aResponseObject, anError);
        }
    }];
    [self.operationManager requestWithParam:param];
}
-(void)pushCommentsVCWithPostUrl:(NSString *)postUrl{
    NSString *routerString = [NSString getRouterVCUrlStringFromUrlString:postUrl];
    
    [[QWRouter sharedInstance] routerWithUrlString:routerString];
}
- (BOOL)canRegistered{
    NSDictionary *dict = QWGlobalValue.sharedInstance.systemSwitchesDic;
    
    NSString *type = [dict[@"register"] stringValue];
    if ([type isEqualToString:@"2"]) {
        return NO;
    }
    else if ([type isEqualToString:@"1"]) {
        if ([QWGlobalValue sharedInstance].isLogin == NO) {
            return NO;
        }
        else{
            return YES;
        }
    }
    else  {
        return YES;
    }
}
@end
