//
//  QWMyLevelVO.h
//  Qingwen
//
//  Created by qingwen on 2018/10/15.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyMissionVO.h"
#import "UserVO.h"
@protocol QWMyLevelVO <NSObject>

@end

NS_ASSUME_NONNULL_BEGIN

@interface QWMyLevelVO : QWValueObject

@property (nonatomic, copy, nullable) NSString *level_name;
@property (nonatomic, copy, nullable) NSString *level_brief_text;
@property (nonatomic,copy,nullable) NSNumber *level_exp;
@property (nonatomic,copy,nullable) NSNumber *user_exp;
@property (nonatomic,copy,nullable) NSString *user_level;
@property (nonatomic,copy,nullable) NSString *user_next_level;
@end

NS_ASSUME_NONNULL_END
