//
//  QWGlobalValue.h
//  Qingwen
//
//  Created by Aimy on 7/9/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UserVO.h"
#import "BindingVO.h"
#import "AuthenticationVO.h"

#define NOT_LOGIN_ERROR [NSError errorWithDomain:@"not login" code:403 userInfo:nil]

UIKIT_EXTERN NSString * const __nonnull LOGIN_STATE_CHANGED;//登录状态修改
UIKIT_EXTERN NSString * const __nonnull LOCATE_CHANGED;//分区状态修改

@interface QWGlobalValue : NSObject

+ (QWGlobalValue * __nonnull)sharedInstance;

@property (nonatomic, copy, nullable) NSString *token;
@property (nonatomic, copy, nullable) NSString *pushId;
@property (nonatomic, copy, nullable) NSString *deviceToken;
@property (nonatomic, copy, nullable) NSNumber *isPublished;

@property (nonatomic, copy, nullable) NSNumber *nid;
@property (nonatomic, copy, nullable) NSString *username;
@property (nonatomic, copy, nullable) NSNumber *created_favorite;
@property (nonatomic, copy, nullable) NSString *vip_date;
@property (nonatomic, copy, nullable) NSString *profile_url;
@property (nonatomic, copy, nullable) NSString *level;
@property (nonatomic, copy, nullable) UserVO *user;

@property (nonatomic, copy, nullable) NSNumber *unread;
@property (nonatomic, copy, nullable) NSNumber *officialCount;
@property (nonatomic, copy, nullable) NSNumber *oldOfficialCount;

@property (nonatomic, copy, nullable) NSString *channel_token; //演绘独特token
@property (nonatomic, copy, nullable) NSNumber *update_username;//是否更新过昵称
@property (nonatomic, copy, nullable) NSString *location;

@property (nonatomic,copy,nullable) NSDictionary *postDic;
@property (nonatomic,copy,nullable) NSMutableArray *postArr;
@property (nonatomic,copy,nullable) NSDate *viewApperDate;
//数据统计配置
@property (nonatomic,copy,nullable) NSString *postUrl;
@property (nonatomic,copy,nullable) NSString *request_interval;
@property (nonatomic,copy,nullable) NSString *beats_time;

//任务系统
@property (nonatomic,copy,nullable) NSNumber *readTaskTime;

//systemswitches
@property (nonatomic,copy,nullable) NSDictionary *systemSwitchesDic;

//全局广告设置
//广告是否显示
@property (nonatomic,copy,nullable) NSDictionary *globalAdDic;
@property (nonatomic,copy,nullable) NSString *checkin_ad;//签到
@property (nonatomic,copy,nullable) NSString *favorite_ad;//收藏
@property (nonatomic,copy,nullable) NSString *read_ad;//阅读
@property (nonatomic,copy,nullable) NSString *splash_ad;//开屏
@property (nonatomic,copy,nullable) NSString *square_ad;//广场
@property (nonatomic,copy,nullable) NSString *active_ad;//活动
@property (nonatomic,copy,nullable) NSString *brand_ad;//榜单
@property (nonatomic,copy,nullable) NSString *download_ad;//下载
@property (nonatomic,copy,nullable) NSString *topic_ad;//话题
@property (nonatomic,copy,nullable) NSString *upper_ad;//上升
@property (nonatomic,copy,nullable) NSString *index_ad;//书单

//广告显示哪个sdk
@property (nonatomic,copy,nullable) NSString *checkin_adInc;
@property (nonatomic,copy,nullable) NSString *favorite_adInc;
@property (nonatomic,copy,nullable) NSString *read_adInc;
@property (nonatomic,copy,nullable) NSString *splash_adInc;
@property (nonatomic,copy,nullable) NSString *square_adInc;
@property (nonatomic,copy,nullable) NSString *active_adInc;
@property (nonatomic,copy,nullable) NSString *brand_adInc;
@property (nonatomic,copy,nullable) NSString *download_adInc;
@property (nonatomic,copy,nullable) NSString *topic_adInc;
@property (nonatomic,copy,nullable) NSString *upper_adInc;
@property (nonatomic,copy,nullable) NSString *index_adInc;


//广告跳转URL
@property (nonatomic,copy,nullable) NSString *checkin_adURL;
@property (nonatomic,copy,nullable) NSString *favorite_adURL;
@property (nonatomic,copy,nullable) NSString *read_adURL;
@property (nonatomic,copy,nullable) NSString *splash_adURL;
@property (nonatomic,copy,nullable) NSString *square_adURL;
@property (nonatomic,copy,nullable) NSString *active_adURL;
@property (nonatomic,copy,nullable) NSString *brand_adURL;
@property (nonatomic,copy,nullable) NSString *download_adURL;
@property (nonatomic,copy,nullable) NSString *topic_adURL;
@property (nonatomic,copy,nullable) NSString *upper_adURL;
@property (nonatomic,copy,nullable) NSString *index_adURL;




- (void)config;
- (void)getUnread;

//存储到keychain中
- (void)save;
- (void)clear;
- (void)globalDicSave;
- (BOOL)isLogin;

- (BOOL)isAllowdNotification;

@end
