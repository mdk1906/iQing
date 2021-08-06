//
//  QWBlacListManager.m
//  Qingwen
//
//  Created by mumu on 2017/9/30.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWBlacListManager.h"

@interface QWBlacListManager()

@property (nonatomic, strong) NSArray *blackKeys;
@property (nonatomic, strong) NSArray <UserVO> *blackValues;
@property (nonatomic, strong) NSLock *lock;

@property (nonatomic, strong) NSMutableDictionary *blackListDic;
@end

@implementation QWBlacListManager

DEF_SINGLETON(QWBlacListManager)

- (void)getBlackList {
    NSMutableDictionary *blackMutDic = [NSMutableDictionary dictionaryWithContentsOfFile:[self getBlackListPath]];
    if (!blackMutDic) {
        blackMutDic = @{}.mutableCopy;
    }
    _blackListDic = blackMutDic;
}

- (NSString *)getBlackListPath {
    return [[QWFileManager qingwenPath] stringByAppendingPathComponent:@"Qingwen-black.plist"];
}

- (NSArray *)blackKeys {
    
    return _blackListDic.allKeys;
}

- (NSArray<UserVO> *)blackValues {
    NSMutableArray<UserVO> *tempUsers = @[].mutableCopy;
    [_blackListDic.allValues enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UserVO *vo = [UserVO voWithJson:obj];
        [tempUsers addObject:vo];
    }];
    return tempUsers;
}

- (void)addToBlackListWithUser:(UserVO * __nonnull)user {
    if ([[_blackListDic allKeys] containsObject:user.nid.stringValue]) {
        return;
    }
    
    _blackListDic[user.nid.stringValue] = user.toJSONString;
    [_blackListDic writeToFile:[self getBlackListPath] atomically:YES];
}

- (void)removeFromBlackListWithUser:(UserVO * __nonnull)user {
    if (![[_blackListDic allKeys] containsObject:user.nid.stringValue]) {
        return;
    }
    
    [_blackListDic removeObjectForKey:user.nid.stringValue];
    [_blackListDic writeToFile:[self getBlackListPath] atomically:YES];
}

- (DiscussVO *)shieldBlackDiscuss:(DiscussVO *)discuss {
    if (!discuss || discuss.results.count == 0) {
        return nil;
    }
    NSMutableArray <DiscussItemVO> *tempResults = [NSMutableArray arrayWithArray:discuss.results].mutableCopy;
    __block int removeCount = 0;
    [discuss.results enumerateObjectsUsingBlock:^(DiscussItemVO* obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self.blackKeys containsObject:obj.user.nid.stringValue]) {
            [tempResults removeObject:obj];
            removeCount += 1;
        }
    }];
    discuss.results = tempResults;
    return discuss;
}

@end
