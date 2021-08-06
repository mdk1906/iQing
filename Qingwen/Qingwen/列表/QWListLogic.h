//
//  QWListLogic.h
//  Qingwen
//
//  Created by Aimy on 7/4/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBaseLogic.h"

#import "ListVO.h"

typedef NS_ENUM(NSUInteger, QWSortType) {
    QWSortTypeTop = 0,//默认,热度排序
    QWSortTypeTime = 1,//更新
    QWSortTypeDisable = 999,//禁止
};

@interface QWListLogic : QWBaseLogic

@property (nonatomic) QWChannelType channelType;
@property (nonatomic) QWSortType sortType;
@property (nonatomic, strong, nullable) ListVO *listVO;
@property (nonatomic, strong, nullable) NSNumber *period;
@property (nonatomic, strong, nullable) NSNumber *category; //新书 0 全部 1
@property (nonatomic, strong, nullable) NSNumber *type;  // 0 点击榜 1 轻石榜 2 重石榜 3 收藏榜

//榜单
- (void)getWithUrl:(nullable NSString *)aUrl andCompleteBlock:(nullable QWCompletionBlock)aBlock;


/**
 作品库
 */
@property (nonatomic, copy, nullable) NSString *order; //最近更新/最近上升/累计人气/累计收藏:update/gold/views/follow
@property (nonatomic, copy, nullable) NSString *works; //新书/全书: new/all
//获取作品库列表
- (void)getWithUrl1:(nullable NSString *)aUrl1 andCompleteBlock:(nullable QWCompletionBlock)aBlock;

/**
 精品库
 */
@property (nonatomic, copy, nullable) NSNumber *rank; //书籍等级， 黄金/白银/C签:3/4/5
//获取精品列表
- (void)getBoutiqueWithUrl:(nullable NSString *)aUrl andCompleteBlock:(nullable QWCompletionBlock)aBlock;
@end
