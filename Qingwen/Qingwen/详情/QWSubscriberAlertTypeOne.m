//
//  QWSubscriberAlertTypeOne.m
//  Qingwen
//
//  Created by mumu on 16/9/30.
//  Copyright © 2016年 mumu. All rights reserved.
//

#import "QWSubscriberAlertTypeOne.h"
#import "QWSubscriberLogic.h"
#import <StoreKit/StoreKit.h>

@interface QWSubscriberAlertTypeOne()

@property (weak, nonatomic) IBOutlet UIButton *buyButton;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIView *seperatorHView;
@property (strong, nonatomic) IBOutlet UIImageView *seperatorVView;

@property (strong, nonatomic) IBOutlet UILabel *heavyCoinLabel;
@property (strong, nonatomic) IBOutlet UILabel *subscriberLabel;
@property (strong, nonatomic) IBOutlet UILabel *doChargeLabel;
@property (strong, nonatomic) IBOutlet UILabel *myTicketLabel;
@property (strong, nonatomic) IBOutlet UILabel *goShopLabel;


@property (strong, nonatomic) IBOutlet UIButton *currentLocateBtn;
@property (strong, nonatomic) IBOutlet UIButton *goldBtn;
@property (strong, nonatomic) IBOutlet UIButton *ticketBtn;

@property (strong, nonatomic) SubscriberVO *subscriberVO;
@property (strong, nonatomic) QWShopLogic *shopLogic;
@property (strong, nonatomic) QWChargeLogic *logic;
@property (strong, nonatomic) QWSubscriberLogic *subscriberLogic;
@property (nonatomic, copy) QWSubscriberActionBlock actionBlock;

@property (nonatomic, assign) BOOL isSubscriberAllBook;
@property (nonatomic, strong) NSArray *chapterIdList;

- (IBAction)buyAction;
- (IBAction)removeAction;

@end


@implementation QWSubscriberAlertTypeOne


- (void)awakeFromNib {
    [super awakeFromNib];
    self.seperatorHView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"subscriber_separator_horizontal"]];
}

- (QWChargeLogic *)logic {
    if (!_logic) {
        _logic = [QWChargeLogic logicWithOperationManager:self.operationManager];
    }
    
    return _logic;
}

- (QWSubscriberLogic *)subscriberLogic {
    if (!_subscriberLogic) {
        _subscriberLogic = [QWSubscriberLogic logicWithOperationManager:self.operationManager];
    }
    
    return _subscriberLogic;
}

-(QWShopLogic *)shopLogic {
    if (!_shopLogic) {
        _shopLogic = [QWShopLogic logicWithOperationManager:self.operationManager];
    }
    return _shopLogic;
}

+ (instancetype)alertViewWithButtonAction:(QWSubscriberActionBlock)actionBlock {
    
    QWSubscriberAlertTypeOne *alert =  [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] firstObject];
    [alert setupViews];
    alert.actionBlock = actionBlock;
    return alert;
}

- (IBAction)onPressedSelectedBtn:(UIButton *)sender {
    if (self.subscriberVO.amount_coin.integerValue < 1 && sender.tag == 1) {
        return;
    }
    self.currentLocateBtn.selected = false;
    self.currentLocateBtn = sender;
    self.currentLocateBtn.selected = true;
    
}

- (void)setupViews {
    
    self.mainView.layer.cornerRadius = 3;
    self.mainView.layer.borderWidth = 1;
    self.mainView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    CGFloat width = self.frame.size.width - 30;
    self.frame = CGRectMake(0, 0, width, 190);
    
    self.buyButton.layer.cornerRadius = 3;
    
    if ([QWGlobalValue sharedInstance].user.gold) {
        self.heavyCoinLabel.text = [NSString stringWithFormat:@"您的重石余额: %@",[QWGlobalValue sharedInstance].user.gold];
    } else  {
        self.heavyCoinLabel.text = @"您的重石余额: 0";
    }
    self.doChargeLabel.attributedText = [[NSAttributedString alloc] initWithString:@"去充值" attributes:@{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]}];
    self.goShopLabel.attributedText = [[NSAttributedString alloc] initWithString:@"去签到" attributes:@{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]}];
    WEAK_SELF;
    [self.doChargeLabel bk_whenTapped:^{
        STRONG_SELF;
        [self rechargeAction];
    }];
    [self.goShopLabel bk_whenTapped:^{
        STRONG_SELF;
        [self removeAction];
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"mycenter" andParams:nil]];
        
    }];
}

- (void)updateAlertWithSubscriberVO:(SubscriberVO *)subscriberVO {
    self.subscriberVO = subscriberVO;
    self.isSubscriberAllBook = YES;
    
    self.subscriberLabel.text = [NSString stringWithFormat:@"批量订阅，共%@章付费章节",subscriberVO.chapter_count];
    
    [self.goldBtn setTitle:[NSString stringWithFormat:@" 重石X%@ (+ %@信仰) ",  subscriberVO.amount,subscriberVO.points] forState:UIControlStateNormal];
    [self.goldBtn setTitle:[NSString stringWithFormat:@" 重石X%@ (+ %@信仰) ",  subscriberVO.amount,subscriberVO.points] forState:UIControlStateSelected];
    
    [self.ticketBtn setTitle:[NSString stringWithFormat:@" 轻石X%@ (+ %@战力) ",subscriberVO.amount_coin,subscriberVO.battle] forState:UIControlStateNormal];
    [self.ticketBtn setTitle:[NSString stringWithFormat:@" 轻石X%@ (+ %@战力) ",subscriberVO.amount_coin,subscriberVO.battle] forState:UIControlStateSelected];
    
    if ([QWGlobalValue sharedInstance].user.coin) {
        self.myTicketLabel.text = [NSString stringWithFormat:@"您的轻石余额: %@",[QWGlobalValue sharedInstance].user.coin];
    } else  {
        self.myTicketLabel.text = [NSString stringWithFormat:@"您的轻石余额: 0"];
    }
    
   
    
}

- (void)updateAlertWithChapterIdList:(NSArray *)chapterIdList subscriberVO:(SubscriberVO *)subscriberVO {
    self.subscriberVO = subscriberVO;
    self.chapterIdList = chapterIdList;
    self.isSubscriberAllBook = NO;
    if ([subscriberVO.buy_type isEqualToString:@"1"]) {
        if ([subscriberVO.volume_num.stringValue isEqualToString:@"1"]) {
            self.subscriberLabel.text = [NSString stringWithFormat:@"订阅本卷\n应版权方要求，本作品需按卷购买"];
        }
        else{
            self.subscriberLabel.text = [NSString stringWithFormat:@"订阅%@卷\n应版权方要求，本作品需按卷购买",subscriberVO.volume_num.stringValue];
            
        }
        
    }
    else{
        self.subscriberLabel.text = [NSString stringWithFormat:@"批量订阅，共%@章付费章节",subscriberVO.chapter_count];
    }
    [self.buyButton setTitle:@"确认" forState:UIControlStateNormal];
    [self.goldBtn setTitle:[NSString stringWithFormat:@" 重石X%@ (+ %@信仰) ",  subscriberVO.amount,subscriberVO.points] forState:UIControlStateNormal];
    [self.goldBtn setTitle:[NSString stringWithFormat:@" 重石X%@ (+ %@信仰) ",  subscriberVO.amount,subscriberVO.points] forState:UIControlStateSelected];
    [self.ticketBtn setTitle:[NSString stringWithFormat:@" 轻石X%@ (+ %@战力) ",subscriberVO.amount_coin,subscriberVO.battle] forState:UIControlStateNormal];
    [self.ticketBtn setTitle:[NSString stringWithFormat:@" 轻石X%@ (+ %@战力) ",subscriberVO.amount_coin,subscriberVO.battle] forState:UIControlStateSelected];
    if ([QWGlobalValue sharedInstance].user.coin) {
        self.myTicketLabel.text = [NSString stringWithFormat:@"您的轻石余额: %@",[QWGlobalValue sharedInstance].user.coin];
    } else  {
        self.myTicketLabel.text = [NSString stringWithFormat:@"您的轻石余额: 0"];
    }
    
//    WEAK_SELF;
//    [self.shopLogic getCanUseCountWithCompletBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
//        STRONG_SELF;
//        if (aResponseObject && !anError) {
//            NSInteger count = [aResponseObject integerValue];
//            self.subscriberVO.can_use_voucher = @(count);
//
//        }
//    }];
    
   
}
- (IBAction)rechargeAction {
    [self removeAction];
    QWCharge *charge = [[QWCharge alloc]init];
    [charge doCharge];
    //    _actionBlock(QWSubscriberActionTypeRecharge);
}

- (IBAction)rechargeCenterAction {
    [self removeAction];
}

- (IBAction)buyAction {
    if (_subscriberVO.amount.integerValue > [QWGlobalValue sharedInstance].user.gold.integerValue && self.currentLocateBtn.tag == 0) {
        [self showToastWithTitle:@"重石不够" subtitle:nil type:ToastTypeAlert];
        return;
    }
    if (_subscriberVO.amount_coin.integerValue > [QWGlobalValue sharedInstance].user.coin.integerValue && self.currentLocateBtn.tag == 1) {
        [self showToastWithTitle:@"轻石不够" subtitle:nil type:ToastTypeAlert];
        return;
    }
    [self showLoadingWithMessageAndAnimate:@"正在批量订阅章节中，请勿重复操作"];
    WEAK_SELF;
    if (self.isSubscriberAllBook) {
        [self.subscriberLogic doSubscriberBookWithBook:_subscriberVO.book_id useVoucher:[NSNumber numberWithInteger:self.currentLocateBtn.tag] andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            STRONG_SELF;
            [self hideLoading];
            if (!anError) {
                NSNumber *code = aResponseObject[@"code"];
                if (code && ! [code isEqualToNumber:@0]) {//有错误
                    NSString *message = aResponseObject[@"data"];
                    if (message.length) {
                        [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                    }
                    else {
                        [self showToastWithTitle:aResponseObject[@"msg"] subtitle:nil type:ToastTypeError];
                    }
                }
                else {
                    
                    NSString *key = aResponseObject[@"data"];
                    [self QueryWhetherBuySuccessAllBookWithKey:key];
                }
            }
            else {
                [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
            }
        }];
    }
    else {
        NSLog(@"idlist = %@",self.chapterIdList);
        [self.subscriberLogic doSubscriberMultipleChapterWithChapterIdList:self.chapterIdList bookId:self.subscriberVO.book_id useVoucher:@(self.currentLocateBtn.tag) andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            STRONG_SELF;
            [self hideLoading];
            if (!anError) {
                NSNumber *code = aResponseObject[@"code"];
                if (code && ! [code isEqualToNumber:@0]) {//有错误
                    NSString *message = aResponseObject[@"data"];
                    if (message.length) {
                        [self hideLoading];
                        [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                    }
                    else {
                        [self hideLoading];
                        [self showToastWithTitle:aResponseObject[@"msg"] subtitle:nil type:ToastTypeError];
                    }
                }
                else {
//                    if (self.currentLocateBtn.tag == 0) {
//                        [QWGlobalValue sharedInstance].user.gold = @([QWGlobalValue sharedInstance].user.gold.integerValue - self.subscriberVO.amount.integerValue);
//                    }
//                    else if (self.currentLocateBtn.tag == 1) {
//                        [QWGlobalValue sharedInstance].user.coin = @([QWGlobalValue sharedInstance].user.coin.integerValue - self.subscriberVO.amount_coin.integerValue);
//                    }
//                    [[QWGlobalValue sharedInstance] save];
//                    [self removeAction];
//                    self.actionBlock(QWSubscriberActionTypeBuy);
                    NSString *key = aResponseObject[@"data"];
                    [self QueryWhetherBuySuccessWithKey:key];
                    
                }
            }
            else {
                [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
            }

        }];
    }
    
}
-(void)QueryWhetherBuySuccessWithKey:(NSString *)key{
    [self.subscriberLogic QueryWhetherBuySuccessWithKey:key andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code &&  [code isEqualToNumber:@1]) {
                [self hideLoading];
                if (self.currentLocateBtn.tag == 0) {
                    [QWGlobalValue sharedInstance].user.gold = @([QWGlobalValue sharedInstance].user.gold.integerValue - self.subscriberVO.amount.integerValue);
                }
                else if (self.currentLocateBtn.tag == 1) {
                    [QWGlobalValue sharedInstance].user.coin = @([QWGlobalValue sharedInstance].user.coin.integerValue - self.subscriberVO.amount_coin.integerValue);
                }
                [[QWGlobalValue sharedInstance] save];
                [self removeAction];
                self.actionBlock(QWSubscriberActionTypeBuy);
            }
            else if (code && [code isEqualToNumber:@0]){
                sleep(2);
                [self QueryWhetherBuySuccessWithKey:key];
            }
            else{
                [self hideLoading];
                [self showToastWithTitle:@"订阅失败" subtitle:nil type:ToastTypeError];
            }
        }
        else{
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }
    }];
}
-(void)QueryWhetherBuySuccessAllBookWithKey:(NSString *)key{
    [self.subscriberLogic QueryWhetherBuySuccessWithKey:key andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code &&  [code isEqualToNumber:@1]) {
                [self hideLoading];
                if (self.currentLocateBtn.tag == 0) {
                    [QWGlobalValue sharedInstance].user.gold = @([QWGlobalValue sharedInstance].user.gold.integerValue - self.subscriberVO.amount.integerValue);
                }else if (self.currentLocateBtn.tag == 1) {
                    [QWGlobalValue sharedInstance].user.coin = @([QWGlobalValue sharedInstance].user.coin.integerValue - self.subscriberVO.amount_coin.integerValue);
                }
                [[QWGlobalValue sharedInstance] save];
                
                [self showToastWithTitle:@"订阅成功,已添加到收藏夹" subtitle:nil type:ToastTypeError];
                [self removeAction];
            }
            else if (code && [code isEqualToNumber:@0]){
                sleep(2);
                [self QueryWhetherBuySuccessWithKey:key];
            }
            else{
                [self hideLoading];
                [self showToastWithTitle:@"订阅失败" subtitle:nil type:ToastTypeError];
            }
        }
        else{
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }
    }];
}
- (IBAction)removeAction {
    [self removeFromSuperview];
}

- (void)show {
    self.frame = [UIScreen mainScreen].bounds;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
}
- (void)dealloc {
    NSLog(@"[%@ call %@]", [self class], NSStringFromSelector(_cmd));
}
@end
