//
//  QWMymedelVO.h
//  Qingwen
//
//  Created by qingwen on 2018/9/6.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QWMymedelVO.h"
#import "UserVO.h"
@protocol QWMymedelVO <NSObject>

@end

NS_ASSUME_NONNULL_BEGIN

@interface QWMymedelVO : QWValueObject

//@property (nonatomic, copy, nullable) NSString *medal_icon;
//@property (nonatomic, copy, nullable) NSString *medal_instruction;
//@property (nonatomic, copy, nullable) NSString *medal_name;
//@property (nonatomic, copy, nullable) NSString *updated_time;
//@property (nonatomic, copy, nullable) NSNumber *created_time;
//@property (nonatomic, copy, nullable) NSNumber *id;
@property (nonatomic, copy, nullable) NSArray *dataArr;
@property (nonatomic, copy, nullable) NSNumber *obtain;// 1 = 获取 2 = 未获取
@property (nonatomic, copy, nullable )NSString *waerMedalId;
@property (nonatomic, copy, nullable )NSString *avatar;
@end

NS_ASSUME_NONNULL_END
