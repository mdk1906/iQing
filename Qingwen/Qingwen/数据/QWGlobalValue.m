//
//  QWGlobalValue.m
//  Qingwen
//
//  Created by Aimy on 7/9/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWGlobalValue.h"

#import "QWMyCenterLogic.h"

NSString * const LOGIN_STATE_CHANGED = @"LOGIN_STATE_CHANGED";
NSString * const LOCATE_CHANGED = @"LOCATE_CHANGED";

@interface QWGlobalValue ()

@property (nonatomic, strong) QWDeadtimeTimer *timer;
@property (nonatomic, strong) QWOperationManager *operationManager;
@property (nonatomic, strong) QWMyCenterLogic *logic;

@end

@implementation QWGlobalValue

DEF_SINGLETON(QWGlobalValue);

- (instancetype)init
{
    self = [super init];
    self.token = [QWKeychain getKeychainValueForType:@"token"];
    self.isPublished = [QWKeychain getKeychainValueForType:@"isPublished"];
    self.pushId = [QWKeychain getKeychainValueForType:@"pushId"];
    self.deviceToken = [QWKeychain getKeychainValueForType:@"deviceToken"];
    self.nid = [QWKeychain getKeychainValueForType:@"nid"];
    self.username = [QWKeychain getKeychainValueForType:@"username"];
    self.level = [QWKeychain getKeychainValueForType:@"level"];
    self.vip_date = [QWKeychain getKeychainValueForType:@"vip_date"];
    self.profile_url = [QWKeychain getKeychainValueForType:@"profile_url"];
    self.user = [UserVO voWithJson:[QWKeychain getKeychainValueForType:@"user"]];
    self.unread = [QWKeychain getKeychainValueForType:@"unread"];
    self.officialCount = [QWKeychain getKeychainValueForType:@"officialCount"] ?: @0;
    self.oldOfficialCount = [QWKeychain getKeychainValueForType:@"oldOfficialCount"] ?: @0;
    self.channel_token = [QWKeychain getKeychainValueForType:@"channel_token"];
    self.created_favorite = [QWKeychain getKeychainValueForType:@"created_favorite"] ?: @0;
    //    self.postDic = [QWKeychain getKeychainValueForType:@"POST_LOG_DIC"];
    self.systemSwitchesDic = [QWKeychain getKeychainValueForType:@"systemSwitchesDic"];
    self.globalAdDic = [QWKeychain getKeychainValueForType:@"globalAdDic"];
    
    //广告开关
    self.checkin_ad = [QWKeychain getKeychainValueForType:@"checkin_ad"];
    self.favorite_ad = [QWKeychain getKeychainValueForType:@"favorite_ad"];
    self.read_ad = [QWKeychain getKeychainValueForType:@"read_ad"];
    self.splash_ad = [QWKeychain getKeychainValueForType:@"splash_ad"];
    self.square_ad = [QWKeychain getKeychainValueForType:@"square_ad"] ? :@"2";;
    self.active_ad = [QWKeychain getKeychainValueForType:@"active_ad"];
    self.brand_ad = [QWKeychain getKeychainValueForType:@"brand_ad"] ? :@"2";
    self.download_ad = [QWKeychain getKeychainValueForType:@"download_ad"];
    self.topic_ad = [QWKeychain getKeychainValueForType:@"topic_ad"];
    self.upper_ad = [QWKeychain getKeychainValueForType:@"upper_ad"] ? :@"2";;
    self.index_ad = [QWKeychain getKeychainValueForType:@"index_ad"] ? :@"2";;
    
    //广告sdk设置
    self.checkin_adInc = [QWKeychain getKeychainValueForType:@"checkin_adInc"];
    self.favorite_adInc = [QWKeychain getKeychainValueForType:@"favorite_adInc"];
    self.read_adInc = [QWKeychain getKeychainValueForType:@"read_adInc"];
    self.splash_adInc = [QWKeychain getKeychainValueForType:@"splash_adInc"];
    self.square_adInc = [QWKeychain getKeychainValueForType:@"square_adInc"];
    self.active_adInc = [QWKeychain getKeychainValueForType:@"active_adInc"];
    self.brand_adInc = [QWKeychain getKeychainValueForType:@"brand_adInc"];
    self.download_adInc = [QWKeychain getKeychainValueForType:@"download_adInc"];
    self.topic_adInc = [QWKeychain getKeychainValueForType:@"topic_adInc"];
    self.upper_adInc = [QWKeychain getKeychainValueForType:@"upper_adInc"];
    self.index_adInc = [QWKeychain getKeychainValueForType:@"index_adInc"];
    
    //广告跳转URL
    self.checkin_adURL = [QWKeychain getKeychainValueForType:@"checkin_adURL"];
    self.favorite_adURL = [QWKeychain getKeychainValueForType:@"favorite_adURL"];
    self.read_adURL = [QWKeychain getKeychainValueForType:@"read_adURL"];
    self.splash_adURL = [QWKeychain getKeychainValueForType:@"splash_adURL"];
    self.square_adURL = [QWKeychain getKeychainValueForType:@"square_adURL"];
    self.active_adURL = [QWKeychain getKeychainValueForType:@"active_adURL"];
    self.brand_adURL = [QWKeychain getKeychainValueForType:@"brand_adURL"];
    self.download_adURL = [QWKeychain getKeychainValueForType:@"download_adURL"];
    self.topic_adURL = [QWKeychain getKeychainValueForType:@"topic_adURL"];
    self.upper_adURL = [QWKeychain getKeychainValueForType:@"upper_adURL"];
    self.index_adURL = [QWKeychain getKeychainValueForType:@"index_adURL"];
    
    self.postArr = [QWUserDefaults getValueForKey:@"POST_LOG_ARR"];
    self.readTaskTime = [QWUserDefaults getValueForKey:@"readTaskTime"] ?: @0;
    
    if (self.postArr == nil) {
        self.postArr = [NSMutableArray new];
        [[QWUserDefaults sharedInstance]setObject:self.postArr forKeyedSubscript:@"POST_LOG_ARR"];
    }
    self.viewApperDate = nil;
    
    
    return self;
}

- (void)config
{
    WEAK_SELF;
    [self observeNotification:UIApplicationDidBecomeActiveNotification withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }
        
        KVO_STRONG_SELF;
        [kvoSelf getUnread];
        [kvoSelf getLocation];
    }];
    
    [self observeNotification:LOGIN_STATE_CHANGED withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }
        
        KVO_STRONG_SELF;
        [kvoSelf getUnread];
    }];
    
    self.timer = [QWDeadtimeTimer new];
    [self.timer runWithDeadtime:[NSDate distantFuture] andBlock:^(NSDateComponents *dateComponents) {
        static NSInteger second = 0;
        KVO_STRONG_SELF;
        if (second % 60 == 0) {
            [kvoSelf getUnread];
        }
        second++;
    }];
}

- (QWOperationManager *)operationManager
{
    if (!_operationManager) {
        _operationManager = [[QWNetworkManager sharedInstance] generateoperationManagerWithOwner:self];
    }
    
    return _operationManager;
}

- (QWMyCenterLogic *)logic
{
    if (!_logic) {
        _logic = [QWMyCenterLogic logicWithOperationManager:self.operationManager];
    }
    
    return _logic;
}

- (void)getUnread
{
    __block NSInteger step = 1;
    
    WEAK_SELF;
    [self.logic getUnreadMessageWithCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (! anError) {
            NSNumber *unread = aResponseObject[@"all_unread_num"];
            self.logic.unread = unread;
            [self updateWithStep:&step];
        }
    }];
    //每隔一分钟发一次请求
    NSMutableDictionary *params = [NSMutableDictionary new];
    [QWUserStatistics sendEventToServer:@"Beats" pageID:@"Beats" extra:params];
    [QWUserStatistics postDataToServers];
    
}

- (void)updateWithStep:(NSInteger *)step {
    *step = *step - 1;
    if (*step > 0) {
        return ;
    }
    self.unread = self.logic.unread;
    [self save];
    [UIApplication sharedApplication].applicationIconBadgeNumber = self.unread.integerValue;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UNREAD_CHANGED" object:nil];
}


- (void)save
{
    [QWKeychain setKeychainValue:self.token forType:@"token"];
    [QWKeychain setKeychainValue:self.isPublished forType:@"isPublished"];
    [QWKeychain setKeychainValue:self.pushId forType:@"pushId"];
    [QWKeychain setKeychainValue:self.deviceToken forType:@"deviceToken"];
    [QWKeychain setKeychainValue:self.nid forType:@"nid"];
    [QWKeychain setKeychainValue:self.username forType:@"username"];
    [QWKeychain setKeychainValue:self.level forType:@"level"];
    [QWKeychain setKeychainValue:self.vip_date forType:@"vip_date"];
    [QWKeychain setKeychainValue:self.profile_url forType:@"profile_url"];
    [QWKeychain setKeychainValue:self.user.toJSONString forType:@"user"];
    [QWKeychain setKeychainValue:self.unread forType:@"unread"];
    [QWKeychain setKeychainValue:self.officialCount forType:@"officialCount"];
    [QWKeychain setKeychainValue:self.oldOfficialCount forType:@"oldOfficialCount"];
    [QWKeychain setKeychainValue:self.channel_token forType:@"channel_token"];
    [QWKeychain setKeychainValue:self.location forType:@"location"];
    [QWKeychain setKeychainValue:self.created_favorite forType:@"created_favorite"];
    [QWKeychain setKeychainValue:self.systemSwitchesDic forType:@"systemSwitchesDic"];
}
-(void)globalDicSave{
    //广告开关
    [QWKeychain setKeychainValue:self.checkin_ad forType:@"checkin_ad"];
    [QWKeychain setKeychainValue:self.favorite_ad forType:@"favorite_ad"];
    [QWKeychain setKeychainValue:self.read_ad forType:@"read_ad"];
    [QWKeychain setKeychainValue:self.splash_ad forType:@"splash_ad"];
    [QWKeychain setKeychainValue:self.square_ad forType:@"square_ad"];
    [QWKeychain setKeychainValue:self.active_ad forType:@"active_ad"];
    [QWKeychain setKeychainValue:self.brand_ad forType:@"brand_ad"];
    [QWKeychain setKeychainValue:self.download_ad forType:@"download_ad"];
    [QWKeychain setKeychainValue:self.topic_ad forType:@"topic_ad"];
    [QWKeychain setKeychainValue:self.upper_ad forType:@"upper_ad"];
    [QWKeychain setKeychainValue:self.index_ad forType:@"index_ad"];
    
    //广告sdk设置
    [QWKeychain setKeychainValue:self.checkin_adInc forType:@"checkin_adInc"];
    [QWKeychain setKeychainValue:self.favorite_adInc forType:@"favorite_adInc"];
    [QWKeychain setKeychainValue:self.read_adInc forType:@"read_adInc"];
    [QWKeychain setKeychainValue:self.splash_adInc forType:@"splash_adInc"];
    [QWKeychain setKeychainValue:self.square_adInc forType:@"square_adInc"];
    [QWKeychain setKeychainValue:self.active_adInc forType:@"active_adInc"];
    [QWKeychain setKeychainValue:self.brand_adInc forType:@"brand_adInc"];
    [QWKeychain setKeychainValue:self.download_adInc forType:@"download_adInc"];
    [QWKeychain setKeychainValue:self.topic_adInc forType:@"topic_adInc"];
    [QWKeychain setKeychainValue:self.upper_adInc forType:@"upper_adInc"];
    [QWKeychain setKeychainValue:self.index_adInc forType:@"index_adInc"];
    
    //广告URL跳转
    [QWKeychain setKeychainValue:self.checkin_adURL forType:@"checkin_adURL"];
    [QWKeychain setKeychainValue:self.favorite_adURL forType:@"favorite_adURL"];
    [QWKeychain setKeychainValue:self.read_adURL forType:@"read_adURL"];
    [QWKeychain setKeychainValue:self.splash_adURL forType:@"splash_adURL"];
    [QWKeychain setKeychainValue:self.square_adURL forType:@"square_adURL"];
    [QWKeychain setKeychainValue:self.active_adURL forType:@"active_adURL"];
    [QWKeychain setKeychainValue:self.brand_adURL forType:@"brand_adURL"];
    [QWKeychain setKeychainValue:self.download_adURL forType:@"download_adURL"];
    [QWKeychain setKeychainValue:self.topic_adURL forType:@"topic_adURL"];
    [QWKeychain setKeychainValue:self.upper_adURL forType:@"upper_adURL"];
    [QWKeychain setKeychainValue:self.index_adURL forType:@"index_adURL"];
}
- (void)clear
{
    [QWGlobalValue sharedInstance].token = nil;
    [QWGlobalValue sharedInstance].isPublished = nil;
    [QWGlobalValue sharedInstance].nid = nil;
    [QWGlobalValue sharedInstance].username = nil;
    [QWGlobalValue sharedInstance].level = nil;
    [QWGlobalValue sharedInstance].vip_date = nil;
    [QWGlobalValue sharedInstance].profile_url = nil;
    [QWGlobalValue sharedInstance].user = nil;
    [QWGlobalValue sharedInstance].unread = nil;
    [QWGlobalValue sharedInstance].officialCount = nil;
    [QWGlobalValue sharedInstance].oldOfficialCount = nil;
    [QWGlobalValue sharedInstance].channel_token = nil;
    [QWGlobalValue sharedInstance].created_favorite = nil;
    //    [QWGlobalValue sharedInstance].systemSwitchesDic = nil;
    
    [[QWGlobalValue sharedInstance] save];
}

- (BOOL)isLogin
{
    return self.token != nil;
}

- (BOOL)isAllowdNotification
{
    if (IOS_SDK_LESS_THAN(8.0)) {
        if ([UIApplication sharedApplication].enabledRemoteNotificationTypes != UIRemoteNotificationTypeNone) {
            return YES;
        }
    }
    else {
        if (UIUserNotificationTypeNone != [UIApplication sharedApplication].currentUserNotificationSettings.types) {
            return YES;
        }
    }
    
    return NO;
}

- (void)getLocation
{
    WEAK_SELF;
    [self.logic getUserLocation:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        NSString *location = @"other";
        if (!anError && aResponseObject[@"country"]) {
            location = aResponseObject[@"country"];
        }
        NSString *plainString = location;
        NSData *plainData = [plainString dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64String = [plainData base64EncodedStringWithOptions:0];
        self.location = base64String;
        [self save];
    }];
}

@end
