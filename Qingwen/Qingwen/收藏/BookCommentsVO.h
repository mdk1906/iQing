//
//  BookCommentsVO.h
//  Qingwen
//
//  Created by wei lu on 5/01/18.
//  Copyright © 2018 iQing. All rights reserved.
//
#import "QWValueObject.h"
#import "UserVO.h"
@protocol BookCommentsVO <NSObject>

@end

NS_ASSUME_NONNULL_BEGIN

@interface BookCommentsVO : QWValueObject

@property (nonatomic, copy, nullable) NSNumber * favorite_id;
@property (nonatomic, copy, nullable) NSNumber *nid;
@property (nonatomic, copy, nullable) NSString *favorite_title;
@property (nonatomic, copy, nullable) NSString *recommend;
@property (nonatomic, copy, nullable) UserVO *author;
@property (nonatomic, copy, nullable) NSDate *updated_time;


@end

NS_ASSUME_NONNULL_END
