//
//  subscriberList.h
//  Qingwen
//
//  Created by mumu on 16/10/8.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import "PageVO.h"
#import "SubscriberVO.h"
@interface SubscriberList : PageVO

@property (nonatomic, copy) NSArray<SubscriberVO> *results;

@end
