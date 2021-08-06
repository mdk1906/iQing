//
//  QWBuyTicketAlertView.h
//  Qingwen
//
//  Created by mumu on 16/10/27.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsVO.h"
#import "QWSubscriberAlertTypeOne.h"

@interface QWBuyTicketAlertView : UIView

+ (instancetype)alertViewWithButtonAction:(QWSubscriberActionBlock)actionBlock;
- (void)updateWithGoods:(GoodsVO *)goods;
- (void)show;

@end
