//
//  DiscussItemVO.h
//  Qingwen
//
//  Created by Aimy on 8/12/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWValueObject.h"

#import "UserVO.h"
#import "TagVO.h"

@protocol DiscussItemVO <NSObject>

@end

@interface DiscussItemVO : QWValueObject

@property (nonatomic, copy, nullable) NSString *nid;
@property (nonatomic, copy, nullable) NSString *brand;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *content;
@property (nonatomic, copy, nullable) NSString *url;

@property (nonatomic, copy, nullable) NSNumber *order;
@property (nonatomic, copy, nullable) NSNumber *refer;

@property (nonatomic, copy, nullable) NSNumber *count;
@property (nonatomic, copy, nullable) NSNumber *locked;
@property (nonatomic, copy, nullable) NSNumber *neta;
@property (nonatomic, copy, nullable) NSNumber *top;
@property (nonatomic, copy, nullable) NSDate *created_time;
@property (nonatomic, copy, nullable) NSDate *updated_time;
@property (nonatomic, strong, nullable) UserVO *user;

@property (nonatomic, strong, nullable) NSArray<TagVO> *tags;

@property (nonatomic, strong, nullable) NSArray<NSString *> *illustration;

@end
