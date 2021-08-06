//
//  CategoryDiscussVO.h
//  Qingwen
//
//  Created by Aimy on 8/28/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWValueObject.h"

@interface CategoryDiscussVO : QWValueObject

@property (nonatomic, copy) NSDate *created_time;
@property (nonatomic, copy) NSString *nid;
@property (nonatomic, copy) NSNumber *locked;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSString *url;

@end
