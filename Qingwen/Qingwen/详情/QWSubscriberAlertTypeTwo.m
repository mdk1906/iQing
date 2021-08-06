//
//  QWSubscriberAlertTypeTwo.h
//  Qingwen
//
//  Created by mumu on 16/9/30.
//  Copyright © 2016年 mumu. All rights reserved.
//
#import "QWSubscriberAlertTypeTwo.h"
#import "QWSubscriberAlertTypeOne.h"
#import "QWSubscriberLogic.h"
#import "QWDetailTVC.h"
#import "QWMyCenterLogic.h"
@interface QWSubscriberAlertTypeTwo()

@property (weak, nonatomic) IBOutlet UILabel *subscriberLabel;

@property (weak, nonatomic) IBOutlet UIButton *buyButton;

@property (strong, nonatomic) IBOutlet UILabel *heavyCoinLabel;
@property (strong, nonatomic) IBOutlet UILabel *doChargeLabel;
@property (strong, nonatomic) IBOutlet UILabel *myTicketLabel;
@property (strong, nonatomic) IBOutlet UILabel *goShopLabel;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIView *seperatorHView;

@property (strong, nonatomic) IBOutlet UIButton *currentLocateBtn;
@property (strong, nonatomic) IBOutlet UIButton *ticketBtn;
@property (strong, nonatomic) IBOutlet UIButton *goldBtn;

@property (weak, nonatomic) IBOutlet UIButton *noticeBtn;
@property (nonatomic,strong) UILabel *stoneLab;

@property (nonatomic,strong) UILabel *coinLab;
@property (nonatomic, copy) QWSubscriberActionBlock actionBlock;

@property (strong, nonatomic) QWSubscriberLogic *subscriberLogic;

@property (strong, nonatomic) ChapterVO *chapter;

@property (nonatomic, strong) QWDetailLogic *logic;
@property (strong, nonatomic) QWMyCenterLogic *mylogic;
@property (strong ,nonatomic) UIButton *watchAdBtn;
@property (strong ,nonatomic) UIView *stoneBtnView;
@property (strong ,nonatomic) UIView *coinBtnView;
- (IBAction)buyAction;
- (IBAction)removeAction;
- (IBAction)chooseAction:(id)sender;

@end

@implementation QWSubscriberAlertTypeTwo

- (void)awakeFromNib {
    [super awakeFromNib];
    self.seperatorHView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"subscriber_separator_horizontal"]];
    
}
- (QWMyCenterLogic *)mylogic
{
    if (!_mylogic) {
        _mylogic = [QWMyCenterLogic logicWithOperationManager:self.operationManager];
    }
    
    return _mylogic;
}
- (QWSubscriberLogic *)subscriberLogic {
    if (!_subscriberLogic) {
        _subscriberLogic = [QWSubscriberLogic logicWithOperationManager:self.operationManager];
    }
    
    return _subscriberLogic;
}

- (QWDetailLogic *)logic
{
    if (!_logic) {
        _logic = [QWDetailLogic logicWithOperationManager:self.operationManager];
    }
    
    return _logic;
}

+ (instancetype)alertViewWithButtonAction:(QWSubscriberActionBlock)actionBlock {
    
    QWSubscriberAlertTypeTwo *alert =  [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] firstObject];
    [alert setupViews];
    alert.actionBlock = actionBlock;
    return alert;
    
}

- (void)setupViews {
    
    self.mainView.layer.cornerRadius = 3;
    self.mainView.layer.borderWidth = 1;
    self.mainView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    CGFloat width = self.frame.size.width - 30;
    self.frame = CGRectMake(0, 0, width, 190);
    
    self.buyButton.layer.cornerRadius = 3;
    
    if (![QWGlobalValue sharedInstance].isLogin) {
        self.heavyCoinLabel.attributedText = [[NSAttributedString alloc] initWithString:@"登录" attributes:@{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle],NSFontAttributeName: [UIFont systemFontOfSize:17]}];
        self.heavyCoinLabel.textColor = HRGB(0x1485AE);
        WEAK_SELF;
        [self.heavyCoinLabel bk_whenTapped:^{
            STRONG_SELF;
            [self removeAction];
            [[QWRouter sharedInstance] routerToLogin];
            return ;
        }];
    }else {
        if ([QWGlobalValue sharedInstance].user.gold) {
            self.heavyCoinLabel.text = [NSString stringWithFormat:@"您的重石余额: %@",[QWGlobalValue sharedInstance].user.gold];
        } else  {
            self.heavyCoinLabel.text = @"您的重石余额: 0";
        }
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
    [self createAdView];
    
}

//广告相关界面
-(void)createAdView{
    UIView *huiViwe = [UIView new];
    huiViwe.frame = CGRectMake(13, 40, [QWSize screenWidth]-26, 128);
    huiViwe.backgroundColor = HRGB(0xe8e8e8);
    [_mainView addSubview:huiViwe];
    
    _watchAdBtn = [UIButton new];
    [_watchAdBtn setTitle:@"观看广告，免费阅读" forState:0];
    _watchAdBtn.backgroundColor = HRGB(0xD97049);
    _watchAdBtn.layer.cornerRadius = 2;
    _watchAdBtn.masksToBounds = YES;
    _watchAdBtn.titleLabel.font = FONT(12);
    [_watchAdBtn addTarget:self action:@selector(watchAd) forControlEvents:UIControlEventTouchUpInside];
    _watchAdBtn.frame = CGRectMake(12, 10, [QWSize screenWidth]-26-24, 44);
    [_watchAdBtn setTitleColor:[UIColor whiteColor] forState:0];
    [huiViwe addSubview:_watchAdBtn];
    
    _stoneBtnView = [UIView new];
    [_stoneBtnView bk_tapped:^{
        UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"提示" message:@"确认购买吗？"];
        [alertView bk_addButtonWithTitle:@"确认" handler:^{
            [self buyByStone];
            
        }];
        [alertView bk_addButtonWithTitle:@"取消" handler:^{
            
            
        }];
        [alertView show];
    }];
    _stoneBtnView.frame = CGRectMake(12, 74, ([QWSize screenWidth]-25-10-25)/2, 44);
    _stoneBtnView.backgroundColor = [UIColor whiteColor];
    _stoneBtnView.layer.cornerRadius = 2;
    _stoneBtnView.masksToBounds = YES;
    [huiViwe addSubview:_stoneBtnView];
    
    UIImageView *stoneImg = [UIImageView new];
    stoneImg.image = [UIImage imageNamed:@"重石"];
    stoneImg.frame = CGRectMake(15, 12, 20, 20);
    [_stoneBtnView addSubview:stoneImg];
    
    _stoneLab = [[UILabel alloc] initWithFrame:CGRectMake(kMaxX(stoneImg.frame), 0, ([QWSize screenWidth]-25-10-25)/2, 44)];
    _stoneLab.textColor = HRGB(0xa66868);
    _stoneLab.font = [UIFont systemFontOfSize:12];
//    _stoneLab.text = @"重石 X 10";
    [_stoneBtnView addSubview:_stoneLab];
    
    _coinBtnView = [UIView new];
    [_coinBtnView bk_tapped:^{
        UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"提示" message:@"确认购买吗？"];
        [alertView bk_addButtonWithTitle:@"确认" handler:^{
            [self buyByCoin];
            
        }];
        [alertView bk_addButtonWithTitle:@"取消" handler:^{
            
        }];
        [alertView show];
    }];
    _coinBtnView.frame = CGRectMake(12+10+([QWSize screenWidth]-25-10-25)/2, 74, ([QWSize screenWidth]-25-10-25)/2, 44);
    _coinBtnView.backgroundColor = [UIColor whiteColor];
    _coinBtnView.layer.cornerRadius = 2;
    _coinBtnView.masksToBounds = YES;
    [huiViwe addSubview:_coinBtnView];
    
    UIImageView *coinImg = [UIImageView new];
    coinImg.image = [UIImage imageNamed:@"轻石"];
    coinImg.frame = CGRectMake(15, 12, 20, 20);
    [_coinBtnView addSubview:coinImg];
    
    _coinLab = [[UILabel alloc] initWithFrame:CGRectMake(kMaxX(coinImg.frame), 0, ([QWSize screenWidth]-25-10-25)/2, 44)];
    _coinLab.textColor = HRGB(0xa66868);
    _coinLab.font = [UIFont systemFontOfSize:12];
//    _stoneLab.text = @"重石 X 10";
    [_coinBtnView addSubview:_coinLab];
    
}
//重石购买
-(void)buyByStone{
    self.currentLocateBtn.tag = 0;
    [self buyAction];
    
}
//轻石购买
-(void)buyByCoin{
    self.currentLocateBtn.tag = 1;
    [self buyAction];
}
-(void)watchAd{
    NSLog(@"弹窗广告类型 = %@ 是否看广告 = %@",_chapter.ad_type , _chapter.ad_free);
    if (self.chapter.ad_type == nil){
        
        return;
    }
    if ([[QWGlobalValue sharedInstance].read_ad intValue] == 2){
        [self showToastWithTitle:@"该章节无广告观看" subtitle:nil type:ToastTypeAlert];
        return;
    }
    if ([self.chapter.ad_free intValue] == 0) {
        [self showToastWithTitle:@"该章节无广告观看" subtitle:nil type:ToastTypeAlert];
        return;
    }
    if ([self.chapter.ad_type intValue] == 1) {
        //图片广告
        [[NSNotificationCenter defaultCenter] postNotificationName:@"readWatchPhotoAd" object:nil];
        [self removeAction];
    }
    if ([self.chapter.ad_type intValue] == 0){
        //视频广告
        [[NSNotificationCenter defaultCenter] postNotificationName:@"readWatchVedioAd" object:nil];
        [self removeAction];
        
    }
    
}
- (void)updateAlertWithChapter:(ChapterVO *)chapter{
    self.chapter = chapter;
    NSNumber *buytype = chapter.buy_type;
//
    if ([[QWGlobalValue sharedInstance].read_ad intValue] == 2){
        _watchAdBtn.hidden = YES;
        _stoneBtnView.frame = CGRectMake(12, 42, ([QWSize screenWidth]-25-10-25)/2, 44);
        _coinBtnView.frame = CGRectMake(12+10+([QWSize screenWidth]-25-10-25)/2, 42, ([QWSize screenWidth]-25-10-25)/2, 44);
    }
    if ([chapter.ad_free intValue] == 0) {
        _watchAdBtn.hidden = YES;
        _stoneBtnView.frame = CGRectMake(12, 42, ([QWSize screenWidth]-25-10-25)/2, 44);
        _coinBtnView.frame = CGRectMake(12+10+([QWSize screenWidth]-25-10-25)/2, 42, ([QWSize screenWidth]-25-10-25)/2, 44);
    }
    NSLog(@"chaptercolo2 = %@",self.chapter.collection);
    if ([buytype isEqualToNumber: [NSNumber numberWithInt:1]]) {
        self.subscriberLabel.text = [NSString stringWithFormat:@"订阅本卷\n应版权方要求，本作品需按卷购买"];
//        [self.goldBtn setTitle:[NSString stringWithFormat:@" 重石X%@ (+ %@信仰) ",  chapter.volume_need_amount,chapter.volume_points] forState:UIControlStateNormal];
//        [self.goldBtn setTitle:[NSString stringWithFormat:@" 重石X%@ (+ %@信仰) ",  chapter.volume_need_amount,chapter.volume_points] forState:UIControlStateSelected];
//
//        [self.ticketBtn setTitle:[NSString stringWithFormat:@" 轻石X%@ (+ %@战力) ",chapter.volume_amount_coin,chapter.volume_battle] forState:UIControlStateNormal];
//        [self.ticketBtn setTitle:[NSString stringWithFormat:@" 轻石X%@ (+ %@战力) ",chapter.volume_amount_coin,chapter.volume_battle] forState:UIControlStateSelected];
//        self.noticeBtn.hidden = YES;
        self.stoneLab.text = [NSString stringWithFormat:@" 重石X%@ (+%@信仰) ",  chapter.volume_need_amount,chapter.volume_points];
        self.coinLab.text = [NSString stringWithFormat:@" 轻石X%@ (+%@战力) ",chapter.volume_amount_coin,chapter.volume_battle];
    }
    else{
//        [self.goldBtn setTitle:[NSString stringWithFormat:@" 重石X%@ (+ %@信仰) ",  chapter.amount,chapter.points] forState:UIControlStateNormal];
//        [self.goldBtn setTitle:[NSString stringWithFormat:@" 重石X%@ (+ %@信仰) ",  chapter.amount,chapter.points] forState:UIControlStateSelected];
//
//        [self.ticketBtn setTitle:[NSString stringWithFormat:@" 轻石X%@ (+ %@战力) ",chapter.amount_coin,chapter.battle] forState:UIControlStateNormal];
//        [self.ticketBtn setTitle:[NSString stringWithFormat:@" 轻石X%@ (+ %@战力) ",chapter.amount_coin,chapter.battle] forState:UIControlStateSelected];
        
        self.stoneLab.text = [NSString stringWithFormat:@" 重石X%@ (+%@信仰) ",  chapter.amount,chapter.points];
        self.coinLab.text = [NSString stringWithFormat:@" 轻石X%@ (+%@战力) ",chapter.amount_coin,chapter.battle];
    }
    
    if([QWGlobalValue sharedInstance].user.coin){
        self.myTicketLabel.text = [NSString stringWithFormat:@"您的轻石余额: %@",[QWGlobalValue sharedInstance].user.coin];
    }else{
        self.myTicketLabel.text = [NSString stringWithFormat:@"您的轻石余额: 0"];
    }
    
}


- (IBAction)rechargeAction {
//    _actionBlock(QWSubscriberActionTypeRecharge);
    
    WEAK_SELF;
    if (![QWGlobalValue sharedInstance].isLogin) {
        STRONG_SELF;
        [self removeAction];
        [[QWRouter sharedInstance] routerToLogin];
        return ;
    }
    
    [self removeAction];
    QWCharge *charge = [[QWCharge alloc]init];
    [charge doCharge];
    

}
- (IBAction)onPressedSelectedBtn:(UIButton *)sender {
    if ([QWGlobalValue sharedInstance].user.coin.integerValue < 1 && sender.tag == 1) {
        return;
    }
    self.currentLocateBtn.selected = false;
    self.currentLocateBtn = sender;
    self.currentLocateBtn.selected = true;
    
}

- (IBAction)doPressedSubscriberBookAction {
//    _actionBlock(QWSubscriberActionTypeRechargeCenter);
    WEAK_SELF;
    [self.subscriberLogic getSubscriberInfoWithBookId:self.chapter.book andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        [self removeAction];
        if (aResponseObject && !anError) {
            SubscriberVO *subscriberVO = [SubscriberVO voWithDict:aResponseObject];
            if (subscriberVO.amount.integerValue > 0) {
                QWSubscriberAlertTypeOne *alert = [QWSubscriberAlertTypeOne alertViewWithButtonAction:^(QWSubscriberActionType type) {
                }];
                [alert updateAlertWithSubscriberVO:subscriberVO];
                [alert show];
            }
        }
    }];
}

- (IBAction)buyAction {
    WEAK_SELF;
    if (![QWGlobalValue sharedInstance].isLogin) {
        STRONG_SELF;
        [self removeAction];
        [[QWRouter sharedInstance] routerToLogin];
        return ;
    }
    if (self.chapter.amount.integerValue > [QWGlobalValue sharedInstance].user.gold.integerValue && self.currentLocateBtn.tag == 0) {
        [self showToastWithTitle:@"重石不足" subtitle:nil type:ToastTypeAlert];
        return;
    }
    if (self.chapter.amount_coin.integerValue > [QWGlobalValue sharedInstance].user.coin.integerValue && self.currentLocateBtn.tag == 1) {
        [self showToastWithTitle:@"轻石不足" subtitle:nil type:ToastTypeAlert];
        return;
    }
    [self showLoading];
    NSNumber *buytype = self.chapter.buy_type;
    if ([buytype isEqualToNumber: [NSNumber numberWithInt:1]]) {
        [self.subscriberLogic doSubscriberChaperWithVolumeId: self.chapter.volumeId useVoucher:[NSNumber numberWithInteger:self.currentLocateBtn.tag] bookId:self.chapter.book andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
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
//                    if (self.currentLocateBtn.tag == 0) {
//                        [QWGlobalValue sharedInstance].user.gold = @([QWGlobalValue sharedInstance].user.gold.integerValue - self.chapter.amount.integerValue);
//                    }
//                    else if (self.currentLocateBtn.tag == 1) {
//                        [QWGlobalValue sharedInstance].user.coin = @([QWGlobalValue sharedInstance].user.coin.integerValue - self.chapter.amount_coin.integerValue);
//                    }
//                    [self getAttention];
//
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
    else{
    [self.subscriberLogic doSubscriberChaperWithChapterId: self.chapter.nid useVoucher:[NSNumber numberWithInteger:self.currentLocateBtn.tag] andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"data"];
                if (message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:aResponseObject[@"msg"] subtitle:nil type:ToastTypeError];
                    [self hideLoading];
                }
            }
            else {
//                if (self.currentLocateBtn.tag == 0) {
//                    [QWGlobalValue sharedInstance].user.gold = @([QWGlobalValue sharedInstance].user.gold.integerValue - self.chapter.amount.integerValue);
//                }
//                else if (self.currentLocateBtn.tag == 1) {
//                    [QWGlobalValue sharedInstance].user.coin = @([QWGlobalValue sharedInstance].user.coin.integerValue - self.chapter.amount_coin.integerValue);
//                }
//                [self getAttention];
//                [[QWGlobalValue sharedInstance] save];
//                [self removeAction];
//                self.actionBlock(QWSubscriberActionTypeBuy);
                NSString *key = aResponseObject[@"data"];
                [self QueryWhetherBuySuccessWithKey:key];
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
            [self hideLoading];
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
                    [QWGlobalValue sharedInstance].user.gold = @([QWGlobalValue sharedInstance].user.gold.integerValue - self.chapter.amount.integerValue);
                }
                else if (self.currentLocateBtn.tag == 1) {
                    [QWGlobalValue sharedInstance].user.coin = @([QWGlobalValue sharedInstance].user.coin.integerValue - self.chapter.amount_coin.integerValue);
                }
                [[QWGlobalValue sharedInstance] save];
                [self getAttention];
                [self removeAction];
                self.actionBlock(QWSubscriberActionTypeBuy);
            }
            else if (code && [code isEqualToNumber:@0]){
                sleep(1);
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

- (void)getAttention
{
    if ([self.chapter.collection isEqualToNumber:[NSNumber numberWithInt:1]]) {
        
    }
    else{
//        [self showToastWithTitle:@"自动收藏成功" subtitle:nil type:ToastTypeAlert];
    }
   
}

- (IBAction)removeAction {
    [self removeFromSuperview];

}

- (IBAction)chooseAction:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.selected) {
        self.subscriberLogic.autoPurechase = @1;
        
        [self showLoading];
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"token"] = [QWGlobalValue sharedInstance].token;
        params[@"book"] = self.chapter.book;
        params[@"switch"] =  @"1";
        QWOperationParam *param = [QWInterface getWithDomainUrl:@"subscriber/book_auto_switch/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
            [self hideLoading];
            if (!anError) {
                NSNumber *code = aResponseObject[@"code"];
                NSLog(@"result :%@",code);
                if (code && ! [code isEqualToNumber:@0]) {//有错误
                    NSString *message = aResponseObject[@"msg"];
                    if (message.length) {
                        [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                        
                    }
                    else {
                        [self showToastWithTitle:@"提交失败" subtitle:nil type:ToastTypeError];
                    }
                }else{
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"dakaiDingyue" object:nil];
                    
                }
            }
        }];
        param.requestType = QWRequestTypePost;
        [self.operationManager requestWithParam:param];
    }else {
        self.subscriberLogic.autoPurechase = @0;
        [self showLoading];
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"token"] = [QWGlobalValue sharedInstance].token;
        params[@"book"] = self.chapter.book;
        params[@"switch"] =  @"0";
        QWOperationParam *param = [QWInterface getWithDomainUrl:@"subscriber/book_auto_switch/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
            [self hideLoading];
            if (!anError) {
                NSNumber *code = aResponseObject[@"code"];
                NSLog(@"result :%@",code);
                if (code && ! [code isEqualToNumber:@0]) {//有错误
                    NSString *message = aResponseObject[@"msg"];
                    if (message.length) {
                        [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                       
                    }
                    else {
                        [self showToastWithTitle:@"提交失败" subtitle:nil type:ToastTypeError];
                    }
                }else{
                     [[NSNotificationCenter defaultCenter]postNotificationName:@"cancelDingyue" object:nil];
                    
                }
            }
        }];
        param.requestType = QWRequestTypePost;
        [self.operationManager requestWithParam:param];
    }
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
