//
//  PageVO.h
//  Qingwen
//
//  Created by Aimy on 7/4/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWValueObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface PageVO : QWValueObject

@property (nonatomic, copy, nullable) NSNumber *count;
@property (nonatomic, copy, nullable) NSString *next;
@property (nonatomic, copy, nullable) NSString *previous;
@property (nonatomic, copy) NSArray<id> *results;

- (instancetype)addResultsWithNewPage:(PageVO *)page;

@end

NS_ASSUME_NONNULL_END