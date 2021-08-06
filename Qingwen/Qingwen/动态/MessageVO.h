//
//  MessageVO.h
//  Qingwen
//
//  Created by Aimy on 12/3/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWValueObject.h"

#import "MessageDataVO.h"

@protocol MessageVO <NSObject>

@end

@interface MessageVO : QWValueObject

@property (nonatomic, strong, nullable) UserVO *user;
@property (nonatomic, strong, nullable) MessageDataVO *data;
@property (nonatomic, copy, nullable) NSNumber *type;
@property (nonatomic, copy, nullable) NSString *desc;
@property (nonatomic, copy, nullable) NSString *intent;
@property (nonatomic, copy, nullable) NSDate *created_time;

- (BOOL)isValid;

@end
