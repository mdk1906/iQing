//
//  ContentItemVO.h
//  Qingwen
//
//  Created by Aimy on 7/6/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWValueObject.h"

@protocol ContentItemVO <NSObject>

@end

@interface ContentItemVO : QWValueObject

@property (nonatomic, copy) NSNumber *order;
@property (nonatomic, copy) NSNumber *nid;
@property (nonatomic, copy) NSNumber *type;
@property (nonatomic, copy) NSString *value;

@end
