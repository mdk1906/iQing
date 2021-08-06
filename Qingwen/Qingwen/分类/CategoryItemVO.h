//
//  CategoryItemVO.h
//  Qingwen
//
//  Created by Aimy on 7/4/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWValueObject.h"

@protocol CategoryItemVO <NSObject>

@end

@interface CategoryItemVO : QWValueObject

@property (nonatomic, copy) NSNumber *nid;
@property (nonatomic, copy) NSString *book_url;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *order;
@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSNumber *submit;//投稿可以选的分类

- (void)toList;

@end
