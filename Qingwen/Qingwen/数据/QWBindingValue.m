//
//  QWBindingValue.m
//  Qingwen
//
//  Created by mumu on 2017/8/14.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWBindingValue.h"

NSString *const BINDING_CHANGED = @"BINDING_CHANGED";

@interface QWBindingValue()

@property (nonatomic, strong) QWMyCenterLogic *logic;

@end

@implementation QWBindingValue

DEF_SINGLETON(QWBindingValue);

- (instancetype)init {
    self = [super init];
    self.qq = [BindingVO voWithJson:[QWKeychain getKeychainValueForType:@"qq"]];
    self.wx = [BindingVO voWithJson:[QWKeychain getKeychainValueForType:@"wx"]];
    self.sina = [BindingVO voWithJson:[QWKeychain getKeychainValueForType:@"sina"]];
    self.bindPhone = [BindingVO voWithJson:[QWKeychain getKeychainValueForType:@"bindPhone"]];
    self.autor = [AuthenticationVO voWithJson:[QWKeychain getKeychainValueForType:@"autor"]];
    return self;
}

- (QWMyCenterLogic *)logic
{
    if (!_logic) {
        _logic = [QWMyCenterLogic logicWithOperationManager:self.operationManager];
    }
    
    return _logic;
}

- (void)update {
    
    if (![QWGlobalValue sharedInstance].isLogin) {
        return;
    }
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    WEAK_SELF;
    QWOperationParam *param = [QWInterface getWithDomainUrl:@"bind_list/" params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (aResponseObject && !anError) {
            NSDictionary *qq = [aResponseObject firstObject];
            NSDictionary *wx = [aResponseObject objectAtIndex:1];
            NSDictionary *sina = [aResponseObject objectAtIndex:2];
            NSDictionary *bindPhone = [aResponseObject objectAtIndex:3];
            NSDictionary *author = [aResponseObject lastObject];
            self.qq = [BindingVO voWithDict:qq];
            self.wx = [BindingVO voWithDict:wx];
            self.sina = [BindingVO voWithDict:sina];
            self.bindPhone = [BindingVO voWithDict:bindPhone];
            self.autor = [AuthenticationVO voWithDict:author];
            [self save];
            [[NSNotificationCenter defaultCenter] postNotificationName:BINDING_CHANGED object:nil];
        }
    }];
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

- (void)save {
    
    [QWKeychain setKeychainValue:self.qq.toJSONString forType:@"qq"];
    [QWKeychain setKeychainValue:self.wx.toJSONString forType:@"wx"];
    [QWKeychain setKeychainValue:self.sina.toJSONString forType:@"sina"];
    [QWKeychain setKeychainValue:self.bindPhone.toJSONString forType:@"bindPhone"];
    [QWKeychain setKeychainValue:self.autor.toJSONString forType:@"autor"];
}

- (void)clear {
    
    [QWBindingValue sharedInstance].qq = nil;
    [QWBindingValue sharedInstance].wx = nil;
    [QWBindingValue sharedInstance].sina = nil;
    [QWBindingValue sharedInstance].bindPhone = nil;
    [QWBindingValue sharedInstance].autor = nil;
    [self save];
}

- (BOOL)isBindPhone {
    return self.bindPhone.binding.boolValue;
}

- (BOOL)isAuthentication {
    return self.autor.binding.boolValue;
}
@end
