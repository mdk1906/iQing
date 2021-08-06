//
//  TalkVO.h
//  Qingwen
//
//  Created by mumu on 17/3/6.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWValueObject.h"
@class NewMessageVO;
@class UserVO;

NS_ASSUME_NONNULL_BEGIN

@protocol TalkVO <NSObject>

@end

@interface TalkVO : QWValueObject
@property (nonatomic, copy, nullable) NSNumber *talk_id;
@property (nonatomic, copy, nullable) NSNumber *unread_num;

@property (nonatomic, copy, nullable) UserVO *other;
@property (nonatomic, copy, nullable) NewMessageVO *last_message;

@end

NS_ASSUME_NONNULL_END
