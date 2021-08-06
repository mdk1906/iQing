//
//  UserVO.h
//  Qingwen
//
//  Created by Aimy on 7/18/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWValueObject.h"

@protocol UserVO <NSObject>

@end

@interface UserVO : QWValueObject

@property (nonatomic, copy, nullable) UserVO *user;

@property (nonatomic, copy, nullable) NSString *avatar;
@property (nonatomic, copy, nullable) NSDate *birth_day;
@property (nonatomic, copy, nullable) NSNumber *sex;//男1，女2，其他0
@property (nonatomic, copy, nullable) NSString *signature;
@property (nonatomic, copy, nullable) NSString *username;
@property (nonatomic, copy, nullable) NSNumber *nid;

@property (nonatomic, copy, nullable) NSNumber *count;//粉丝
@property (nonatomic, copy, nullable) NSNumber *fans_count;//多少人关注了TA
@property (nonatomic, copy, nullable) NSNumber *follow_count;//TA的关注
@property (nonatomic, copy, nullable) NSNumber *work_count;//投稿
@property (nonatomic, copy, nullable) NSNumber *comments;//评论
@property (nonatomic, copy, nullable) NSString *profile_url;//box

@property (nonatomic, copy, nullable) NSString *book_sync_url;
@property (nonatomic, copy, nullable) NSString *feed_url;

@property (nonatomic, copy, nullable) NSString *bookshelf_url;
@property (nonatomic, copy, nullable) NSString *gameshelf_url;


@property (nonatomic, copy, nullable) NSString *friend_url;
@property (nonatomic, copy, nullable) NSString *fan_url;

@property (nonatomic, copy, nullable) NSString *relationship_url;

@property (nonatomic, copy, nullable) NSString *follow_url;
@property (nonatomic, copy, nullable) NSString *unfollow_url;

@property (nonatomic, copy, nullable) NSString *work_url;

@property (nonatomic, copy, nullable) NSNumber *currency;
@property (nonatomic, copy, nullable) NSNumber *coin;
@property (nonatomic, copy, nullable) NSNumber *gold;
@property (nonatomic, copy, nullable) NSNumber *check_in_count;
@property (nonatomic, copy, nullable) NSDate *check_in_date;
@property (nonatomic, copy, nullable) NSString *check_in_url;


//3.2.0 新增字段
@property (nonatomic, copy, nullable) NSDate *created_time;
@property (nonatomic, copy, nullable) NSNumber *award;
@property (nonatomic, copy, nullable) NSNumber *tips;
@property (nonatomic, copy, nullable) NSNumber *purchase;
@property (nonatomic, copy, nullable) NSNumber *points;

//3.5.0 新增字段
@property (nonatomic, copy, nullable) NSNumber *check_in_u_count;

@property (nonatomic , copy , nullable)NSString *tasks;//任务完成数量
@property (nonatomic , copy , nullable)NSString *medals;//勋章数量
@property (nonatomic , copy , nullable)NSString *adorn_medal;//勋章图片urlarchieve
@property (nonatomic , copy , nullable)NSString *archieve;//成就数量
@property (nonatomic , copy , nullable)NSString *vip_date;//vip还剩天数
@property (nonatomic , copy , nullable)NSNumber *vip;//
@property (nonatomic, copy, nullable) NSString *level;
@property (nonatomic , copy , nullable)NSNumber *level_exp;//所需经验
@property (nonatomic , copy , nullable)NSNumber *exp;//当前经验
@end
