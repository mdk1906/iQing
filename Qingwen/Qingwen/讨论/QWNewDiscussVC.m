//
//  QWNewDiscussVC.m
//  Qingwen
//
//  Created by Aimy on 8/11/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWNewDiscussVC.h"

#import "QWDiscussLogic.h"
#import "QWInputView.h"

@interface QWNewDiscussVC () <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *contentTV;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentTVHeightConstraint;
@property (strong, nonatomic) IBOutlet QWInputView *contentInputView;
@property (nonatomic, strong) QWDiscussLogic *logic;

@end

@implementation QWNewDiscussVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.contentTV.textContainerInset = UIEdgeInsetsMake(4, 4, 4, 4);

    WEAK_SELF;
    [self observeNotification:UIKeyboardWillShowNotification fromObject:nil withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }

        KVO_STRONG_SELF;
        NSDictionary *info = [notification userInfo];
        NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGSize keyboardSize = [value CGRectValue].size;
        kvoSelf.contentTVHeightConstraint.constant = -(keyboardSize.height);

        NSNumber *during = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        [UIView animateWithDuration:during.doubleValue animations:^{
            KVO_STRONG_SELF;
            [kvoSelf.view layoutIfNeeded];
        }];
    }];

    [self observeNotification:UIKeyboardWillHideNotification fromObject:nil withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }

        KVO_STRONG_SELF;
        kvoSelf.contentTVHeightConstraint.constant = 0.f;

        NSDictionary *info = [notification userInfo];
        NSNumber *during = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        [UIView animateWithDuration:during.doubleValue animations:^{
            KVO_STRONG_SELF;
            [kvoSelf.view layoutIfNeeded];
        }];
    }];
}

- (QWDiscussLogic *)logic
{
    if (!_logic) {
        _logic = [QWDiscussLogic logicWithOperationManager:self.operationManager];
    }

    return _logic;
}

- (IBAction)onPressedSendBtn:(id)sender {
    [self.contentTV resignFirstResponder];
    [self.contentTV setContentOffset:CGPointMake(0, -self.contentTV.contentInset.top) animated:YES];

    if (!self.contentTV.text.length) {
        [self showToastWithTitle:@"内容不能为空" subtitle:nil type:ToastTypeError];
        return;
    }

    if (!self.contentTV.text.length) {
        [self showToastWithTitle:@"内容不能大于1024个字符" subtitle:nil type:ToastTypeError];
        return;
    }

    [self showLoading];
    [self.logic createDiscussWithUrl:self.discussUrl content:self.contentTV.text paths:@[] andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (anError == nil) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"data"];
                if (message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:@"发帖失败" subtitle:nil type:ToastTypeError];
                }
            }
            else {
                [self showToastWithTitle:@"发帖成功" subtitle:nil type:ToastTypeNormal];
                [self performSegueWithIdentifier:@"refreshdiscuss" sender:self];
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }

        [self hideLoading];
    }];
}

- (IBAction)onPressedAddBookBtn:(id)sender {
    WEAK_SELF;
    [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"search" andParams:@{@"searchbookname": @1}] callbackBlock:^id(NSDictionary *params) {
        __strong typeof(weakSelf)self = weakSelf;
        NSString *book_name = params[@"book_name"];
        self.contentInputView.contentTV.text = [NSString stringWithFormat:@"%@ 《%@》 ", self.contentInputView.contentTV.text, book_name];
        return nil;
    }];
}

- (IBAction)onPressedAddAtBtn:(id)sender {
    WEAK_SELF;
    [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"myattention" andParams:@{@"searchusername": @1}] callbackBlock:^id(NSDictionary *params) {
        __strong typeof(weakSelf)self = weakSelf;
        NSString *nickname = params[@"nickname"];
        self.contentInputView.contentTV.text = [NSString stringWithFormat:@"%@ @%@ ", self.contentInputView.contentTV.text, nickname];
        return nil;
    }];
}

@end
