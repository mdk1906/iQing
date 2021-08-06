//
//  QWBindPhoneView.m
//  Qingwen
//
//  Created by mumu on 2017/8/9.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWBindPhoneView.h"
#import "QWTextField.h"

@interface QWBindFirstView()

@property (nonatomic, strong) QWMyCenterLogic *logic;
@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, strong) NSArray *resource;
@property (nonatomic, strong) IBOutlet UIButton *stateBtn;
@property (nonatomic, strong) QWPopoverView *stateView;
@property (nonatomic, strong) QWDeadtimeTimer *timer;
@property (nonatomic, strong) IBOutlet UITextField *phoneTextField;
@property (nonatomic, strong) IBOutlet UIButton *sendVerificationCode;
@property (nonatomic, strong) IBOutlet UITextField *verificationCodeTF;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstTopConstraint;
@property (nonatomic, strong) NSString *AreacCode;
@property (nonatomic, strong) void (^goNext)();
@property (nonatomic, strong) void (^dismiss)();
@end

@implementation QWBindFirstView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.timer = [QWDeadtimeTimer new];
    _AreacCode = @"+86";
}

- (NSArray *)resource {
    if (!_resource) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"state" ofType:@"plist"];
        NSArray *states = [NSArray arrayWithContentsOfFile:plistPath];
        NSMutableArray *tempStates = @[].mutableCopy;
        [states enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *statesNumbers = [obj objectForKey:@"states"];
            [statesNumbers enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [tempStates addObject:obj];
            }];
        }];
        _resource = tempStates.copy;
        
    }
    return _resource;
}

- (QWPopoverView *)stateView {
    if (!_stateView) {
        CGFloat x = self.stateBtn.center.x + self.contentView.mj_x;
        CGFloat y = self.contentView.mj_y + self.stateBtn.mj_y + self.stateBtn.mj_h;
        _stateView = [[QWPopoverView alloc] initWithPoint:CGPointMake(x, y) titles:self.resource size:CGSizeMake(self.stateBtn.mj_w, self.contentView.frame.size.height - self.stateBtn.mj_h - self.stateBtn.mj_y)];
    }
    return _stateView;
}

- (IBAction)hide:(id)sender {
    self.dismiss();
}

- (IBAction)onPressedStateBtn:(UIButton *)sender {
    [self.stateView show];
    WEAK_SELF;
    self.stateView.selectRowAtIndex = ^(NSInteger index) {
        STRONG_SELF;
        NSDictionary *dic = [self.resource objectAtIndex:index];
        _AreacCode = [NSString stringWithFormat:@"+%@",dic[@"code"]];
        [self.stateBtn setTitle:[NSString stringWithFormat:@"%@（+%@）",dic[@"name"],dic[@"code"]] forState:UIControlStateNormal];
    };
}

- (IBAction)onPressedSendVerificationCodeBtn:(id)sender {
    if (!self.phoneTextField.text.length) {
        [self showToastWithTitle:@"手机号不能为空" subtitle:nil type:ToastTypeError];
        return;
    }
    
    [self showLoading];
    
    WEAK_SELF;
    [self.logic sendVerificationCodeToPhone:[QWHelper phoneNumberWithState:self.stateBtn.currentTitle phone:self.phoneTextField.text] registe:QWVerificationTypeRegiste andCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (!anError && code && [code isEqualToNumber:@0]) {
                //                [self performSegueWithIdentifier:@"registphone" sender:nil];
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
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }
        
        [self hideLoading];
    }];
}

- (IBAction)onPressedNextSetpBtn:(id)sender {
    if (!_phoneTextField.text.length) {
        [self showToastWithTitle:@"手机号不能为空" subtitle:nil type:ToastTypeError];
        return ;
    }
    if (!_verificationCodeTF.text.length) {
        [self showToastWithTitle:@"验证码不能为空" subtitle:nil type:ToastTypeError];
        return ;
    }
    [self showLoading];
    WEAK_SELF;
    [self endTextEditing];
    NSString *pho = [NSString string];
    if ([_AreacCode isEqualToString:@"+86"]) {
        pho = _phoneTextField.text;
    }
    else{
        pho = [NSString stringWithFormat:@"%@%@",_AreacCode,_phoneTextField.text];
    }
    
    [self.logic boundWithPhone:pho password:@"" code:_verificationCodeTF.text andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (!anError && aResponseObject) {
            NSNumber *code = [aResponseObject objectForKey:@"code"];
            if (code && ![code isEqualToNumber:@0]) {
                NSString *message = aResponseObject[@"msg"];
                
                if ([message isKindOfClass:[NSString class]] && message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:@"绑定失败" subtitle:nil type:ToastTypeError];
                }
            }
            else {
                self.goNext();
//                _firstView.hidden = true;
//                self.thirdView.hidden = false;
                [[QWBindingValue sharedInstance] update];
            }
        }
        else {
            [self showToastWithTitle:anError.description subtitle:nil type:ToastTypeError];
        }
        [self hideLoading];
    }];
//    [self.logic checkCodeWithPhone:[QWHelper phoneNumberWithState:self.stateBtn.currentTitle phone:self.phoneTextField.text] code:self.verificationCodeTF.text registe:true save:true andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
//        STRONG_SELF;
//        if (!anError && aResponseObject) {
//            NSNumber *code = [aResponseObject objectForKey:@"code"];
//            if (code && ![code isEqualToNumber:@0]) {
//                NSString *message = aResponseObject[@"msg"];
//
//                if ([message isKindOfClass:[NSString class]] && message.length) {
//                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
//                }
//                else {
//                    [self showToastWithTitle:@"验证码错误" subtitle:nil type:ToastTypeError];
//                }
//            }
//            else {
//                self.goNext([QWHelper phoneNumberWithState:self.stateBtn.currentTitle phone:self.phoneTextField.text],self.verificationCodeTF.text);
//            }
//        }
//        else {
//            [self showToastWithTitle:anError.description subtitle:nil type:ToastTypeError];
//        }
//        [self hideLoading];
//    }];
}

@end

@interface QWBindSecondView()
@property (nonatomic, strong) QWMyCenterLogic *logic;

@property (nonatomic, strong) IBOutlet QWTextField *passwordTF;

@property (nonatomic, strong) IBOutlet QWTextField *verifyPasswordTF;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondTopConstraint;

@property (nonatomic, strong) void (^goNext)();
@property (nonatomic, strong) void (^dismiss)();

@property (copy, nonatomic) NSString *phone;
@property (copy, nonatomic) NSString *code;
@end

@implementation QWBindSecondView

- (IBAction)onPressedConfirm:(id)sender {
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
    if (![self.passwordTF.text isEqualToString:self.verifyPasswordTF.text]) {
        [self showToastWithTitle:@"两次输入密码不一样" subtitle:nil type:ToastTypeError];
        return;
    }
    [self endTextEditing];
    WEAK_SELF;
    [self.logic boundWithPhone:_phone password:self.passwordTF.text code:_code andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (!anError && aResponseObject) {
            NSNumber *code = [aResponseObject objectForKey:@"code"];
            if (code && ![code isEqualToNumber:@0]) {
                NSString *message = aResponseObject[@"msg"];
                
                if ([message isKindOfClass:[NSString class]] && message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:@"绑定失败" subtitle:nil type:ToastTypeError];
                }
            }
            else {
                self.goNext();
                [[QWBindingValue sharedInstance] update];
            }
        }
        else {
            [self showToastWithTitle:anError.description subtitle:nil type:ToastTypeError];
        }
        [self hideLoading];
    }];
}

- (IBAction)hide:(id)sender {
    self.dismiss();
}

@end

@interface QWBindThirdView()

@property (nonatomic, strong) void (^dismiss)();
@end

@implementation QWBindThirdView

- (IBAction)onPressedConfirmBtn:(id)sender {
    self.dismiss();
}
@end

@interface QWBindPhoneView()<UITextFieldDelegate>
{
    float _cursorHeight;                                    //光标距底部的高度
    float _spacingWithKeyboardAndCursor;                    //光标与键盘之间的间隔
}
@property (nonatomic, strong) QWMyCenterLogic *logic;
@property (nonatomic, weak) QWBindFirstView *firstView;
@property (nonatomic, weak) QWBindSecondView *secondView;
@property (nonatomic, weak) QWBindThirdView *thirdView;
@end

@implementation QWBindPhoneView

DEF_SINGLETON(QWBindPhoneView);

+ (void)load {
    QWNativeFuncVO *vo = [QWNativeFuncVO new];
    vo.block = [(id) ^(NSDictionary *params) {
        [[QWBindPhoneView sharedInstance] showBindPhoneView];
        return nil;
    } copy];
    
    [[QWRouter sharedInstance] registerNativeFuncVO:vo withKey:@"bindphone"];
}

- (QWMyCenterLogic *)logic {
    if (!_logic) {
        _logic = [QWMyCenterLogic logicWithOperationManager:self.operationManager];
    }
    return _logic;
}

- (QWBindFirstView *)firstView {
    if (!_firstView) {
        UITabBarController *tbc = (id)[[UIApplication sharedApplication].delegate window].rootViewController;
        NSArray *nibView = [[NSBundle mainBundle]loadNibNamed:@"QWBindPhoneView" owner:nil options:nil];
        _firstView = nibView.firstObject;
        _firstView.logic = self.logic;
        _firstView.phoneTextField.inputAccessoryView = [self createDoneButton];
        _firstView.verificationCodeTF.inputAccessoryView = [self createDoneButton];
        _firstView.verificationCodeTF.delegate = self;
        [tbc.view addSubview:_firstView];
        [_firstView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:tbc.view];
        [_firstView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:tbc.view];
        [_firstView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:tbc.view];
        [_firstView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:tbc.view];
    }
    return _firstView;
}

- (QWBindSecondView *)secondView {
    if (!_secondView) {
        UITabBarController *tbc = (id)[[UIApplication sharedApplication].delegate window].rootViewController;
        NSArray *nibView = [[NSBundle mainBundle]loadNibNamed:@"QWBindPhoneView" owner:nil options:nil];
        _secondView = nibView[1];
        _secondView.logic = self.logic;
        _secondView.passwordTF.inputAccessoryView = [self createDoneButton];
        _secondView.verifyPasswordTF.inputAccessoryView = [self createDoneButton];
        [tbc.view addSubview:_secondView];
        [_secondView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:tbc.view];
        [_secondView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:tbc.view];
        [_secondView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:tbc.view];
        [_secondView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:tbc.view];
        _secondView.hidden = true;
    }
    return _secondView;
}

- (QWBindThirdView *)thirdView {
    if (!_thirdView) {
        UITabBarController *tbc = (id)[[UIApplication sharedApplication].delegate window].rootViewController;
        NSArray *nibView = [[NSBundle mainBundle]loadNibNamed:@"QWBindPhoneView" owner:nil options:nil];
        _thirdView = nibView[2];
        [tbc.view addSubview:_thirdView];
        [_thirdView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:tbc.view];
        [_thirdView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:tbc.view];
        [_thirdView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:tbc.view];
        [_thirdView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:tbc.view];
        _thirdView.hidden = true;
    }
    return _thirdView;
}

- (void)configViews {
    WEAK_SELF;
    self.firstView.goNext = ^{
        STRONG_SELF;
//        self.secondView.phone = phone;
//        self.secondView.code = code;
        self.firstView.hidden = true;
//        self.secondView.hidden = false;
        self.secondView.hidden = true;
        self.thirdView.hidden = false;
    };
    self.firstView.dismiss = ^{
        STRONG_SELF;
        [self dismiss];
    };
    
    self.secondView.goNext = ^{
        STRONG_SELF;
        self.secondView.hidden = true;
        self.thirdView.hidden = false;
    };
    self.secondView.dismiss = ^{
        STRONG_SELF;
        [self dismiss];
    };
    
    self.thirdView.dismiss = ^ {
        STRONG_SELF;
        [self dismiss];
    };
    [self AddKeyBoardOB];
}

- (void)dismiss {
    [self.firstView removeFromSuperview];
    [self.secondView removeFromSuperview];
    [self.thirdView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showBindPhoneView {
    [self configViews];
}


- (void)AddKeyBoardOB
{
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification {
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    float keyboardHeight = keyboardRect.origin.y;
    _spacingWithKeyboardAndCursor =  _cursorHeight - keyboardHeight;
    if (_spacingWithKeyboardAndCursor > 0) {
        if(_firstView.hidden == false){
            self.firstView.firstTopConstraint.constant = 144 - _spacingWithKeyboardAndCursor-26;
            
        }else{
            self.secondView.secondTopConstraint.constant = 144 - _spacingWithKeyboardAndCursor-26;
        }
        
    }
}
//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification {
    if (_spacingWithKeyboardAndCursor > 0) {
        if(_firstView.hidden == false){
             self.firstView.firstTopConstraint.constant = 144;
        }else{
            self.secondView.secondTopConstraint.constant = 144;
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    CGPoint point = [textField.superview convertPoint:textField.center toView:self.firstView.superview];
    _cursorHeight = point.y;//CGRectGetMaxY();
    return YES;
}

- (UIToolbar*)createDoneButton
{
    UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(dismissKeyboard)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flex,doneButton, nil]];
    return keyboardDoneButtonView;
}
-(void)dismissKeyboard {
    END_EDITING;
}
@end
