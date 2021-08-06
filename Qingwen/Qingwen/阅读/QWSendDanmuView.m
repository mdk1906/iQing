//
//  QWSendDanmuView.m
//  Qingwen
//
//  Created by mumu on 16/12/5.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import "QWSendDanmuView.h"

#define kTableViewRowHeight 40

@interface QWSendDanmuView()

@property (strong, nonatomic) IBOutlet QWTableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *danmuLabel;
@property (strong, nonatomic) IBOutlet QWTextView *danmuTextView;
@property (strong, nonatomic) IBOutlet UIButton *fastDanmuBtn;

@property (nonatomic) BOOL config;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;

@property (nonatomic, strong) NSLayoutConstraint *constraint;
@property (strong, nonatomic) IBOutlet UIView *fastDanmuView;

@property (strong, nonatomic) IBOutlet UIView *coverView;
@property (strong, nonatomic) IBOutlet UIButton *avatarBtn;

@property (nonatomic) CGFloat viewHeight;

@property (nonatomic, strong) NSArray *fastDanmuList;
- (CGFloat)viewHeight;

@end

@implementation QWSendDanmuView

- (CGFloat)viewHeight {
    return  [QWSize screenHeight];
}

- (NSArray *)fastDanmuList {
    return  @[@"轻石重石已投，作者加油更新啦！",@"作者的女装呢？",@"先投石再看！",@"已收藏！",@"这设定 6666666",@"又找到一本好看的啦",@"我又来复习这一章了 ww",@"大家看完小说之后也请给作者投喂一下石头哦",@"今天码字了吗作者君？",@"前方高能！！！",];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    self.danmuTextView.placeholder = @"吐槽这一段(20个字内)";
    self.danmuTextView.textColor = HRGB(0x848484);
    self.danmuTextView.font = [UIFont systemFontOfSize:14];
    self.danmuTextView.textColor = HRGB(0x848484);
    self.danmuTextView.returnKeyType = UIReturnKeySend;
    
    [self refreshAvatarNameBtn];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    WEAK_SELF;
    [self.fastDanmuView bk_whenTapped:^{
        STRONG_SELF;
        [weakSelf.fastDanmuBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }];
    [self.coverView bk_whenTapped:^{
        STRONG_SELF;
        [weakSelf hideWithAnimated];
    }];
    [self observeNotification:UIKeyboardWillShowNotification fromObject:nil withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }
        
        KVO_STRONG_SELF;
        NSDictionary *info = [notification userInfo];
        NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGSize keyboardSize = [value CGRectValue].size;
        if (keyboardSize.height > 0) {
            kvoSelf.constraint.constant = - (keyboardSize.height - kvoSelf.tableView.frame.size.height + kvoSelf.viewHeight);
            
            [UIView animateWithDuration:.25f animations:^{
                KVO_STRONG_SELF;
                [kvoSelf layoutIfNeeded];
            }];
        }
    }];
    
    [self observeNotification:LOGIN_STATE_CHANGED withBlock:^(__weak id self, NSNotification *notification) {
        KVO_STRONG_SELF;
        if ( ! notification) {
            return;
        }
        [kvoSelf refreshAvatarNameBtn];
    }];
    
    [self observeNotification:UIKeyboardWillHideNotification fromObject:nil withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }
        
        KVO_STRONG_SELF;
        kvoSelf.constraint.constant = - [kvoSelf viewHeight];
        kvoSelf.fastDanmuBtn.selected = true;
        NSDictionary *info = [notification userInfo];
        NSNumber *during = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        [UIView animateWithDuration:during.doubleValue animations:^{
            KVO_STRONG_SELF;
            [kvoSelf layoutIfNeeded];
        }];
    }];
}

- (void)refreshAvatarNameBtn {
    if ([QWGlobalValue sharedInstance].isLogin) {
        [self.avatarBtn setTitle:[QWGlobalValue sharedInstance].username forState:UIControlStateNormal];
        [self.avatarBtn setTitleColor:HRGB(0xA66868) forState:UIControlStateNormal];
        self.avatarBtn.layer.borderColor = [UIColor clearColor].CGColor;
        self.avatarBtn.enabled = false;
    } else {
        [self.avatarBtn setTitle:@"登录账号" forState:UIControlStateNormal];
        self.avatarBtn.layer.cornerRadius = 10.0;
        self.avatarBtn.layer.borderColor = HRGB(0x999999).CGColor;
        self.avatarBtn.layer.borderWidth = 0.5;
        self.avatarBtn.enabled = true;
    }
}
- (void)didMoveToSuperview {
    if (!_config) {
        self.hidden = true;
        self.config = true;
        self.constraint = [self autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.superview];
        [self autoConstrainAttribute:ALAttributeVertical toAttribute:ALAttributeVertical ofView:self.superview];
        [self autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.superview];
        [self autoSetDimension:ALDimensionHeight toSize:self.viewHeight];
    }
}

- (void)showWithAnimated {
    self.hidden = false;
    [self.danmuTextView becomeFirstResponder];
}

- (void)hideWithAnimated {
    self.fastDanmuBtn.selected = false;
    self.danmuTextView.text = @"";
    self.danmuLabel.text = @"快捷弹幕:";
    [self endTextEditing];
    WEAK_SELF;
    [UIView animateWithDuration:.3f animations:^{
        STRONG_SELF;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        STRONG_SELF;
        self.hidden = YES;
    }];
}

#pragma mark - action 

- (IBAction)onPressedShowTableView:(UIButton *)sender {
    if (sender.selected) {
        [self.danmuTextView becomeFirstResponder];
    } else {

        [self endTextEditing];
        self.fastDanmuBtn.selected = false;
    }
    sender.selected = !sender.isSelected;
}
- (IBAction)onPressedSendDanmuBtn:(id)sender {
    if (![QWBindingValue sharedInstance].isBindPhone) {
        UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"" message:@"应国家相关法律法规规定，您必须绑定手机号码后方可发表弹幕。"];
        [alert bk_addButtonWithTitle:@"取消" handler:^{
            
        }];
        [alert bk_addButtonWithTitle:@"确定" handler:^{
            NSDictionary *param = @{@"bind_phone":[NSNumber numberWithInt:1]};
            [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"myself" andParams:param]];
        }];
        [alert show];
    }
    else{
        if (!self.danmuTextView.text.length) {
            return ;
        }
        if ([_delegate respondsToSelector:@selector(sendDanmuWithString:)]) {
            NSString *content = [[QWBannedWords sharedInstance] cryptoStringWithText:self.danmuTextView.text];
            [_delegate sendDanmuWithString:content];
        }
        [self hideWithAnimated];
    }
    
}

- (IBAction)onPressedHideView:(id)sender {
    [self hideWithAnimated];
}
- (IBAction)onPressedLoginBtn:(id)sender {
    if ([QWGlobalValue sharedInstance].isLogin) {
        return;
    }
    [self hideWithAnimated];
    [[QWRouter sharedInstance] routerToLogin];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (!text.length) {
        return  true;
    }
    if (textView == self.danmuTextView && [text isEqualToString:@"\n"]) {
        [self onPressedSendDanmuBtn:nil];
        return  false;
    }
    if (textView == self.danmuTextView && self.danmuTextView.text.length > 20) {
        return false;
    }
    return  true;
}


#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.fastDanmuList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.textLabel.text = self.fastDanmuList[indexPath.row];
    cell.textLabel.textColor = HRGB(0x888888);
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    if (IOS_SDK_MORE_THAN_OR_EQUAL(8.0)) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.danmuTextView.text = self.fastDanmuList[indexPath.row];
    self.danmuLabel.text = [NSString stringWithFormat:@"快捷弹幕:%@",self.fastDanmuList[indexPath.row]];
}

@end
