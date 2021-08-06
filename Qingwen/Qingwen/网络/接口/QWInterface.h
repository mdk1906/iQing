//
//  QWInterface.h
//  Qingwen
//
//  Created by Aimy on 7/3/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QWOperationParam.h"

@interface QWInterface : NSObject

/**
 *  获取用户信息
 */
+ (QWOperationParam *)getUserInfoWithParam:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)block;
+ (QWOperationParam *)getUserInfoWithParam:(NSDictionary *)params userId:(NSString *)userId method:(NSString *)method andCompleteBlock:(QWCompletionBlock)block;
/**
 *  更新头像
 */
+ (QWOperationParam *)updateAvatarWithParam:(NSDictionary *)params image:(UIImage *)image andCompleteBlock:(QWCompletionBlock)block;
+ (QWOperationParam *)uploadImageWithParam:(NSDictionary *)params image:(UIImage *)image andCompleteBlock:(QWCompletionBlock)block;

/**
 *  更新用户信息
 */
+ (QWOperationParam *)updateUserInfoWithParam:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)block;

/**
 *  发送登录
 */
+ (QWOperationParam *)loginWithParam:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)block;
/**
 *  发送注册
 */
+ (QWOperationParam *)registWithParam:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)block;
/**
 *  重置密码
 */
+ (QWOperationParam *)resetPasswordWithParam:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)block;
/**
 *  发送短信
 */
+ (QWOperationParam *)sendVerificationCodeWithParam:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)block;

/**
 * 功能点：搜索
 */
+(QWOperationParam *)searchWithParam:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)aBlock;

/**
 * 功能点：获取书
 */
+(QWOperationParam *)getBookWithParams:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)aBlock;

/**
 * 功能点：获取分类
 */
+(QWOperationParam *)getCategoryWithParams:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)aBlock;

/**
 * 功能点：获取分类讨论区
 */
+(QWOperationParam *)getCategoryDiscussWithParams:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)aBlock;

/**
 * 功能点：获取推荐列表
 */
+(QWOperationParam *)getRecommendWithParams:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)aBlock;
+(QWOperationParam *)getGuessWithParams:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)aBlock;
+(QWOperationParam *)getRankListWithType:(NSInteger)type params:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)aBlock;
+(QWOperationParam *)getNewRankListWithParams:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)aBlock;

/**
 * 功能点：获取书的卷信息
 */
+(QWOperationParam *)getVolumeWithCompleteBlock:(QWCompletionBlock)aBlock;

/**
 * 功能点：获取书的章节信息
 */
+(QWOperationParam *)getChapterWithCompleteBlock:(QWCompletionBlock)aBlock;

/**
 * 功能点：获取书的正文信息
 */
+(QWOperationParam *)getContentWithCompleteBlock:(QWCompletionBlock)aBlock;

/**
 * 功能点：GET
 */
+(QWOperationParam *)getWithUrl:(NSString *)aUrl andCompleteBlock:(QWCompletionBlock)aBlock;

/**
 * 功能点：GET
 */
+(QWOperationParam *)getWithUrl:(NSString *)aUrl params:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)aBlock;
+(QWOperationParam *)getWithDomainUrl:(NSString *)aUrl params:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)aBlock;

+(QWOperationParam *)postWithDomainUrl:(NSString *)aUrl params:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)aBlock;
+(QWOperationParam *)postWithUrl:(NSString *)aUrl params:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)aBlock;
@end
