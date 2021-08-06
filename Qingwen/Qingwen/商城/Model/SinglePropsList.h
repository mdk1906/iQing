//
//  SinglePropsList.h
//  Qingwen
//
//  Created by mumu on 16/10/27.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import "PageVO.h"
#import "SinglePropsVO.h"

NS_ASSUME_NONNULL_BEGIN
@interface SinglePropsList : PageVO
@property(nonatomic, copy) NSArray <SinglePropsVO> *results;
@end
NS_ASSUME_NONNULL_END
