//
//  QWMessageLogic.h
//  Qingwen
//
//  Created by Aimy on 8/21/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBaseLogic.h"

#import "UserVO.h"
#import "MessageListVO.h"

@interface QWMessageLogic : QWBaseLogic

@property (nonatomic, strong) MessageListVO *messageListVO;

- (void)getFeedWithUrl:(NSString *)url completeBlock:(QWCompletionBlock)aBlock;

- (void)migrateWithBookIds:(NSArray *)ids andCompleteBlock:(QWCompletionBlock)block;

@end
