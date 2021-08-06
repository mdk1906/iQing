//
//  AuthenticationVO.h
//  Qingwen
//
//  Created by mumu on 2017/8/10.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWValueObject.h"

@protocol AuthenticationVO <NSObject>

@end

NS_ASSUME_NONNULL_BEGIN
@interface AuthenticationVO : QWValueObject

@property (nonatomic, copy, nullable) NSString *wallet_name;
@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, copy, nullable) NSString *id_card;
@property (nonatomic, copy, nullable) NSNumber *binding;
@property (nonatomic, copy, nullable) NSString *wallet_account;
@property (nonatomic, copy, nullable) NSString *channel;
@property (nonatomic, copy, nullable) NSString *real_name;

@end
NS_ASSUME_NONNULL_END
