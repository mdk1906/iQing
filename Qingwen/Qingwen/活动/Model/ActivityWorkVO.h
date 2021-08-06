//
//  ActivityWorkVO.h
//  Qingwen
//
//  Created by mumu on 2017/5/2.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWValueObject.h"

@protocol ActivityWorkVO <NSObject>


@end
NS_ASSUME_NONNULL_BEGIN
@interface ActivityWorkVO : QWValueObject<QWBookTVCellCogig>

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *author_name;
@property (nonatomic, copy, nullable) NSNumber *combat;
@property (nonatomic, copy, nullable) NSNumber *belief;
@property (nonatomic, copy, nullable) NSNumber *count;
@property (nonatomic, copy, nullable) NSDate *updated_time;

@property (nonatomic, copy, nullable) NSString *cover;
@property (assign) QWReadingType work_type;
@property (nonatomic, copy, nullable) NSString *url;

@end
NS_ASSUME_NONNULL_END
