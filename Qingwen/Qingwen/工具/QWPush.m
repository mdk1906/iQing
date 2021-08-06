//
//  QWPush.m
//  
//
//  Created by Aimy on 9/3/15.
//
//

#import "QWPush.h"

#import "QWPush.h"
#import "QWMyCenterLogic.h"
#import "NSObject+category.h"
#import "QWNetworkManager.h"
#import "QWKeychain.h"

@interface QWPush ()

@property (nonatomic, strong) QWMyCenterLogic *logic;
@property (nonatomic, getter=isRegistedPush) BOOL registedPush;
@end

@implementation QWPush

DEF_SINGLETON(QWPush);

- (instancetype)init
{
    self = [super init];
    self.registedPush = [[QWKeychain sharedInstance][@"registedPush"] boolValue];

    WEAK_SELF;
    [self observeNotification:LOGIN_STATE_CHANGED withBlock:^(__weak id self, NSNotification *notification) {
        KVO_STRONG_SELF;
        if ( ! notification) {
            return;
        }

        [kvoSelf registPush];
    }];

    return self;
}

#pragma mark - Network
- (QWOperationManager *)operationManager
{
    QWOperationManager *manager = [self objc_getAssociatedObject:@"operationManager"];
    if (manager == nil) {
        manager = [[QWNetworkManager sharedInstance] generateoperationManagerWithOwner:self];
        [self objc_setAssociatedObject:@"operationManager" value:manager policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
    }

    return manager;
}

- (QWMyCenterLogic *)logic
{
    if ( ! _logic) {
        _logic = [QWMyCenterLogic logicWithOperationManager:self.operationManager];
    }

    return _logic;
}

- (void)registPush
{
    if ( ! [QWGlobalValue sharedInstance].isLogin || ! [QWGlobalValue sharedInstance].pushId.length || ! [QWGlobalValue sharedInstance].deviceToken.length) {
        return ;
    }

    WEAK_SELF;
    [self.logic registPushWithCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;

    }];
}

- (void)unRegist
{
    
}

@end
