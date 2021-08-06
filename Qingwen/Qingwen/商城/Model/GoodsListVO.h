//
//  GoodsListVO.h
//  Qingwen
//
//  Created by mumu on 16/10/26.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import "PageVO.h"
NS_ASSUME_NONNULL_BEGIN
@interface GoodsListVO : PageVO
@property(nonatomic, copy) NSArray <GoodsVO> *results;
@end
NS_ASSUME_NONNULL_END
