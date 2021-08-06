//
//  QWBuyTicketAlertView.m
//  Qingwen
//
//  Created by mumu on 16/10/27.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import "QWBuyTicketAlertView.h"

@interface QWBuyTicketAlertView()
@property (weak, nonatomic) IBOutlet UILabel *propmtLabel;

@property (weak, nonatomic) IBOutlet UITextField *countField;
@property (strong, nonatomic) IBOutlet UILabel *coinLabel;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UILabel *expirationLabel;

@property (weak, nonatomic) IBOutlet UIImageView *ticketImageView;
@property (nonatomic, copy) QWSubscriberActionBlock actionBlock;

@property (weak, nonatomic) IBOutlet UIButton *cancleButton;

@property (weak, nonatomic) IBOutlet UIButton *buyButton;

@property (weak, nonatomic) IBOutlet UIButton *reduceButton;

@property (strong, nonatomic) QWShopLogic *shopLogic;

@property (strong, nonatomic) GoodsVO *goods;

@property (strong, nonatomic) UIAlertView *alert;

- (IBAction)removeAction:(id)sender;
- (IBAction)reduceAction:(id)sender;
- (IBAction)addAction:(id)sender;
@end

@implementation QWBuyTicketAlertView

+ (instancetype)alertViewWithButtonAction:(QWSubscriberActionBlock)actionBlock {
    
    QWBuyTicketAlertView *alert =  [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] firstObject];
    [alert setupViews];
    alert.actionBlock = actionBlock;
    return alert;
    
}

-(QWShopLogic *)shopLogic {
    if (!_shopLogic) {
        _shopLogic = [QWShopLogic logicWithOperationManager:self.operationManager];
    }
    return _shopLogic;
}

- (void)setupViews {
    
    self.mainView.layer.cornerRadius = 3;
    self.mainView.layer.borderWidth = 1;
    self.mainView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    CGFloat width = self.frame.size.width - 30;
    self.frame = CGRectMake(0, 0, width, 190);
    
    self.cancleButton.layer.cornerRadius = 3;
    self.cancleButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.cancleButton.layer.borderWidth = 1;
    
    self.buyButton.layer.cornerRadius = 3;
    
    self.alert =  [[UIAlertView alloc] initWithTitle:@"消息" message:@"" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
    [self setPropmtLabelText];
}

- (void)updateWithGoods:(GoodsVO *)goods {
    self.goods = goods;
    self.coinLabel.text = [NSString stringWithFormat:@"我的轻石: %@",[QWGlobalValue sharedInstance].user.coin];
    
    if (goods.icon.length > 0) {
        [self.ticketImageView qw_setImageUrlString:[QWConvertImageString convertPicURL:goods.icon imageSizeType:QWImageSizeTypeCover] placeholder:nil animation:true];
    }else {
        self.ticketImageView.image = [UIImage imageNamed:@"shop_alert_ticket"];
    }
    NSDate *sevenDayAfter = [NSDate dateWithDaysFromNow:goods.period.integerValue];
    self.expirationLabel.text = [NSString stringWithFormat:@"将于%@过期",[QWHelper fullDateToString:sevenDayAfter]];
    [self setPropmtLabelText];
}

- (IBAction)buyTicketAction:(id)sender {
    
    NSNumber *costPrice = @([self.countField.text integerValue] * self.goods.price.integerValue);
    if (costPrice.integerValue > [QWGlobalValue sharedInstance].user.coin.integerValue) {
        [self showToastWithTitle:@"轻石不够" subtitle:nil type:ToastTypeError];
    } else {
        [self showLoading];
        WEAK_SELF;
        [self.shopLogic buyTicketWithGoods:self.goods count:@([self.countField.text integerValue]) completeBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            STRONG_SELF;
            [self hideLoading];
            if (!anError) {
                NSNumber *code = aResponseObject[@"code"];
                if (code && ! [code isEqualToNumber:@0]) {//有错误
                    NSString *message = aResponseObject[@"msg"];
                    if (message.length) {
                        self.alert.title = @"购买失败";
                        self.alert.message = [NSString stringWithFormat:@"%@",message];
                        [self.alert show];
                        //[self showToastWithTitle:@"购买失败" subtitle:message type:ToastTypeAlert];
                    }
                    else {
                        [self showToastWithTitle:@"购买失败" subtitle:nil type:ToastTypeError];
                    }
                }
                else {
                    [QWGlobalValue sharedInstance].user.coin = @([QWGlobalValue sharedInstance].user.coin.integerValue - self.goods.price.integerValue);
                    [[QWGlobalValue sharedInstance] save];
                    [self removeAction:nil];
                    [self showToastWithTitle:[NSString stringWithFormat:@"获得%@张购书券",@([self.countField.text integerValue])] subtitle:nil type:ToastTypeAlert];
                }
            }
            else {
                [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
            }
        }];
    }
}


- (void)show {
    self.frame = [UIScreen mainScreen].bounds;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
}

- (IBAction)removeAction:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)reduceAction:(UIButton *)sender {
    NSInteger number = [self.countField.text integerValue];
    --number;
    if(number == 0) {
        sender.enabled = NO;
    }
    self.countField.text = [NSString stringWithFormat:@"%@",@(number)];
    [self setPropmtLabelText];
}

- (IBAction)addAction:(UIButton *)sender {
    NSInteger number = [self.countField.text integerValue];
    ++number;
    self.reduceButton.enabled = YES;
    self.countField.text = [NSString stringWithFormat:@"%@",@(number)];
    [self setPropmtLabelText];
}

- (void)setPropmtLabelText {
    NSString *quanNum = self.countField.text;
    NSString *qingshinNum = [NSString stringWithFormat:@"%@", @([self.countField.text integerValue] * self.goods.price.integerValue)];
    
    NSMutableAttributedString *mutAttr = [[NSMutableAttributedString alloc] initWithString:@"购买购书券张，总额轻石"];
    UIColor *color = [UIColor colorWithRed:250/255.0 green:142/255.0 blue:155/255.0 alpha:1.0];
    NSAttributedString *attr1 = [[NSAttributedString alloc] initWithString:quanNum attributes:@{NSForegroundColorAttributeName: color}];
    NSAttributedString *attr2 = [[NSAttributedString alloc] initWithString:qingshinNum attributes:@{NSForegroundColorAttributeName: color}];
    [mutAttr insertAttributedString:attr2 atIndex:@"购买购书券张，总额".length];
    [mutAttr insertAttributedString:attr1 atIndex:@"购买购书券".length];
    self.propmtLabel.attributedText = mutAttr;
}



@end
