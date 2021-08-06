//
//  QWNewMessageLogic.h
//  Qingwen
//
//  Created by mumu on 17/3/3.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWBaseLogic.h"
#import "NewMessageListVO.h"
#import "TalkVO.h"
#import "TalkListVO.h"

@interface QWNewMessageLogic : QWBaseLogic

@property (nonatomic, strong) NewMessageListVO *messageList;
@property (nonatomic, strong) TalkListVO *talkList;

/**
 * 获取对话列表
 */
- (void)getTalkListWithCompletBlock:(QWCompletionBlock)completeBlock;
/**
 获取单个对话列表
 */
- (void)getSingelMessageListWithTargetId:(NSNumber *)targetId andCompletBlock:(QWCompletionBlock)completBlock;

- (void)getUnreadMessageListWithStart:(NSInteger)startIndex end:(NSInteger)endIndex andTargetId:(NSNumber *)targetId andCompletBlock:(QWCompletionBlock)completBlock;

@end
