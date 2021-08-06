//
//  TalkListVO.h
//  Qingwen
//
//  Created by mumu on 17/3/6.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWValueObject.h"
#import "TalkVO.h"
@interface TalkListVO : QWValueObject

@property (nonatomic, copy, nullable) NSNumber *code;
@property (nonatomic, copy, nullable) NSNumber *count;
@property (nonatomic, copy, nullable) NSNumber *all_count;
@property (nonatomic, copy, nullable) NSArray <TalkVO> *talk_list;

@end
