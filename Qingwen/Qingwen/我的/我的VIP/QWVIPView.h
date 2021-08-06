//
//  QWVIPView.h
//  Qingwen
//
//  Created by qingwen on 2018/10/15.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QWVIPView : UIView
@property (nonatomic,strong)UIImageView *backImg;
@property (nonatomic,strong)UILabel *titleLab;
@property (nonatomic,strong)UILabel *givingLab;
@property (nonatomic,strong) UILabel *moneyLab;
@property (nonatomic,strong)UILabel *deleteMoneyLab;
@property (nonatomic,strong)UIView *hui;
@property (nonatomic ,strong)NSString *productsId;
@property (nonatomic,strong)UIImageView *recommendedImg;
-(void)addTarget:(id)target selector:(SEL)selector;
-(void)setTitle:(NSString *)title give:(NSString*)give money:(NSString *)money deleteMoney:(NSString*)deleteMoney;
@end
