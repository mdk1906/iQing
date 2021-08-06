//
//  QWRegistPhoneVC.m
//  Qingwen
//
//  Created by mumu on 16/11/11.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import "QWRegistPhoneVC.h"
#import "QWRegistVC.h"
#import "QWChangeStateTVC.h"
#import "QWTextField.h"

@interface QWRegistPhoneVC ()<UITextFieldDelegate>
{
    float _cursorHeight;                                    //光标距底部的高度
    float _spacingWithKeyboardAndCursor;                    //光标与键盘之间的间隔
}
@property (strong, nonatomic) IBOutlet UIButton *stateBtn;
@property (strong, nonatomic) IBOutlet QWTextField *phoneTextField;

@property (strong, nonatomic) IBOutlet UIButton *sendVerificationCode;
@property (strong, nonatomic) IBOutlet QWTextField *verificationCodeTF;
@property (strong, nonatomic) IBOutlet UITextField *usernameTF;
@property (strong, nonatomic) IBOutlet UITextField *passwordTF;
@property (strong, nonatomic) IBOutlet QWTextField *verifyPasswordTF;

@property (strong, nonatomic) IBOutlet UIButton *registPhoneBtn;
@property (nonatomic, strong) QWMyCenterLogic *logic;

@property (strong, nonatomic) IBOutlet UIView *firstRegistView;
@property (strong, nonatomic) IBOutlet UIView *secondRegistView;
@property (nonatomic, strong) NSArray *resource;
@property (nonatomic, strong) QWPopoverView *stateView;
@property (strong, nonatomic) IBOutlet UIView *thirdRegistView;
@property (weak, nonatomic) IBOutlet QWTextField *passWord1Tf;


@property (strong, nonatomic) QWDeadtimeTimer *timer;

@property (nonatomic, copy, nullable) NSString *target_url;

@property  BOOL agreeAgreement;
@end

@implementation QWRegistPhoneVC

- (QWMyCenterLogic *)logic
{
    if (!_logic) {
        _logic = [QWMyCenterLogic logicWithOperationManager:self.operationManager];
    }
    
    return _logic;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.agreeAgreement = NO;
    self.fd_interactivePopDisabled = true;
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self configRegistView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange) name:UITextFieldTextDidChangeNotification object:_phoneTextField];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange) name:UITextFieldTextDidChangeNotification object:_verificationCodeTF];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    UIToolbar *keyboardDoneButtonView = [self createDoneButton];
    _phoneTextField.inputAccessoryView = keyboardDoneButtonView;
    _verificationCodeTF.inputAccessoryView = keyboardDoneButtonView;

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

    [_usernameTF setKeyboardType:UIKeyboardTypeDefault];
    [_passwordTF setKeyboardType:UIKeyboardTypeDefault];
    [_passWord1Tf setKeyboardType:UIKeyboardTypeDefault];
    [_verifyPasswordTF setKeyboardType:UIKeyboardTypeDefault];
    
    _passwordTF.secureTextEntry = true;
    _passWord1Tf.secureTextEntry = true;
    _verifyPasswordTF.secureTextEntry = true;
    
    [self.view addGestureRecognizer:tap];
    self.timer = [QWDeadtimeTimer new];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = true;
}

- (void)configRegistView {
    [self.view addSubview:_firstRegistView];
    _firstRegistView.translatesAutoresizingMaskIntoConstraints = NO;
    [_firstRegistView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view withOffset:144];
    [_firstRegistView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view withOffset:12];
    [_firstRegistView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view withOffset:-12];
    [_firstRegistView autoSetDimension:ALDimensionHeight toSize:277];
    
    [self createAgreementBtn];
    
    [self.view addSubview:_secondRegistView];
    _secondRegistView.translatesAutoresizingMaskIntoConstraints = NO;
    [_secondRegistView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view withOffset:144];
    [_secondRegistView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view withOffset:12];
    [_secondRegistView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view withOffset:-12];
    [_secondRegistView autoSetDimension:ALDimensionHeight toSize:277];
    _secondRegistView.hidden = true;
    
    [self.view addSubview:_thirdRegistView];
    [_thirdRegistView autoCenterInSuperview];
    [_thirdRegistView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view withOffset:12];
    [_thirdRegistView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view withOffset:-12];
    [_thirdRegistView autoSetDimension:ALDimensionHeight toSize:188];
    _thirdRegistView.hidden = true;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - firstView

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
        CGFloat x = self.stateBtn.center.x + self.firstRegistView.mj_x;
        CGFloat y = self.firstRegistView.mj_y + self.stateBtn.mj_y + self.stateBtn.mj_h;
        _stateView = [[QWPopoverView alloc] initWithPoint:CGPointMake(x, y) titles:self.resource size:CGSizeMake(self.stateBtn.mj_w, self.firstRegistView.frame.size.height - self.stateBtn.mj_h - self.stateBtn.mj_y)];
    }
    return _stateView;
}


- (IBAction)onPressedStateBtn:(id)sender {
    [self.stateView show];
    WEAK_SELF;
    self.stateView.selectRowAtIndex = ^(NSInteger index) {
        STRONG_SELF;
        NSDictionary *dic = [self.resource objectAtIndex:index];
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
    [self.logic sendVerificationCodeToPhone:[self acquirePhone] registe:QWVerificationTypeRegiste andCompleteBlock:^(id aResponseObject, NSError *anError) {
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
    if (!self.passWord1Tf.text.length) {
        [self showToastWithTitle:@"密码不能为空" subtitle:nil type:ToastTypeError];
        return ;
    }
    
    if (self.passWord1Tf.text.length < 2) {
        [self showToastWithTitle:@"密码不能小于2位" subtitle:nil type:ToastTypeError];
        return ;
    }
    
    if (self.passWord1Tf.text.length > 24) {
        [self showToastWithTitle:@"密码不能大于24位" subtitle:nil type:ToastTypeError];
        return ;
    }
    if (self.agreeAgreement == NO) {
        [self showToastWithTitle:@"您必须同意《隐私权政策》和《用户注册协议》才可注册" subtitle:nil type:ToastTypeError];
        return ;
    }
    [self showLoading];
    [self endTextEditing];
    WEAK_SELF;
    [self.logic registWithName:[self acquirePhone] password:self.passWord1Tf.text code:self.verificationCodeTF.text username:@"" invite:@"" andCompleteBlock:^(id aResponseObject, NSError *anError) {
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
                UserVO *user = [UserVO voWithDict:aResponseObject];
                [QWGlobalValue sharedInstance].user = user;
                [[QWGlobalValue sharedInstance] save];
                
                [QWKeychain setKeychainValue:[self acquirePhone] forType:@"phone"];
                self.secondRegistView.hidden = YES;
                self.firstRegistView.hidden = true;
                self.thirdRegistView.hidden = false;
                
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }
        
        [self hideLoading];
        
    }];
//    [self.logic checkCodeWithPhone:[self acquirePhone] code:self.verificationCodeTF.text registe:YES andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
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
//                self.firstRegistView.hidden = true;
//                self.secondRegistView.hidden = false;
//            }
//        }
//        else {
//            [self showToastWithTitle:anError.description subtitle:nil type:ToastTypeError];
//        }
//        [self hideLoading];
//    }];

    
}

- (NSString *)acquirePhone {
    NSString *phone = self.phoneTextField.text;
    NSString *state = @"";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d+" options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:self.stateBtn.currentTitle options:0 range:NSMakeRange(0, self.stateBtn.currentTitle.length)];
    if (match) {
        state = [NSString stringWithFormat:@"+%@",[self.stateBtn.currentTitle substringWithRange:match.range]];
    }
    if ( ! [state isEqualToString:@"+86"]) {
        phone = [NSString stringWithFormat:@"%@%@", state, self.phoneTextField.text];
    }
    else if ( [state isEqualToString:@"+86"]){
        phone = [NSString stringWithFormat:@"%@", self.phoneTextField.text];
    }
    return phone;
}

-(void)createAgreementBtn{
    CGFloat width = [QWSize autoWidth:@"同意《隐私权政策》和《用户注册协议》" width:500 height:15 num:12];
    CGFloat labWidth = [QWSize autoWidth:@"同意" width:500 height:15 num:12];
    CGFloat btn1Width = [QWSize autoWidth:@"《隐私权政策》" width:500 height:15 num:12];
    CGFloat lab2Width = [QWSize autoWidth:@"和" width:500 height:15 num:12];
    CGFloat btn2Width = [QWSize autoWidth:@"《用户注册协议》" width:500 height:15 num:12];
//    chapter_unchoice chapter_choice
    
    UIButton *choiceBtn = [UIButton new];
    choiceBtn.frame = CGRectMake((UISCREEN_WIDTH-width)/2 - 10 - 15, kMaxY(self.passwordTF.frame)+25, 15, 15);
    [choiceBtn setImage:[UIImage imageNamed:@"chapter_unchoice"] forState:UIControlStateNormal];
    [choiceBtn setImage:[UIImage imageNamed:@"chapter_choice"] forState:UIControlStateSelected];
    [choiceBtn addTarget:self action:@selector(choiceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_firstRegistView addSubview:choiceBtn];
    UILabel *agreementLab = [UILabel new];
    agreementLab.frame = CGRectMake((UISCREEN_WIDTH-width)/2, kMaxY(self.passwordTF.frame)+25, labWidth, 15);
    agreementLab.text = @"同意";
    [_firstRegistView addSubview:agreementLab];
    agreementLab.textColor = HRGB(0x888888);
    agreementLab.textAlignment = 1;
    agreementLab.font = FONT(12);
    
    UIButton *btn = [UIButton new];
    btn.frame = CGRectMake(kMaxX(agreementLab.frame), kMaxY(self.passwordTF.frame)+25, btn1Width, 15);
    [_firstRegistView addSubview:btn];
    [btn bk_tapped:^{
            self.navigationController.navigationBar.hidden = false;
        [[QWRouter sharedInstance] routerWithUrl:[NSURL URLWithString:@"https://www.iqing.com/info/#/privacy"]];
        
        
    }];
    [btn setTitle:@"《隐私权政策》" forState:0];
    [btn setTitleColor:QWPINK forState:0];
    btn.titleLabel.font = FONT(12);
    btn.titleLabel.textAlignment = 1;
    
    UILabel *andLab = [UILabel new];
    andLab.frame = CGRectMake(kMaxX(btn.frame), kMaxY(self.passwordTF.frame)+25, lab2Width, 15);
    andLab.text = @"和";
    [_firstRegistView addSubview:andLab];
    andLab.textColor = HRGB(0x888888);
    andLab.textAlignment = 1;
    andLab.font = FONT(12);
    
    UIButton *btn2 = [UIButton new];
    btn2.frame = CGRectMake(kMaxX(andLab.frame), kMaxY(self.passwordTF.frame)+25, btn2Width, 15);
    [_firstRegistView addSubview:btn2];
    [btn2 bk_tapped:^{
        self.navigationController.navigationBar.hidden = false;
        [[QWRouter sharedInstance] routerWithUrl:[NSURL URLWithString:@"https://www.iqing.com/info/#/registration"]];
    }];
    [btn2 setTitle:@"《用户注册协议》" forState:0];
    [btn2 setTitleColor:QWPINK forState:0];
    btn2.titleLabel.font = FONT(12);
    btn2.titleLabel.textAlignment = 1;
    
    
}
- (void)choiceBtnClick:(UIButton *)button {
    button.selected = !button.selected;
    self.agreeAgreement = !self.agreeAgreement;
}
#pragma mark - secondedView

- (IBAction)onPressedBackBtn:(id)sender {
    self.secondRegistView.hidden = true;
    self.firstRegistView.hidden = false;
}


- (IBAction)onPressedRegistBtn:(id)sender {

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
    
    [self endTextEditing];
    
    WEAK_SELF;
    [self showLoading];
    [self.logic registWithName:[self acquirePhone] password:self.passwordTF.text code:self.verificationCodeTF.text username:self.usernameTF.text invite:@"" andCompleteBlock:^(id aResponseObject, NSError *anError) {
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
                UserVO *user = [UserVO voWithDict:aResponseObject];
                [QWGlobalValue sharedInstance].user = user;
                [[QWGlobalValue sharedInstance] save];
                
                [QWKeychain setKeychainValue:[self acquirePhone] forType:@"phone"];
                self.secondRegistView.hidden = YES;
                self.thirdRegistView.hidden = false;
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }
        
        [self hideLoading];
        
    }];
}

- (BOOL)containEmoji:(NSString *)string {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *result = [regex firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    if (result) {
        [self showToastWithTitle:@"昵称禁止输入emoji" subtitle:nil type:ToastTypeAlert];
    }
    return result != nil;
}


- (void)leftBtnClicked:(id)sender {
    [self dismissViewControllerAnimated:false completion:nil];
}

#pragma mark - thirdView

- (IBAction)onPressedCconfirmBtn:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_STATE_CHANGED object:nil];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        if (self.target_url.length) {
            [[QWRouter sharedInstance] routerWithUrlString:self.target_url];
        }
    }];
}

#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    

}

- (IBAction)unwindToRegistPhoneVC:(UIStoryboardSegue *)sender
{
    QWChangeStateTVC *vc = sender.sourceViewController;
//    self.stateLabel.text = [NSString stringWithFormat:@"+%@",vc.selectedState];
    [self.stateBtn setTitle:[NSString stringWithFormat:@"%@（+%@）",vc.selectedState,vc.selectedName] forState:UIControlStateNormal];
}

-(void)dismissKeyboard {
    END_EDITING;
}

#pragma mark UITextFieldDeletage
//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification {
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    float keyboardHeight = keyboardRect.origin.y;
    _spacingWithKeyboardAndCursor =  _cursorHeight - keyboardHeight;
    if (_spacingWithKeyboardAndCursor > 0) {
        if(_firstRegistView.hidden == false){
            [_firstRegistView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view withOffset:144-_spacingWithKeyboardAndCursor-15];
        }else{
            [_secondRegistView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view withOffset:144-_spacingWithKeyboardAndCursor-15];
        }
        [self.view updateConstraintsIfNeeded];
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }
}
//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification {
    if (_spacingWithKeyboardAndCursor > 0) {
        //[self.view removeConstraint:_firstRegistView.constraints[0]];
        //NSLog(@"单精度浮点数： %ld",(long)_firstRegistView.superview.constraints.firstObject.firstAttribute);
        for (NSLayoutConstraint *constraint in self.view.constraints) {
            if (constraint.firstAttribute == NSLayoutAttributeTop || constraint.secondAttribute == NSLayoutAttributeTop) {
                if([constraint.firstItem isEqual:(_firstRegistView)]){
                    constraint.constant = 144;
                }else if([constraint.firstItem isEqual:(_secondRegistView)]){
                    constraint.constant = 144;
                }
            }
        }
        [self.view updateConstraintsIfNeeded];
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
        CGPoint point = [textField.superview convertPoint:textField.center toView:self.view];
        _cursorHeight = point.y;//CGRectGetMaxY();
    return YES;
}


- (void)textFieldTextDidChange
{
    if(_phoneTextField.text.length){
        [self.registPhoneBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_12"] forState:UIControlStateNormal];
    }else {
        [self.registPhoneBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_10"] forState:UIControlStateNormal];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.phoneTextField.text.length) {
        return YES;
    }
    else {
        [self showToastWithTitle:@"手机号不能为空" subtitle:nil type:ToastTypeError];
        return NO;
    }
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

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.timer stop];
}
@end
