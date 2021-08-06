//
//  QWGameSubscribeView.h
//  Qingwen
//
//  Created by mumu on 2017/10/16.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QWGameSubscribeView : UIView

- (void)showWithGameId:(NSString *)gameId chapterId:(NSString *)chapterId gold:(NSString *)gold andCompletBlock:(QWSubscriberActionBlock)block;

@end
