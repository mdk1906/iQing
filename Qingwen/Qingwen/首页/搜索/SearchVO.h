//
//  SearchVO.h
//  Qingwen
//
//  Created by Aimy on 7/10/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "PageVO.h"

#import "BookVO.h"

typedef NS_ENUM(NSInteger, SearchType) {
    SearchTypeNone = 0,//全字段搜索
    SearchTypeTitle,//书名
    SearchTypeAuthor,//作者
    SearchTypePress,//出版社
};

NS_ASSUME_NONNULL_BEGIN

@interface SearchVO : PageVO

@property (nonatomic, copy, nullable) NSString *keywords;
@property (nonatomic) SearchType type;
@property (nonatomic, copy, nullable) NSArray<BookVO> *results;

@end

NS_ASSUME_NONNULL_END