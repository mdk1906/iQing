//
//  QWSearchLogic.h
//  Qingwen
//
//  Created by Aimy on 7/30/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBaseLogic.h"

#import "SearchVO.h"
#import "SuggestVO.h"
#import "SearchCount.h"

NS_ASSUME_NONNULL_BEGIN

@interface QWSearchLogic : QWBaseLogic

//搜书
@property (nonatomic, strong, nullable) NSNumber *locate; //10 原创少年 11 女性向少女 12同人
@property (nonatomic, strong, nullable) NSNumber *categories; // 分类
@property (nonatomic, strong, nullable) NSNumber *category_id; //专为日轻准备  日轻=12
@property (nonatomic, strong, nullable) NSNumber *rank; //3:白银 4:黄金 5:签约
@property (nonatomic, strong, nullable) NSNumber *end; //3:白银 4:黄金 5:签约
/*
 order :书籍可选 0:更新时间 1:战力 2:信仰 3: 收藏 4:讨论区评论数 5:字数
 演绘可选 0:更新时间 1:战力 2:信仰 3:收藏 4:评论
 活动可选 0:创建时间 1:评论数 2:作品数
 专题可选 0:创建时间 1:评论数 2:作品数
 */
@property (nonatomic, strong, nullable) NSNumber *order;

@property (nonatomic, strong, nullable) ListVO *searchBookVO;
@property (nonatomic, strong, nullable) ListVO *searchGameVO;
@property (nonatomic, strong, nullable) ActivityListVO *searchActivityListVO;
@property (nonatomic, strong, nullable) UserPageVO *searchUserListVO;
@property (nonatomic, strong, nullable) FavoriteBooksListVO *searchFavorite;

@property (nonatomic, strong, nullable) CategoryVO *categoryVO;//查询到的分类
@property (nonatomic, copy, nullable) NSArray <NSString *> *categoryStrings; // 查询到的分类数组

@property (nonatomic, copy, nullable) NSString *keywords;
@property (nonatomic, copy, nullable) NSArray <SuggestVO> *suggests;

@property (nonatomic, copy, nullable) NSArray <SearchCount> *searchCounts;

- (void)getCountsWithKeywords:(NSString *_Nullable)keywords andCompleteBlock:(QWCompletionBlock _Nullable)aBlock;

- (void)getSuggestWithKeywords:(NSString *_Nullable)keywords andCompleteBlock:(QWCompletionBlock _Nullable)aBlock;

- (void)getCategoryWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock;
//搜书
- (void)searchBookWithKeywords:(NSString *_Nullable)keywords andCompleteBlock:(QWCompletionBlock _Nullable)aBlock;
//搜演绘
- (void)searchGameWithKeywords:(NSString *_Nullable)keywords andCompleteBlock:(QWCompletionBlock _Nullable)aBlock;
//搜活动/专题
- (void)searchActivityWithKeywords:(NSString *_Nullable)keywords topic:(BOOL)topic andCompleteBlock:(QWCompletionBlock _Nullable)aBlock;

//搜用户
- (void)searchUserWithKeywords:(NSString * _Nullable)keywords andCompleteBlock:(QWCompletionBlock _Nullable)aBlock;

- (void)searchFavoriteWithKeywords:(NSString * _Nullable)keywords andCompleteBlock:(QWCompletionBlock _Nullable)aBlock;

- (BOOL)isShow;
@end
NS_ASSUME_NONNULL_END
