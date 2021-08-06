//
//  QWSubscriberAlertTypeOne.h
//  Qingwen
//
//  Created by mumu on 16/9/30.
//  Copyright © 2016年 mumu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,QWSubscriberActionType) {
    QWSubscriberActionTypeRemove,               //取消
    QWSubscriberActionTypeRecharge,             //充值
    QWSubscriberActionTypeRechargeCenter,       //充值中心
    QWSubscriberActionTypeBuy                   //购买
};

typedef void (^QWSubscriberActionBlock)(QWSubscriberActionType type);

@interface QWSubscriberAlertTypeOne : UIView

+ (instancetype)alertViewWithButtonAction:(QWSubscriberActionBlock)actionBlock;

- (void)updateAlertWithSubscriberVO:(SubscriberVO *)subscriberVO;

- (void)updateAlertWithChapterIdList:(NSArray *)chapterIdList subscriberVO:(SubscriberVO *)subscriberVO;

- (void)show; 

@end
