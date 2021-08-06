//
//  PropsVO.h
//  Qingwen
//
//  Created by mumu on 16/10/27.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import "QWValueObject.h"
NS_ASSUME_NONNULL_BEGIN

@interface PropsVO : QWValueObject

@property (nonatomic, copy, nullable) NSNumber *count;
@property (nonatomic, strong, nullable) GoodsVO *commodity;
@end

NS_ASSUME_NONNULL_END
