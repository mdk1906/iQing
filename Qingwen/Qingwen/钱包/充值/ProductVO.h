//
//  ProductVO.h
//  Qingwen
//
//  Created by Aimy on 3/17/16.
//  Copyright © 2016 iQing. All rights reserved.
//

#import "QWValueObject.h"

@protocol ProductVO <NSObject>

@end

@interface ProductVO : QWValueObject

@property (nonatomic, strong, nullable) NSNumber *nid;
@property (nonatomic, strong, nullable) NSNumber *currency;//价格
@property (nonatomic, strong, nullable) NSNumber *gold;//重石
@property (nonatomic, strong, nullable) NSNumber *platform;//平台
@property (nonatomic, strong, nullable) NSString *name;
@property (nonatomic, strong, nullable) NSString *bonus;//轻石
@property (nonatomic, strong, nullable) NSString *vip_bonus;//VIP加送轻石
@end
