//
//  WalletBillVO.h
//  Qingwen
//
//  Created by Aimy on 2/28/16.
//  Copyright © 2016 iQing. All rights reserved.
//

#import "QWValueObject.h"

@protocol WalletBillVO <NSObject>

@end

@interface WalletBillVO : QWValueObject

@property (nonatomic, copy, nullable) NSNumber *nid;
@property (nonatomic, copy, nullable) NSNumber *user;
@property (nonatomic, copy, nullable) NSString *reason;
@property (nonatomic, copy, nullable) NSString *money;
@property (nonatomic, copy, nullable) NSDate *created_time;
@property (nonatomic, copy, nullable) NSDate *updated_time;

@end
