//
//  EntranceVO.h
//  Qingwen
//
//  Created by mumu on 17/2/28.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWValueObject.h"
NS_ASSUME_NONNULL_BEGIN

@protocol EntranceVO <NSObject>

@end

@interface EntranceVO : QWValueObject

@property (nonatomic, copy, nullable) NSNumber *order;

@property (nonatomic, copy, nullable) NSString *cover;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *href;

@end
NS_ASSUME_NONNULL_END
