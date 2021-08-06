//
//  CommentsVO.h
//  Qingwen
//
//  Created by qingwen on 2018/4/27.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import "CommentsVO.h"
#import "UserVO.h"
@protocol CommentsVO <NSObject>

@end

NS_ASSUME_NONNULL_BEGIN

@interface CommentsVO : QWValueObject

@property (nonatomic, copy, nullable) NSString *bf_url;
@property (nonatomic, copy, nullable) NSNumber *nid;
@property (nonatomic, copy, nullable) NSDate *created_time;
@property (nonatomic, copy, nullable) NSNumber *order;
@property (nonatomic, copy, nullable) NSString *r_avatar;
@property (nonatomic, copy, nullable) NSString *r_content;
@property (nonatomic, copy, nullable) NSString *s_avatar;
@property (nonatomic, copy, nullable) NSString *s_content;
@property (nonatomic, copy, nullable) NSNumber *work_id;
@property (nonatomic, copy, nullable) NSNumber *work_type;
@property (nonatomic, copy, nullable) NSString *work_url;
@property (nonatomic, copy, nullable) NSString *post_url;
@property (nonatomic, copy, nullable) UserVO *r_user;
@property (nonatomic,copy,nullable) UserVO *s_user;

@end

NS_ASSUME_NONNULL_END
