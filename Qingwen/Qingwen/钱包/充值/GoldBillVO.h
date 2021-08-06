//
//  GoldBillVO.h
//  Qingwen
//
//  Created by Aimy on 3/21/16.
//  Copyright © 2016 iQing. All rights reserved.
//

#import "QWValueObject.h"

@protocol GoldBillVO <NSObject>

@end

@interface GoldBillVO : QWValueObject

@property (nonatomic, strong, nullable) NSDate *updated_time;
@property (nonatomic, strong, nullable) NSString *reason;
@property (nonatomic, strong, nullable) NSNumber *gold;

@end
