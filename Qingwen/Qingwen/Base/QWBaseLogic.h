//
//  QWBaseLogic.h
//  Qingwen
//
//  Created by Aimy on 7/3/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

#define READING_CONTENT_PAGE_SIZE 99999//阅读加载content内容, 为了取到本章节所有的内容

#import "QWOperationManager.h"


typedef NS_ENUM(NSUInteger, QWChannelType) {
    QWChannelTypeNone = 0,//不区分
    QWChannelType10 = 10,//少年  3.0修改成原创
    QWChannelType11 = 11,//少女  3.0修改成女性向
    QWChannelType12 = 12,//同人  3.0修改同人
    QWChannelType13 = 13,//日轻
    QWChannelType14 = 14,//文库本
    QWChannelType99 = 100,//演绘
};

typedef NS_ENUM(NSUInteger, QWCategroyType) {
    QWCategroyTypeNew = 0, //新书
    QWCategroyTypeAll = 1, //全部
};

typedef NS_ENUM(NSUInteger, QWPeriodType) {
    QWPeriodTypeDay = 0, //日
    QWPeriodTypeWeek = 1, //周
    QWPeriodTypeMonth = 2, //月
};

typedef NS_ENUM(NSUInteger, QWReadingType) {
    QWReadingTypeOther = 0, //未知
    QWReadingTypeBook = 1, //书
    QWReadingTypeGame = 2, //演绘
    QWReadingTypeFavorite = 6, //演绘
};

typedef NS_ENUM(NSUInteger, QWWorkType) {
    QWWorkTypeBook = 1,//书
    QWWorkTypeGame = 2,//演绘
    QWWorkTypeActivity = 3, //活动
    QWWorkTypeTopic = 4, //专题
    QWWrokTypeUser = 5 //用户
};

NS_ASSUME_NONNULL_BEGIN

typedef void(^QWCompletionBlock)(_Nullable id aResponseObject, NSError* _Nullable anError);
typedef void(^QWDataBlock)(_Nullable id aResponseObject);

@interface QWBaseLogic : NSObject

//@property (nonatomic, strong, readonly) QWOperationManager *operationManager;
@property (nonatomic, getter=isLoading) BOOL loading;

+ (instancetype)logicWithOperationManager:(QWOperationManager *)aOperationManger;

- (void)getWithUrl:(NSString * _Nullable)aUrl useOrigin:(BOOL)useOrigin andCompleteBlock:(_Nullable QWCompletionBlock)aBlock;
- (void)handleResponseObjectV4:(id)aResponseObject dataBlock:(QWDataBlock)block;
- (void)getAchievementInfoWithCompleteBlock:(QWCompletionBlock _Nullable)aBlock;
@end

NS_ASSUME_NONNULL_END
