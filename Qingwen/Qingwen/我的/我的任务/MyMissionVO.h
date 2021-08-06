//
//  MyMissionVO.h
//  Qingwen
//
//  Created by qingwen on 2018/9/5.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyMissionVO.h"
#import "UserVO.h"
@protocol MyMissionVO <NSObject>

@end

NS_ASSUME_NONNULL_BEGIN

@interface MyMissionVO : QWValueObject

@property (nonatomic, copy, nullable) NSString *task_name;
@property (nonatomic, copy, nullable) NSString *task_instruction;
@property (nonatomic, copy, nullable) NSString *task_vip_instruction;
@property (nonatomic, copy, nullable) NSString *limit_time;
@property (nonatomic, copy, nullable) NSNumber *status;
@property (nonatomic, copy, nullable) NSNumber *done;
@property (nonatomic, copy, nullable) NSNumber *all;
@end

NS_ASSUME_NONNULL_END
