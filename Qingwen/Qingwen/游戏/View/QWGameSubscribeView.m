//
//  QWGameSubscribeView.m
//  Qingwen
//
//  Created by mumu on 2017/10/16.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWGameSubscribeView.h"
#import "QWSubscriberLogic.h"

@interface QWGameSubscribeView()

@property (nonatomic, strong) QWSubscriberActionBlock block;

@property (nonatomic, strong) QWSubscriberLogic *logic;

@property (strong, nonatomic) IBOutlet UILabel *needPayLabel;

@property (strong, nonatomic) IBOutlet UILabel *goldLabel;

@property (copy, nonatomic) NSString *gold;
@property (copy, nonatomic) NSString *gameId;
@property (copy, nonatomic) NSString *chapterId;

@end

@implementation QWGameSubscribeView

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (QWSubscriberLogic *)logic {
    if (!_logic) {
        _logic = [QWSubscriberLogic logicWithOperationManager:self.operationManager];
    }
    return _logic;
}

- (void)showWithGameId:(NSString *)gameId chapterId:(NSString *)chapterId gold:(NSString *)gold andCompletBlock:(QWSubscriberActionBlock)block {
    self.gold = gold;
    self.chapterId = chapterId;
    self.gameId = gameId;
    self.block = block;
    WEAK_SELF;
    [UIView animateWithDuration:0.34 animations:^{
        STRONG_SELF;
        self.hidden = false;
        self.goldLabel.text = [NSString stringWithFormat:@"您的重石余额：%@",[QWGlobalValue sharedInstance].user.gold ? [QWGlobalValue sharedInstance].user.gold : @0];
        self.needPayLabel.text = [NSString stringWithFormat:@"解锁本章节需付%@重石",gold];
    }];
}

- (IBAction)onPressedBuyBtn:(id)sender {
    if (![QWGlobalValue sharedInstance].isLogin) {
        [self onPressedRemove:nil];
        [[QWRouter sharedInstance] routerToLogin];
        return;
    }
    if ([QWGlobalValue sharedInstance].user.gold.doubleValue < self.gold.doubleValue) {
        [self showToastWithTitle:@"你的重石不够解锁此章节演绘内容" subtitle:nil type:ToastTypeError];
        return;
    }
    
    WEAK_SELF;
    [self showLoading];
    [self.logic doSubscriberGameChapterWithChapterId:self.chapterId gameId:self.gameId andCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        [self hideLoading];
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"msg"];
                if (message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:@"解锁章节失败" subtitle:nil type:ToastTypeError];
                }
                self.block(QWSubscriberActionTypeRemove);
            }
            else {
                [QWGlobalValue sharedInstance].user.gold = @([QWGlobalValue sharedInstance].user.gold.doubleValue - self.gold.doubleValue);
                [[QWGlobalValue sharedInstance] save];
                [self showToastWithTitle:@"解锁章节成功" subtitle:nil type:ToastTypeError];
                self.block(QWSubscriberActionTypeBuy);
                self.hidden = true;
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }
    }];
}

- (IBAction)onPressedRemove:(id)sender {
    _block(QWSubscriberActionTypeRemove);
    [UIView animateWithDuration:0.34 animations:^{
        self.hidden = true;
    }];
}

- (IBAction)onPressedChargeCenter:(id)sender {
    QWCharge *charge = [QWCharge new];
    [charge doCharge];
}


@end
