//
//  RecommendBooksVO.h
//  Qingwen
//
//  Created by wei lu on 12/12/17.
//  Copyright © 2017 iQing. All rights reserved.
//


#import "QWValueObject.h"

@protocol RecommendBooksVO <NSObject>

@end

NS_ASSUME_NONNULL_BEGIN

@interface RecommendBooksVO : QWValueObject

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSNumber *nid;
@property (nonatomic, copy, nullable) NSString *url;
@property (nonatomic, copy, nullable) NSString *cover;
@property (nonatomic, copy, nullable) NSString *recommend_words;
@property (nonatomic, copy, nullable) FavoriteBooksVO *work;
@end

NS_ASSUME_NONNULL_END
