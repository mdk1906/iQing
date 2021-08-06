//
//  SearchCount.h
//  Qingwen
//
//  Created by mumu on 2017/7/29.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWValueObject.h"

@protocol SearchCount<NSObject>

@end


NS_ASSUME_NONNULL_BEGIN

@interface SearchCount : QWValueObject

@property (nonatomic, copy, nullable) NSNumber *count;
//@property (nonatomic) QWWorkType work_type;
@property (nonatomic, copy, nullable) NSNumber *work_type;
@end

NS_ASSUME_NONNULL_END
