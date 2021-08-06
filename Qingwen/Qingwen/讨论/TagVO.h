//
//  TagVO.h
//  Qingwen
//
//  Created by Aimy on 1/11/16.
//  Copyright © 2016 iQing. All rights reserved.
//

#import "QWValueObject.h"

@protocol TagVO <NSObject>

@end

@interface TagVO : QWValueObject

@property (nonatomic, copy, nullable) NSString *nid;
@property (nonatomic, copy, nullable) NSNumber *type;//0-title,1-image
@property (nonatomic, copy, nullable) NSString *value;
@property (nonatomic) BOOL local;

@end
