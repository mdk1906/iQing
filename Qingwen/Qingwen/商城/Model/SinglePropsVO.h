//
//  SinglePropsVO.h
//  Qingwen
//
//  Created by mumu on 16/10/27.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import "QWValueObject.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SinglePropsVO <NSObject>


@end

@interface SinglePropsVO : QWValueObject

@property (nonatomic, copy, nullable) NSNumber *nid;
@property (nonatomic, copy, nullable) NSDate * created_time;
@property (nonatomic, copy, nullable) NSDate * overdue_time;

@property (nonatomic, copy, nullable) NSDate * updated_time;

@property (nonatomic, copy, nullable) NSString *source;
@property (nonatomic, copy, nullable) NSNumber *is_used;

@property (nonatomic, copy, nullable) NSString *remark;

@property (nonatomic, copy, nullable) NSString *category;

@property (nonatomic, strong, nullable) GoodsVO *commodity;

@end
NS_ASSUME_NONNULL_END
