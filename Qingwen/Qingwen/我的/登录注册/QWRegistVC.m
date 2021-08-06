//
//  QWRegistVC.m
//  Qingwen
//
//  Created by Aimy on 7/2/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWRegistVC.h"

#import "QWDeadtimeTimer.h"

#import "QWMyCenterLogic.h"
#import "QWChangeStateTVC.h"

@interface QWRegistVC ()

@property (strong, nonatomic) IBOutlet UITextField *verificationCodeTF;
@property (strong, nonatomic) IBOutlet UITextField *usernameTF;
@property (strong, nonatomic) IBOutlet UITextField *passwordTF;
@property (strong, nonatomic) IBOutlet UITextField *inviteTF;

@property (strong, nonatomic) IBOutlet UIButton *sendVerificationCode;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) IBOutlet UIButton *registBtn;

@property (strong, nonatomic) QWDeadtimeTimer *timer;

@property (nonatomic, strong) QWMyCenterLogic *logic;

@property (nonatomic, copy, nullable) NSString *target_url;

@end

@implementation QWRegistVC

- (void)resize:(CGSize)size
{
    CGRect frame = self.contentView.frame;
    frame.size.width = size.width;
    self.contentView.frame = frame;
    self.scrollView.contentSize = CGSizeMake(size.width, size.height + 10);
    if (ISIPHONE3_5) {
        self.scrollView.contentSize = CGSizeMake(size.width, size.height + 204);
    }
    else if (ISIPHONE4_0) {
        self.scrollView.contentSize = CGSizeMake(size.width, size.height + 114);
    }
    else if (IS_LANDSCAPE) {
        self.scrollView.contentSize = CGSizeMake(size.width, size.height + 114);
    }
}

- (void)didResize:(CGSize)size
{
    if (IS_LANDSCAPE) {
        self.scrollView.contentSize = CGSizeMake(size.width, size.height + 114);
    }
    else {
        self.scrollView.contentSize = CGSizeMake(size.width, size.height);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if ([self.navigationController.extraData objectForCaseInsensitiveKey:@"target_url"]) {
        self.target_url = [self.navigationController.extraData objectForCaseInsensitiveKey:@"target_url"];
    }
    self.scrollView.showsHorizontalScrollIndicator = false;
    self.scrollView.showsVerticalScrollIndicator = false;
    [self.scrollView addSubview:self.contentView];
    [self resize:CGSizeMake(UISCREEN_WIDTH, UISCREEN_HEIGHT)];

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
    WEAK_SELF;
    [self.timer runWithDeadtime:[NSDate dateWithTimeIntervalSinceNow:60.f] andBlock:^(NSDateComponents *dateComponents) {
        STRONG_SELF;
        if (dateComponents.second > 0) {
            self.sendVerificationCode.enabled = NO;
            [self.sendVerificationCode setTitle:[NSString stringWithFormat:@"%@秒",@(dateComponents.second)] forState:UIControlStateNormal];
        }
        else {
            self.sendVerificationCode.enabled = YES;
            [self.sendVerificationCode setTitle:@"重发" forState:UIControlStateNormal];
        }
    }];
}

- (void)dealloc
{
    [self.timer stop];
}

- (IBAction)onPressedSendVerificationCodeBtn:(id)sender {
    if (!self.phoneText.length) {
        [self showToastWithTitle:@"手机号为空" subtitle:nil type:ToastTypeError];
        return ;
    }

    NSString *phone = self.phoneText;
    if ( ! [self.stateText isEqualToString:@"+86"]) {
        phone = [NSString stringWithFormat:@"%@%@", [self.stateText stringByReplacingOccurrencesOfString:@"+" withString:@""], self.phoneText];
    }
    
    [self showLoading];
    
    WEAK_SELF;
    [self.logic sendVerificationCodeToPhone:phone registe:QWVerificationTypeRegiste andCompleteBlock:^(id aResponseObject, NSError *anError) {
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
                        [self.sendVerificationCode setTitle:@"重发" forState:UIControlStateNormal];
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

- (IBAction)onPressedRegistBtn:(id)sender {
    if (!self.phoneText.length) {
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

    if (!self.usernameTF.text.length) {
        [self showToastWithTitle:@"昵称不能为空" subtitle:nil type:ToastTypeError];
        return ;
    }

    if (self.usernameTF.text.length < 2) {
        [self showToastWithTitle:@"昵称不能小于2位" subtitle:nil type:ToastTypeError];
        return ;
    }

    if (self.usernameTF.text.length > 24) {
        [self showToastWithTitle:@"昵称不能大于24位" subtitle:nil type:ToastTypeError];
        return ;
    }

    if ([self containEmoji:self.usernameTF.text]) {
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

    NSString *phone = self.phoneText;
    if ( ! [self.stateText isEqualToString:@"+86"]) {
        phone = [NSString stringWithFormat:@"%@%@", [self.stateText stringByReplacingOccurrencesOfString:@"+" withString:@""], self.phoneText];
    }

    [self endTextEditing];

    WEAK_SELF;
    [self showLoading];
    [self.logic registWithName:phone password:self.passwordTF.text code:self.verificationCodeTF.text username:self.usernameTF.text invite:self.inviteTF.text andCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"data"];
                if ([message isKindOfClass:[NSString class]] && message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:@"注册失败" subtitle:nil type:ToastTypeError];
                }
            }
            else {
                [QWGlobalValue sharedInstance].token = aResponseObject[@"token"];
                [QWGlobalValue sharedInstance].username = aResponseObject[@"username"];
                [QWGlobalValue sharedInstance].nid = aResponseObject[@"id"];
                [QWGlobalValue sharedInstance].profile_url = aResponseObject[@"profile_url"];
                [QWGlobalValue sharedInstance].channel_token = aResponseObject[@"channel_token"];
                UserVO *user = [UserVO voWithDict:aResponseObject];
                [QWGlobalValue sharedInstance].user = user;
                [[QWGlobalValue sharedInstance] save];

                [QWKeychain setKeychainValue:phone forType:@"phone"];
                
                [[QWBindingValue sharedInstance] update];
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_STATE_CHANGED object:nil];

                [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
                    if (self.target_url.length) {
                        [[QWRouter sharedInstance] routerWithUrlString:self.target_url];
                    }
                }];
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }
        
        [self hideLoading];
            
    }];
}

- (IBAction)onPressedShownBtn:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    self.passwordTF.secureTextEntry = !sender.isSelected;
}

#pragma mark - tf delegate

- (void)textFieldDidBeginEditing:(nonnull UITextField *)textField
{
    if (ISIPHONE3_5 || ISIPHONE4_0) {

        if (self.verificationCodeTF == textField) {
            [self.scrollView setContentOffset:CGPointMake(0, self.verificationCodeTF.frame.origin.y - 64 - 20) animated:YES];
        }
        else if (self.usernameTF == textField) {
            [self.scrollView setContentOffset:CGPointMake(0, self.usernameTF.frame.origin.y - 64 - 20) animated:YES];
        }
        else if (self.inviteTF == textField) {
            [self.scrollView setContentOffset:CGPointMake(0, self.inviteTF.frame.origin.y - 64 - 20) animated:YES];
        }
        else if (self.passwordTF == textField) {
            [self.scrollView setContentOffset:CGPointMake(0, self.passwordTF.frame.origin.y - 64 - 20) animated:YES];
        }

    }
    else if (ISIPHONE4_7) {

        if (self.verificationCodeTF == textField) {
            [self.scrollView setContentOffset:CGPointMake(0, self.verificationCodeTF.frame.origin.y - 64 - 20) animated:YES];
        }
        else if (self.usernameTF == textField) {
            [self.scrollView setContentOffset:CGPointMake(0, self.usernameTF.frame.origin.y - 64 - 20) animated:YES];
        }
        else if (self.inviteTF == textField) {
            [self.scrollView setContentOffset:CGPointMake(0, self.usernameTF.frame.origin.y - 64 - 20) animated:YES];
        }
        else if (self.passwordTF == textField) {
            [self.scrollView setContentOffset:CGPointMake(0, self.verificationCodeTF.frame.origin.y - 64 - 20) animated:YES];
        }

    }
    else if (ISIPHONE9_7 && IS_LANDSCAPE) {
        if (self.verificationCodeTF == textField) {
            [self.scrollView setContentOffset:CGPointMake(0, self.verificationCodeTF.frame.origin.y - 64 - 20) animated:YES];
        }
        else if (self.usernameTF == textField) {
            [self.scrollView setContentOffset:CGPointMake(0, self.usernameTF.frame.origin.y - 64 - 20) animated:YES];
        }
        else if (self.inviteTF == textField) {
            [self.scrollView setContentOffset:CGPointMake(0, self.usernameTF.frame.origin.y - 64 - 20) animated:YES];
        }
        else if (self.passwordTF == textField) {
            [self.scrollView setContentOffset:CGPointMake(0, self.verificationCodeTF.frame.origin.y - 64 - 20) animated:YES];
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

    if (textField == self.usernameTF && self.usernameTF.text.length >= 24) {
        return NO;
    }

    if (textField == self.passwordTF && self.passwordTF.text.length >= 24) {
        return NO;
    }

    return YES;
}

- (BOOL)containEmoji:(NSString *)string {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *result = [regex firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    if (result) {
        [self showToastWithTitle:@"昵称禁止输入emoji" subtitle:nil type:ToastTypeAlert];
    }
    return result != nil;
}
@end
