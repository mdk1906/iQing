//
//  QWDiscussLogic.h
//  Qingwen
//
//  Created by Aimy on 8/11/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBaseLogic.h"

#import "DiscussVO.h"

@interface QWDiscussLogic : QWBaseLogic

@property (nonatomic, copy, nullable) NSNumber *discussLastCount;
@property (nonatomic, strong, nullable) DiscussVO *bestDiscussVO;//精华
@property (nonatomic, strong, nullable) DiscussVO *topDiscussVO;//置顶
@property (nonatomic, strong, nullable) DiscussVO *discussVO;//帖子
@property (nonatomic, strong, nullable) DiscussVO *commentVO;//回复
@property (nonatomic, strong, nullable) NSNumber *own;


/**
 获取到板块内容
 */
- (void)getBrandWithUrl:(NSString * __nonnull)aUrl andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
- (void)getBestDiscussWithUrl:(NSString * __nonnull)aUrl andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
- (void)getDiscussLastCountWithUrl:(NSString * __nonnull)url andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
- (void)getDiscussWithUrl:(NSString * __nonnull)aUrl andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
- (void)getDiscussDetailWithUrl:(NSString * __nonnull)aDiscussUrl andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
- (void)getTopDiscussWithUrl:(NSString * __nonnull)aUrl andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
- (void)getCommentWithUrl:(NSString * __nonnull)aUrl lonely:(BOOL)lonely andCompleteBlock:(__nullable QWCompletionBlock)aBlock;

- (void)createDiscussWithUrl:(NSString * __nonnull)aUrl content:(NSString * __nonnull)content paths:(NSArray * __nullable)paths andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
- (void)createCommentWithUrl:(NSString * __nullable)aUrl content:(NSString * __nullable)content refer:(NSNumber * __nullable)order paths:(NSArray * __nullable)paths andCompleteBlock:(__nullable QWCompletionBlock)aBlock;

- (BOOL)isPureExpression:(NSString * __nonnull)content;

- (void)getAuthorWithUrl:(NSString * __nonnull)aUrl andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
//0设置,1取消设置
- (void)setTopWithUrl:(NSString * __nonnull)aUrl type:(BOOL)type andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
//0设置,1取消设置
- (void)setDiggestWithUrl:(NSString * __nonnull)aUrl type:(BOOL)type andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
//0帖子,1回复
- (void)submitReportWithId:(NSString * __nonnull)nid type:(BOOL)type content:(NSString * __nullable)content andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
//0帖子,1回复
- (void)deleteDiscussWithId:(NSString * __nonnull)nid type:(BOOL)type andCompleteBlock:(__nullable QWCompletionBlock)aBlock;

- (void)getDiscussDetailWithID:(NSString * __nonnull)nid andCompleteBlock:(__nullable QWCompletionBlock)aBlock;

-(void) getPostCommentsWithID:(NSString * __nonnull)nid andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
@end
