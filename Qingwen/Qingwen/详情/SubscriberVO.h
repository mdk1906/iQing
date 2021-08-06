//
//  SubscriberVO.h
//  Qingwen
//
//  Created by mumu on 16/10/8.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import "QWValueObject.h"

NS_ASSUME_NONNULL_BEGIN

@protocol  SubscriberVO<NSObject>

@end

@interface SubscriberVO : QWValueObject

@property (nonatomic, copy, nullable) NSNumber *book_id;

@property (nonatomic, copy, nullable) NSNumber *chapter_count;
@property (nonatomic, copy, nullable) NSNumber *amount;
@property (nonatomic, copy, nullable) NSNumber *points;
@property (nonatomic, copy, nullable) NSNumber *can_use_voucher;
@property (nonatomic, copy, nullable) NSNumber *chapter;
@property (nonatomic, copy ,nullable) NSNumber *book;
@property (nonatomic, copy, nullable) NSNumber *amount_coin;
@property (nonatomic, copy, nullable) NSNumber *battle;
@property (nonatomic, copy, nullable) NSNumber *toggle;
@property (nonatomic,copy,nullable) NSString *buy_type;
@property (nonatomic, copy, nullable) NSDate *created_time;
@property (nonatomic, copy, nullable) NSNumber *volume_num;
@end

NS_ASSUME_NONNULL_END
