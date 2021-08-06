//
//  QWInterface.m
//  Qingwen
//
//  Created by Aimy on 7/3/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWInterface.h"

@implementation QWInterface

/**
 *  获取用户信息
 */
+ (QWOperationParam *)getUserInfoWithParam:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)block
{
    QWOperationParam *operationParam = [QWOperationParam paramWithMethodName:@"profile/" type:QWRequestTypePost param:params callback:block];
    return operationParam;
}

/**
 *  获取用户信息
 */
+ (QWOperationParam *)getUserInfoWithParam:(NSDictionary *)params userId:(NSString *)userId method:(NSString *)method andCompleteBlock:(QWCompletionBlock)block
{
    QWOperationParam *operationParam = [QWOperationParam paramWithMethodName:[NSString stringWithFormat:@"user/%@/%@/", userId, method] type:QWRequestTypePost param:params callback:block];
    return operationParam;
}

/**
 *  更新用户信息
 */
+ (QWOperationParam *)updateUserInfoWithParam:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)block
{
    QWOperationParam *operationParam = [QWOperationParam paramWithMethodName:@"update_profile/" type:QWRequestTypePost param:params callback:block];
    return operationParam;
}

/**
 *  更新头像
 */
+ (QWOperationParam *)updateAvatarWithParam:(NSDictionary *)params image:(UIImage *)image andCompleteBlock:(QWCompletionBlock)block
{
    QWOperationParam *operationParam = [QWOperationParam paramWithMethodName:@"avatar/" type:QWRequestTypePost param:params callback:block];
    operationParam.uploadImage = image;
    operationParam.compressimage = YES;
    operationParam.requestType = QWRequestTypePost;
    operationParam.timeoutTime = 30.f;
    operationParam.paramsUseForm = YES;
    return operationParam;
}

+ (QWOperationParam *)uploadImageWithParam:(NSDictionary *)params image:(UIImage *)image andCompleteBlock:(QWCompletionBlock)block
{
    QWOperationParam *operationParam = [QWOperationParam paramWithMethodName:@"tunnel/" type:QWRequestTypePost param:params callback:block];
    operationParam.uploadImage = image;
    operationParam.requestType = QWRequestTypePost;
    operationParam.timeoutTime = 30.f;
    operationParam.paramsUseForm = YES;
    operationParam.uploadBookImage = YES;
    return operationParam;
}

/**
 *  发送登录
 */
+ (QWOperationParam *)loginWithParam:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)block
{
    QWOperationParam *operationParam = [QWOperationParam paramWithMethodName:@"login/" type:QWRequestTypePost param:params callback:block];
    return operationParam;
}

/**
 *  发送注册
 */
+ (QWOperationParam *)registWithParam:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)block
{
    QWOperationParam *operationParam = [QWOperationParam paramWithMethodName:@"register/" type:QWRequestTypePost param:params callback:block];
    return operationParam;
}

/**
 *  重置密码
 */
+ (QWOperationParam *)resetPasswordWithParam:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)block
{
    QWOperationParam *operationParam = [QWOperationParam paramWithMethodName:@"reset_password/" type:QWRequestTypePost param:params callback:block];
    return operationParam;
}

/**
 *  发送短信
 */
+ (QWOperationParam *)sendVerificationCodeWithParam:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)block
{
    QWOperationParam *operationParam = [QWOperationParam paramWithMethodName:@"sms/" type:QWRequestTypePost param:params callback:block];
    return operationParam;
}

/**
 * 旧客户端功能点：搜索
 */
+(QWOperationParam *)searchWithParam:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)aBlock
{
    QWOperationParam *operationParam = [QWOperationParam paramWithMethodName:@"book/search/" type:QWRequestTypeGet param:params callback:aBlock];
    return operationParam;
}

/**
 * 功能点：获取书
 */
+(QWOperationParam *)getBookWithParams:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)aBlock
{
    QWOperationParam *operationParam = [QWOperationParam paramWithMethodName:@"book/" type:QWRequestTypeGet param:params callback:aBlock];
    return operationParam;
}

/**
 * 功能点：获取分类
 */
+(QWOperationParam *)getCategoryWithParams:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)aBlock
{
    QWOperationParam *operationParam = [QWOperationParam paramWithMethodName:@"category/" type:QWRequestTypeGet param:params callback:aBlock];
    return operationParam;
}

/**
 * 功能点：获取分类讨论区
 */
+(QWOperationParam *)getCategoryDiscussWithParams:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)aBlock
{
    QWOperationParam *operationParam = [QWOperationParam paramWithMethodName:@"brand/" type:QWRequestTypeGet param:params callback:aBlock];
    return operationParam;
}

/**
 * 功能点：获取推荐列表
 */
+(QWOperationParam *)getRecommendWithParams:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)aBlock;
{
    QWOperationParam *operationParam = [QWOperationParam paramWithMethodName:@"recommend/" type:QWRequestTypeGet param:params callback:aBlock];
    return operationParam;
}

+(QWOperationParam *)getGuessWithParams:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)aBlock
{
    QWOperationParam *operationParam = [QWOperationParam paramWithMethodName:@"book/random/" type:QWRequestTypeGet param:params callback:aBlock];
    return operationParam;
}

+(QWOperationParam *)getRankListWithType:(NSInteger)type params:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)aBlock
{
    if (type == 0) {
        QWOperationParam *operationParam = [QWOperationParam paramWithMethodName:@"book/day_rank/" type:QWRequestTypeGet param:params callback:aBlock];
        return operationParam;
    }
    else {
        QWOperationParam *operationParam = [QWOperationParam paramWithMethodName:@"book/week_rank/" type:QWRequestTypeGet param:params callback:aBlock];
        return operationParam;
    }
}

+(QWOperationParam *)getNewRankListWithParams:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)aBlock
{
    QWOperationParam *operationParam = [QWOperationParam paramWithMethodName:@"statistic/book/new_book_rank/" type:QWRequestTypeGet param:params callback:aBlock];
    return operationParam;
}

/**
 * 功能点：获取书的卷信息
 */
+(QWOperationParam *)getVolumeWithCompleteBlock:(QWCompletionBlock)aBlock
{
    NSMutableDictionary *paramDict = @{}.mutableCopy;

    QWOperationParam *operationParam = [QWOperationParam paramWithMethodName:@"volume/" type:QWRequestTypeGet param:paramDict callback:aBlock];
    return operationParam;
}

/**
 * 功能点：获取书的章节信息
 */
+(QWOperationParam *)getChapterWithCompleteBlock:(QWCompletionBlock)aBlock
{
    NSMutableDictionary *paramDict = @{}.mutableCopy;

    QWOperationParam *operationParam = [QWOperationParam paramWithMethodName:@"chapter/" type:QWRequestTypeGet param:paramDict callback:aBlock];
    return operationParam;
}

/**
 * 功能点：获取书的正文信息
 */
+(QWOperationParam *)getContentWithCompleteBlock:(QWCompletionBlock)aBlock
{
    NSMutableDictionary *paramDict = @{}.mutableCopy;

    QWOperationParam *operationParam = [QWOperationParam paramWithMethodName:@"content/" type:QWRequestTypeGet param:paramDict callback:aBlock];
    return operationParam;
}

/**
 * 功能点：GET
 */
+(QWOperationParam *)getWithUrl:(NSString *)aUrl andCompleteBlock:(QWCompletionBlock)aBlock
{
    NSMutableDictionary *paramDict = @{}.mutableCopy;
    return [self getWithUrl:aUrl params:paramDict andCompleteBlock:aBlock];
}

/**
 * 功能点：GET
 */
+(QWOperationParam *)getWithUrl:(NSString *)aUrl params:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)aBlock
{
    QWOperationParam *operationParam = [QWOperationParam paramWithUrl:aUrl type:QWRequestTypeGet param:params callback:aBlock];
    return operationParam;
}

+(QWOperationParam *)getWithDomainUrl:(NSString *)aUrl params:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)aBlock
{
    QWOperationParam *operationParam = [QWOperationParam paramWithMethodName:aUrl type:QWRequestTypeGet param:params callback:aBlock];
    return operationParam;
}

+(QWOperationParam *)postWithDomainUrl:(NSString *)aUrl params:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)aBlock
{
    QWOperationParam *operationParam = [QWOperationParam paramWithMethodName:aUrl type:QWRequestTypePost param:params callback:aBlock];
    return operationParam;
}

+(QWOperationParam *)postWithUrl:(NSString *)aUrl params:(NSDictionary *)params andCompleteBlock:(QWCompletionBlock)aBlock
{
    QWOperationParam *operationParam = [QWOperationParam paramWithUrl:aUrl type:QWRequestTypePost param:params callback:aBlock];
    return operationParam;
}
@end
