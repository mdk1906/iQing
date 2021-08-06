//
//  QWBlacListManager.h
//  Qingwen
//
//  Created by mumu on 2017/9/30.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QWBlacListManager : NSObject

+ (QWBlacListManager * __nonnull)sharedInstance;

@property (nonatomic, strong, readonly) NSArray * _Nullable blackKeys;
@property (nonatomic, strong, readonly) NSArray <UserVO> * _Nullable blackValues;

- (void)getBlackList;

- (void)addToBlackListWithUser:(UserVO * __nonnull)user;

- (void)removeFromBlackListWithUser:(UserVO * __nonnull)user;

- (DiscussVO *_Nullable)shieldBlackDiscuss:(DiscussVO *_Nullable)discuss;
@end
