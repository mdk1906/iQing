//
//  NewMessageListVO.h
//  Qingwen
//
//  Created by mumu on 17/3/3.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "PageVO.h"
#import "NewMessageVO.h"
@class UserVO;

NS_ASSUME_NONNULL_BEGIN

@interface NewMessageListVO : PageVO

@property (nonatomic, copy, nullable) NSNumber *code;
@property (nonatomic, copy, nullable) NSNumber *all_count;
@property (nonatomic, copy, nullable) UserVO *other;
@property (nonatomic, copy, nullable) UserVO *me;
@property (nonatomic, copy, nullable) NSArray <NewMessageVO> *message_list;

@property (nonatomic, assign) NSInteger end;  //为了方便消息自己滚动到最后一个

- (instancetype)addResultsWithNewPage:(NewMessageListVO *)page;

@end

NS_ASSUME_NONNULL_END
