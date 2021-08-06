//
//  BillVO.h
//  Qingwen
//
//  Created by Aimy on 11/16/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWValueObject.h"

@protocol BillVO <NSObject>

@end

@interface BillVO : QWValueObject

@property (nonatomic, copy, nullable) NSNumber *type;
@property (nonatomic, copy, nullable) NSNumber *status;
@property (nonatomic, copy, nullable) NSNumber *sender;
@property (nonatomic, copy, nullable) NSString *detail;
@property (nonatomic, copy, nullable) NSNumber *receiver;
@property (nonatomic, copy, nullable) NSString *order_id;
@property (nonatomic, copy, nullable) NSNumber *coin;
@property (nonatomic, copy, nullable) NSDate *created_time;
@property (nonatomic, copy, nullable) NSDate *updated_time;

@end
