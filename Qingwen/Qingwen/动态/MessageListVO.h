//
//  MessageListVO.h
//  Qingwen
//
//  Created by Aimy on 12/3/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "PageVO.h"

#import "MessageVO.h"

@interface MessageListVO : PageVO

@property (nonatomic, copy) NSArray<MessageVO> *results;

@end
