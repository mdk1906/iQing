//
//  FriendList.h
//  Qingwen
//
//  Created by Aimy on 8/24/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "PageVO.h"

#import "FriendItemVO.h"

@interface FriendListVO : PageVO

@property (nonatomic, copy) NSArray<FriendItemVO> *results;

@end
