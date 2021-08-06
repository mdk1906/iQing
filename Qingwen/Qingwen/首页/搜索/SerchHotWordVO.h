//
//  SerchHotWordVO.h
//  Qingwen
//
//  Created by mdk mdk on 2019/8/8.
//  Copyright © 2019 iQing. All rights reserved.
//

#import "PageVO.h"

#import "BookVO.h"

NS_ASSUME_NONNULL_BEGIN

@interface SerchHotWordVO : QWValueObject
@property (nonatomic, copy, nullable) NSString *href;
@property (nonatomic, copy, nullable) NSString *refer_id;
@property (nonatomic,copy,nullable) NSNumber *id;
@property (nonatomic,copy,nullable) NSNumber *order;
@property (nonatomic,copy,nullable) NSString *refer_type;
@property (nonatomic,copy,nullable) NSString *word;
@end

NS_ASSUME_NONNULL_END
