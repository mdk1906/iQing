//
//  UserPageVO.h
//  Qingwen
//
//  Created by Aimy on 11/13/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "PageVO.h"

@interface UserPageVO : PageVO

@property (nonatomic, copy) NSArray<UserVO> *results;

@end
