//
//  QWLoginVC.m
//  Qingwen
//
//  Created by Aimy on 7/2/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWLoginVC.h"

#import "QWMyCenterLogic.h"
#import "QWRegistVC.h"
#import <OnePasswordExtension.h>
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "WeiboSDK.h"
#import "QWShareManager.h"
#import "QWChangeStateTVC.h"
#import "QWAnnouncementView.h"
@interface QWLoginVC () <UITextFieldDelegate, QWWXLoginDelegate, QWQQLoginDelegate, QWWBLoginDelegate>

@property (nonatomic, strong) IBOutlet UIButton *registBtn;
@property (nonatomic, strong) IBOutlet UIButton *loginBtn;
@property (nonatomic, strong) IBOutlet UITextField *phoneTF;
@property (nonatomic, strong) IBOutlet UITextField *passwordTF;
@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIButton *forgetPasswordBtn;
@property (nonatomic, strong) IBOutlet UIButton *onepasswordSigninButton;
@property (nonatomic, strong) IBOutlet UIButton *showPasswordBtn;
@property (nonatomic, strong) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIButton *vistorLoginBtn;

@property (nonatomic, strong) QWMyCenterLogic *logic;

@property (nonatomic, copy, nullable) NSString *target_url;
@property (nonatomic, strong) IBOutlet UIView *thirdLoginView;
@property (nonatomic, strong) QWPopoverView *stateView;
@property (nonatomic, strong) NSArray *resource;

@property (weak, nonatomic) IBOutlet UIView *qqLoginView;

@property (weak, nonatomic) IBOutlet UIView *wxLoginView;
@property (weak, nonatomic) IBOutlet UIView *wbLoginView;

@end

@implementation QWLoginVC

+ (void)load
{
    QWMappingVO *vo = [QWMappingVO new];
    vo.className = [NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject;
    vo.storyboardName = @"QWLogin";
    vo.storyboardID = @"login";
    vo.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vo.model = YES;
    
    [[QWRouter sharedInstance] registerRouterVO:vo withKey:@"login"];
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self resize:CGSizeMake(UISCREEN_WIDTH, UISCREEN_HEIGHT)];
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"忘记密码? " attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: HRGB(0x16719e), NSUnderlineStyleAttributeName: @1}];
    [self.forgetPasswordBtn setAttributedTitle:title forState:UIControlStateNormal];
}

- (void)resize:(CGSize)size
{
    CGRect frame = self.contentView.frame;
    frame.size.width = size.width;
    [self.contentView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view withOffset:70];
    [self.contentView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view withOffset:12];
    [self.contentView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view withOffset:-12];
    [self.contentView autoSetDimension:ALDimensionHeight toSize:frame.size.height relation:NSLayoutRelationEqual];
    
    if (ISIPHONE3_5) {
        self.scrollView.contentSize = CGSizeMake(size.width, size.height + self.contentView.bounds.size.height - 200);
    }
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
        //获取stateLabelRect 里面的位置
        CGPoint point = CGPointMake(72, 165);
        _stateView = [[QWPopoverView alloc] initWithPoint:point titles:self.resource size:CGSizeMake(120, 250)];
    }
    return _stateView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    [self.onepasswordSigninButton setBackgroundImage:[[UIImage imageNamed:@"1password"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.onepasswordSigninButton.tintColor = QWPINK;
    [self.onepasswordSigninButton setHidden:![[OnePasswordExtension sharedExtension] isAppExtensionAvailable]];

    if ([self.navigationController.extraData objectForCaseInsensitiveKey:@"target_url"]) {
        self.target_url = [self.navigationController.extraData objectForCaseInsensitiveKey:@"target_url"];
    }

    [self.view addSubview:self.contentView];

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_left"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBtnClicked:)];
    self.navigationItem.leftBarButtonItem = item;

    NSString *phone = [QWKeychain getKeychainValueForType:@"phone"];
    NSString *state = [QWKeychain getKeychainValueForType:@"state"];
    if (phone.length) {
        self.phoneTF.text = phone;
    }
    if (state.length) {
        self.stateLabel.text = state;
    }
    WEAK_SELF;
    self.stateView.selectRowAtIndex = ^(NSInteger index) {
        STRONG_SELF;
        NSDictionary *dic = [self.resource objectAtIndex:index];
        self.stateLabel.text = [NSString stringWithFormat:@"+%@",dic[@"code"]];
    };
    
    
        self.vistorLoginBtn.hidden = NO;
    
    
    [self createAgreementBtn];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = true;
    if ([WXApi isWXAppInstalled]) {
        self.wxLoginView.hidden = false;
    }else {
        self.wxLoginView.hidden = true;
    }
    
    if ([QQApiInterface isQQInstalled]) {
        self.qqLoginView.hidden = false;
    }else {
        self.qqLoginView.hidden = true;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString *phone = [QWKeychain getKeychainValueForType:@"phone"];
    if (phone.length) {
        [self.passwordTF becomeFirstResponder];
        self.showPasswordBtn.userInteractionEnabled = true;
    }
    else {
    }
}
-(void)createAgreementBtn{
    CGFloat width = [QWSize autoWidth:@"使用即为同意《隐私权政策》和《用户注册协议》" width:500 height:15 num:12];
    CGFloat labWidth = [QWSize autoWidth:@"使用即为同意" width:500 height:15 num:12];
    CGFloat btn1Width = [QWSize autoWidth:@"《隐私权政策》" width:500 height:15 num:12];
    CGFloat lab2Width = [QWSize autoWidth:@"和" width:500 height:15 num:12];
    CGFloat btn2Width = [QWSize autoWidth:@"《用户注册协议》" width:500 height:15 num:12];
    UILabel *agreementLab = [UILabel new];
    agreementLab.frame = CGRectMake((UISCREEN_WIDTH-width)/2, kMaxY(self.vistorLoginBtn.frame)+15, labWidth, 15);
    agreementLab.text = @"使用即为同意";
    [_contentView addSubview:agreementLab];
    agreementLab.textColor = HRGB(0x888888);
    agreementLab.textAlignment = 1;
    agreementLab.font = FONT(12);
    
    UIButton *btn = [UIButton new];
    btn.frame = CGRectMake(kMaxX(agreementLab.frame), kMaxY(self.vistorLoginBtn.frame)+15, btn1Width, 15);
    [_contentView addSubview:btn];
    [btn bk_tapped:^{
        self.navigationController.navigationBar.hidden = false;
        [[QWRouter sharedInstance] routerWithUrl:[NSURL URLWithString:@"https://www.iqing.com/info/#/privacy"]];
    }];
    [btn setTitle:@"《隐私权政策》" forState:0];
    [btn setTitleColor:QWPINK forState:0];
    btn.titleLabel.font = FONT(12);
    btn.titleLabel.textAlignment = 1;
    
    UILabel *andLab = [UILabel new];
    andLab.frame = CGRectMake(kMaxX(btn.frame), kMaxY(self.vistorLoginBtn.frame)+15, lab2Width, 15);
    andLab.text = @"和";
    [_contentView addSubview:andLab];
    andLab.textColor = HRGB(0x888888);
    andLab.textAlignment = 1;
    andLab.font = FONT(12);
    
    UIButton *btn2 = [UIButton new];
    btn2.frame = CGRectMake(kMaxX(andLab.frame), kMaxY(self.vistorLoginBtn.frame)+15, btn2Width, 15);
    [_contentView addSubview:btn2];
    [btn2 bk_tapped:^{
        self.navigationController.navigationBar.hidden = false;
        [[QWRouter sharedInstance] routerWithUrl:[NSURL URLWithString:@"https://www.iqing.com/info/#/registration"]];
    }];
    [btn2 setTitle:@"《用户注册协议》" forState:0];
    [btn2 setTitleColor:QWPINK forState:0];
    btn2.titleLabel.font = FONT(12);
    btn2.titleLabel.textAlignment = 1;
    
    
}
- (void)leftBtnClicked:(id)sender
{
    [self cancelAllOperations];
    [self.presentingViewController dismissViewControllerAnimated:false completion:nil];
}

- (IBAction)findLoginFrom1Password:(id)sender {
    [[OnePasswordExtension sharedExtension] findLoginForURLString:@"http://account.iqing.in" forViewController:self sender:sender completion:^(NSDictionary *loginDictionary, NSError *error) {
        if (loginDictionary.count == 0) {
            if (error.code != AppExtensionErrorCodeCancelledByUser) {
                NSLog(@"Error invoking 1Password App Extension for find login: %@", error);
            }
            return;
        }

        self.phoneTF.text = loginDictionary[AppExtensionUsernameKey];
        self.passwordTF.text = loginDictionary[AppExtensionPasswordKey];
        [self onPressedLoginBtn:nil];
    }];
}

- (QWMyCenterLogic *)logic
{
    if (!_logic) {
        _logic = [QWMyCenterLogic logicWithOperationManager:self.operationManager];
    }

    return _logic;
}

- (IBAction)onPrssedStateBtn:(id)sender {
    [self.stateView show];
}


- (IBAction)onPressedLoginBtn:(id)sender {
    if (!self.phoneTF.text.length) {
        [self showToastWithTitle:@"手机号不能为空" subtitle:nil type:ToastTypeError];
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

    NSString *phone = self.phoneTF.text;
    if (![self.stateLabel.text isEqualToString:@"+86"]) {
      phone = [[self.stateLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""] stringByAppendingString:phone];
    }
    WEAK_SELF;
    [self showLoading];
    [self.logic loginWithName:phone password:self.passwordTF.text andCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"data"];
                if (message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:@"登录失败" subtitle:nil type:ToastTypeError];
                }
            }
            else {
                [self saveGlobalValueWithAResponseObject:aResponseObject];
                [QWKeychain setKeychainValue:self.phoneTF.text forType:@"phone"];
                [QWKeychain setKeychainValue:self.stateLabel.text forType:@"state"];
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

- (void)saveGlobalValueWithAResponseObject:(NSDictionary *)aResponseObject {
    
    [QWGlobalValue sharedInstance].token = aResponseObject[@"token"];
    NSLog(@"token12345 = %@",[QWGlobalValue sharedInstance].token);
    [QWGlobalValue sharedInstance].username = aResponseObject[@"username"];
    [QWGlobalValue sharedInstance].nid = aResponseObject[@"id"];
    [QWGlobalValue sharedInstance].profile_url = aResponseObject[@"profile_url"];
    UserVO *user = [UserVO voWithDict:aResponseObject];
    [QWGlobalValue sharedInstance].user = user;
    [QWGlobalValue sharedInstance].channel_token = aResponseObject[@"channel_token"];
    
    if (aResponseObject[@"update_username"] != nil) {
        [QWGlobalValue sharedInstance].update_username = aResponseObject[@"update_username"];
    }
    else{
        [QWGlobalValue sharedInstance].update_username = 0;
    }
    [[QWGlobalValue sharedInstance] save];
    
    [[QWBindingValue sharedInstance] update];
    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_STATE_CHANGED object:nil];
}
- (IBAction)onPressedWXLoginBtn:(id)sender {
    [QWShareManager sharedInstance].wxLoginDelegate = self;
    [[QWShareManager sharedInstance] wxLogin];
}

- (IBAction)onPressedQQLoginBtn:(id)sender {
    [QWShareManager sharedInstance].qqLoginDelegate = self;
    if([QQApiInterface isQQInstalled]){
        [[QWShareManager sharedInstance] qqLogin];
    }else{
        [self showToastWithTitle:@"没有安装QQ应用" subtitle:nil type:ToastTypeAlert];
    }
    
}

- (IBAction)onPressedWBLoginBtn:(id)sender {
    [QWShareManager sharedInstance].wbLoginDelegate = self;
    [[QWShareManager sharedInstance] wbLogin];
}

- (IBAction)onPressedRegistBtn:(id)sender {
    if (self.logic.canRegistered == YES) {
        QWRegistVC *vc = [QWRegistVC createFromStoryboardWithStoryboardID:@"regist" storyboardName:@"QWLogin"];
        
        
        [[[QWRouter sharedInstance] topVC].navigationController pushViewController:vc animated:false];
    }
    else{
        [self endTextEditing];
        QWAnnouncementView *view = [[QWAnnouncementView alloc] initWithFrame2:CGRectMake(0, 0, UISCREEN_WIDTH, UISCREEN_HEIGHT)];
        [self.view addSubview:view];
        
    }
    
//    [self.presentingViewController dismissViewControllerAnimated:false completion:nil];

}
//游客登录
- (IBAction)onPressedVistorLoginBtn:(id)sender {
    [self showLoading];
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"uuid"] = [QWTracker sharedInstance].GUID;
    QWOperationParam *param = [QWInterface getWithDomainUrl:@"visitor/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject != nil) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"data"];
                if (message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:@"登录失败" subtitle:nil type:ToastTypeError];
                }
            }
            else {
                [QWGlobalValue sharedInstance].token = aResponseObject[@"token"];
                [QWGlobalValue sharedInstance].username = aResponseObject[@"username"];
                [QWGlobalValue sharedInstance].nid = aResponseObject[@"id"];
                [QWGlobalValue sharedInstance].profile_url = aResponseObject[@"profile_url"];
                UserVO *user = [UserVO voWithDict:aResponseObject];
                [QWGlobalValue sharedInstance].user = user;
                [QWGlobalValue sharedInstance].channel_token = aResponseObject[@"channel_token"];
                [[QWGlobalValue sharedInstance] save];
                
                [[QWBindingValue sharedInstance] update];
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_STATE_CHANGED object:nil];
                [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
                    if (self.target_url.length) {
                        [[QWRouter sharedInstance] routerWithUrlString:self.target_url];
                    }
                }];
                //                    [QWKeychain setKeychainValue:self.phoneTF.text forType:@"phone"];
                //                    [QWKeychain setKeychainValue:self.stateLabel.text forType:@"state"];
                
            }
        }
        else{
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }
        [self hideLoading];
    }];
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

#pragma mark - tf delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!string.length) {
        return YES;
    }

    if (textField == self.passwordTF && self.passwordTF.text.length >= 24) {
        return NO;
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.phoneTF) {
        if (self.phoneTF.text.length) {
            [self.passwordTF becomeFirstResponder];
            return YES;
        }
        else {
            [self showToastWithTitle:@"手机号不能为空" subtitle:nil type:ToastTypeError];
            return NO;
        }
    }

    if (textField == self.passwordTF) {
        if (self.passwordTF.text.length < 2) {
            [self showToastWithTitle:@"密码不能小于2位" subtitle:nil type:ToastTypeError];
            return NO;
        }

        if (self.passwordTF.text.length > 24) {
            [self showToastWithTitle:@"密码不能大于24位" subtitle:nil type:ToastTypeError];
            return NO;
        }

        [self onPressedLoginBtn:nil];
        return YES;
    }

    return NO;
}

- (IBAction)onPressedShownBtn:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    self.passwordTF.secureTextEntry = !sender.isSelected;
}

- (IBAction)unwindToLoginVC:(UIStoryboardSegue *)sender
{
    QWChangeStateTVC *vc = sender.sourceViewController;
    self.stateLabel.text = [NSString stringWithFormat:@"+%@",vc.selectedState];
}
#pragma mark -微信登录
- (void)loginWXSuccessWithCode:(NSString *)code {
    NSLog(@"%@",code);
    WEAK_SELF;
    [self showLoading];
    [self.logic registWithWXCode:code andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (!anError && aResponseObject) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"data"];
                if (message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:@"微信登录失败" subtitle:nil type:ToastTypeError];
                }
            }
            else {
                [self saveGlobalValueWithAResponseObject:aResponseObject];
                
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

#pragma mark - QQ登录 
-(void)loginQQSuccessWithJsonResponse:(NSDictionary *)jsonResponse {
    WEAK_SELF;
    [self showLoading];
    [self.logic registWithQQJsonResponse:jsonResponse andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (!anError && aResponseObject) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"data"];
                if (message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:@"QQ登录失败" subtitle:nil type:ToastTypeError];
                }
            }
            else {
                [self saveGlobalValueWithAResponseObject:aResponseObject];
                
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

#pragma mark - 微博登录
- (void)loginWBSuccessWithJsonResponse:(NSDictionary *)jsonResponse {
    WEAK_SELF;
    [self showLoading];
    [self.logic registWithWBJsonResponse:jsonResponse andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (!anError && aResponseObject) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"data"];
                if (message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:@"微博登录失败" subtitle:nil type:ToastTypeError];
                }
            }
            else {
                [self saveGlobalValueWithAResponseObject:aResponseObject];
                
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

@end
