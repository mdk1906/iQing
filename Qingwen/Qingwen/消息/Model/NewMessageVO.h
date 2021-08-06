//
//  NewMessageVO.h
//  Qingwen
//
//  Created by mumu on 17/3/3.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWValueObject.h"
@class UserVO;
@class ExpandVO;

typedef NS_ENUM(NSUInteger, QWMessageType){
    QWMessageText = 0,
    QWMessageImage,
    QWMessageAudio,
    QWMessageVideo,
};

@protocol NewMessageVO <NSObject>

@end

NS_ASSUME_NONNULL_BEGIN

@interface NewMessageVO : QWValueObject

@property (nonatomic, copy, nullable) NSString *message_id;
@property (nonatomic) QWMessageType message_type;
@property (nonatomic, copy, nullable) NSNumber *sender_id;
@property (nonatomic, copy, nullable) NSNumber *reciver_id;
@property (nonatomic, copy, nullable) NSString *content;
@property (nonatomic, copy, nullable) NSDate * created_time;
@property (nonatomic, copy, nullable) ExpandVO *expand;

//客户端字段 判断是否显示时间
@property (nonatomic, assign) BOOL showDateTime;
@end
NS_ASSUME_NONNULL_END
