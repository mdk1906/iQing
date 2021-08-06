//
//  GoodsVO.h
//  Qingwen
//
//  Created by mumu on 16/10/26.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import "QWValueObject.h"

NS_ASSUME_NONNULL_BEGIN

@protocol GoodsVO <NSObject>

@end

@interface GoodsVO : QWValueObject

@property (nonatomic, copy, nullable) NSNumber *nid;
@property (nonatomic, copy, nullable) NSNumber *price; //价格
@property (nonatomic, copy, nullable) NSString *price_type; //价格单位："轻石"
@property (nonatomic, copy, nullable) NSDate * created_time;
@property (nonatomic, copy, nullable) NSDate * updated_time;
@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, copy, nullable) NSString *descriptions; //使用说明
@property (nonatomic, copy, nullable) NSString *icon;
@property (nonatomic, copy, nullable) NSNumber *period;       //有效天数
@property (nonatomic, copy, nullable) NSNumber *is_online;    //是否在线
@property (nonatomic, copy, nullable) NSString *my_hold_url; //跳转URL

@end
NS_ASSUME_NONNULL_END
