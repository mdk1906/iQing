//
//  MyWalletVO.h
//  Qingwen
//
//  Created by Aimy on 2/28/16.
//  Copyright © 2016 iQing. All rights reserved.
//

#import "QWValueObject.h"

@interface MyWalletVO : QWValueObject

@property (nonatomic, strong, nullable) NSString *current;
@property (nonatomic, strong, nullable) NSString *total;
@property (nonatomic, strong, nullable) NSNumber *user;
@property (nonatomic, strong, nullable) NSNumber *withdraw_balance;

@end
