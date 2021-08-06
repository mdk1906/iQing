//
//  QWAttentionLogic.h
//  Qingwen
//
//  Created by Aimy on 8/24/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBaseLogic.h"
#import "UserVO.h"
#import "FriendListVO.h"

NS_ASSUME_NONNULL_BEGIN

@interface QWAttentionLogic : QWBaseLogic

@property (nonatomic, strong, nullable) FriendListVO *friendListVO;
@property (nonatomic, strong, nullable) FriendListVO *fanListVO;

- (void)getFriendWithUrl:(NSString * _Nullable)aUrl andCompleteBlock:(QWCompletionBlock _Nullable)aBlock;
- (void)unfollowFriendWithUrl:(NSString * _Nullable)aUrl andCompleteBlock:(QWCompletionBlock _Nullable)aBlock;
- (void)followFriendWithUrl:(NSString * _Nullable)aUrl andCompleteBlock:(QWCompletionBlock _Nullable)aBlock;

@end


NS_ASSUME_NONNULL_END