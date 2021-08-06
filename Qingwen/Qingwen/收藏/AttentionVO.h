//
//  AttentionVO.h
//  Qingwen
//
//  Created by mumu on 17/4/1.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWValueObject.h"

@protocol AttentionVO <NSObject>

@end

NS_ASSUME_NONNULL_BEGIN

@interface AttentionVO : QWValueObject

@property (nonatomic, copy, nullable) NSDate * created_time;
@property (nonatomic, copy, nullable) NSNumber *nid;
@property (nonatomic, assign) QWReadingType work_type;
@property (nonatomic, copy, nullable) NSNumber *work_id;

@property (nonatomic, copy, nullable) BookVO *work;
//@property (nonatomic, copy, nullable) BookVO *game;

@end

NS_ASSUME_NONNULL_END
