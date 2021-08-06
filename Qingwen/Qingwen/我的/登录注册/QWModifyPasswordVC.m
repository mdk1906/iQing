//
//  QWModifyPasswordVC.m
//  Qingwen
//
//  Created by Aimy on 7/14/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWModifyPasswordVC.h"

#import "QWMyCenterLogic.h"
#import "QWDeadtimeTimer.h"
#import "QWChangeStateTVC.h"

@interface QWModifyPasswordVC () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UITextField *phoneTF;
@property (strong, nonatomic) IBOutlet UITextField *passwordTF;
@property (strong, nonatomic) IBOutlet UITextField *passwordAgainTF;

@property (strong, nonatomic) IBOutlet UITextField *verificationCodeTF;
@property (strong, nonatomic) IBOutlet UIButton *sendVerificationCode;

@property (strong, nonatomic) IBOutlet UIButton *stateBtn;

@property (nonatomic, strong) QWMyCenterLogic *logic;

@property (strong, nonatomic) QWDeadtimeTimer *timer;

@end

@implementation QWModifyPasswordVC

- (void)resize:(CGSize)size
{
    CGRect frame = self.contentView.frame;
    frame.size.width = size.width;
    self.contentView.frame = frame;

    if (ISIPHONE3_5) {
        self.scrollView.contentSize = CGSizeMake(size.width, size.height + 130);
    }
    else if (ISIPHONE4_0) {
        self.scrollView.contentSize = CGSizeMake(size.width, size.height + 80);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.scrollView addSubview:self.contentView];

    [self resize:CGSizeMake(UISCREEN_WIDTH, UISCREEN_HEIGHT)];
    
    self.navigationController.navigationBar.hidden = false;
    
    self.timer = [QWDeadtimeTimer new];
}

- (QWMyCenterLogic *)logic
{
    if (!_logic) {
        _logic = [QWMyCenterLogic logicWithOperationManager:self.operationManager];
    }

    return _logic;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.phoneTF becomeFirstResponder];
}

- (IBAction)onPressedCancelBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onPressedSendVerificationCodeBtn:(id)sender {
    if (!self.phoneTF.text.length) {
        [self showToastWithTitle:@"手机号为空" subtitle:nil type:ToastTypeError];
        return ;
    }

    NSString *phone = self.phoneTF.text;
    if ( ! [[self.stateBtn titleForState:UIControlStateNormal] isEqualToString:@"86"]) {
        phone = [NSString stringWithFormat:@"+%@%@", [self.stateBtn titleForState:UIControlStateNormal], self.phoneTF.text];
    }

    self.sendVerificationCode.enabled = NO;

    WEAK_SELF;
    [self showLoading];
    [self.logic sendVerificationCodeToPhone:phone registe:QWVerificationTypeResetPassword andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (!anError && code && [code isEqualToNumber:@0]) {
                [self.timer runWithDeadtime:[NSDate dateWithTimeIntervalSinceNow:60.f] andBlock:^(NSDateComponents *dateComponents) {
                    STRONG_SELF;
                    if (dateComponents.second > 0) {
                        [self.sendVerificationCode setTitle:[NSString stringWithFormat:@"%@秒",@(dateComponents.second)] forState:UIControlStateNormal];
                    }
                    else {
                        self.sendVerificationCode.enabled = YES;
                        [self.sendVerificationCode setTitle:@"发送验证码" forState:UIControlStateNormal];
                    }
                }];
            }
            else {
                if ([code isEqualToNumber:@-1]) {
                    [self showToastWithTitle:@"发送失败" subtitle:nil type:ToastTypeError];
                }
                else {
                    NSString *message = aResponseObject[@"msg"];
                    if (message.length) {
                        [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                    }
                    else {
                        [self showToastWithTitle:@"发送失败" subtitle:nil type:ToastTypeError];
                    }
                }

                self.sendVerificationCode.enabled = YES;
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
            self.sendVerificationCode.enabled = YES;
        }

        [self hideLoading];
    }];
}

- (IBAction)onPressedDoneBtn:(id)sender {

    if (!self.phoneTF.text.length) {
        [self showToastWithTitle:@"手机号不能为空" subtitle:nil type:ToastTypeError];
        return ;
    }

    if (!self.verificationCodeTF.text.length) {
        [self showToastWithTitle:@"验证码不能为空" subtitle:nil type:ToastTypeError];
        return ;
    }

    if (self.verificationCodeTF.text.length != 6) {
        [self showToastWithTitle:@"验证码不正确" subtitle:nil type:ToastTypeError];
        return ;
    }

    if (!self.passwordTF.text.length) {
        [self showToastWithTitle:@"密码不能为空" subtitle:nil type:ToastTypeError];
        return ;
    }

    if (self.passwordTF.text.length < 2) {
        [self showToastWithTitle:@"密码不能小于2位" subtitle:nil type:ToastTypeError];
        return ;
    }

    if (self.passwordTF.text.length > 24) {
        [self showToastWithTitle:@"密码不能大于24位" subtitle:nil type:ToastTypeError];
        return ;
    }

    if (!self.passwordAgainTF.text.length) {
        [self showToastWithTitle:@"密码不能为空" subtitle:nil type:ToastTypeError];
        return ;
    }

    if (self.passwordAgainTF.text.length < 2) {
        [self showToastWithTitle:@"密码不能小于2位" subtitle:nil type:ToastTypeError];
        return ;
    }

    if (self.passwordAgainTF.text.length > 24) {
        [self showToastWithTitle:@"密码不能大于24位" subtitle:nil type:ToastTypeError];
        return ;
    }

    if (!self.passwordAgainTF.text.length || ![self.passwordAgainTF.text isEqualToString:self.passwordTF.text]) {
        [self showToastWithTitle:@"密码不一致" subtitle:nil type:ToastTypeError];
        return ;
    }

    NSString *phone = self.phoneTF.text;
    if ( ! [[self.stateBtn titleForState:UIControlStateNormal] isEqualToString:@"86"]) {
        phone = [NSString stringWithFormat:@"+%@%@", [self.stateBtn titleForState:UIControlStateNormal], self.phoneTF.text];
    }

    [self endTextEditing];

    WEAK_SELF;
    [self showLoading];
    [self.logic resetPasswordWithPhone:phone password:self.passwordTF.text code:self.verificationCodeTF.text andCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"data"];
                if (message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:@"重置失败" subtitle:nil type:ToastTypeError];
                }
            }
            else {
                [[QWGlobalValue sharedInstance] clear];

                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_STATE_CHANGED object:nil];

                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }

        [self hideLoading];
    }];
}

#pragma mark - tf delegate

- (void)textFieldDidBeginEditing:(nonnull UITextField *)textField
{
    if (ISIPHONE3_5 || ISIPHONE4_0) {
        if (self.phoneTF == textField) {
            [self.scrollView setContentOffset:CGPointMake(0, self.phoneTF.frame.origin.y - 64 - 20) animated:YES];
        }
        else if (self.verificationCodeTF == textField) {
            [self.scrollView setContentOffset:CGPointMake(0, self.verificationCodeTF.frame.origin.y - 64 - 20) animated:YES];
        }
        else if (self.passwordTF == textField) {
            [self.scrollView setContentOffset:CGPointMake(0, self.passwordTF.frame.origin.y - 64 - 20) animated:YES];
        }
        else if (self.passwordAgainTF == textField) {
            [self.scrollView setContentOffset:CGPointMake(0, self.passwordAgainTF.frame.origin.y - 64 - 20) animated:YES];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!string.length) {
        return YES;
    }

    if (textField == self.verificationCodeTF && self.verificationCodeTF.text.length >= 6) {
        return NO;
    }

    if (textField == self.passwordTF && self.passwordTF.text.length >= 24) {
        return NO;
    }

    if (textField == self.passwordAgainTF && self.passwordAgainTF.text.length >= 24) {
        return NO;
    }
    
    return YES;
}

- (IBAction)unwindToModifyPasswordVC:(UIStoryboardSegue *)sender
{
    QWChangeStateTVC *vc = sender.sourceViewController;
    [self.stateBtn setTitle:vc.selectedState forState:UIControlStateNormal];
}

@end
