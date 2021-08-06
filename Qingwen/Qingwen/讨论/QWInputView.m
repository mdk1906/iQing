//
//  QWInputView.m
//  Qingwen
//
//  Created by Aimy on 8/13/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWInputView.h"

@interface QWInputView () <QWExpressionViewDelegate>

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *heightConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *bgViewConstraint;
@property (nonatomic, strong) IBOutlet UIView *bgView;
@property (nonatomic, strong) IBOutlet UIButton *sendBtn;
@property (nonatomic, strong) IBOutlet UIButton *expressionBtn;
@property (nonatomic, strong) IBOutlet UIButton *imageBtn;

@property (strong, nonatomic) QWExpressionView *expressionInputView;

@property (nonatomic) NSInteger defaultheight;

@end

@implementation QWInputView

- (void)setLogic:(QWDiscussLogic *)logic
{
    self.imageInputView.logic = logic;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.defaultheight = 81;
    self.bgViewConstraint.constant = 0;

    self.expressionInputView = [QWExpressionView createWithNib];
    self.expressionInputView.delegate = self;
    self.expressionInputView.frame = CGRectMake(0, 0, self.contentTV.bounds.size.width, 240);
    [self.bgView addSubview:self.expressionInputView];
    [self.expressionInputView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.bgView];
    [self.expressionInputView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.bgView];
    [self.expressionInputView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.bgView];
    [self.expressionInputView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.bgView];
    self.expressionInputView.hidden = YES;

    self.imageInputView = [QWAddImageView createWithNib];
    self.imageInputView.frame = CGRectMake(0, 0, self.contentTV.bounds.size.width, 195);
    [self.bgView addSubview:self.imageInputView];
    [self.imageInputView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.bgView];
    [self.imageInputView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.bgView];
    [self.imageInputView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.bgView];
    [self.imageInputView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.bgView];
    self.imageInputView.hidden = YES;

    self.contentTV.placeholderColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0980392 alpha:0.22];
    self.contentTV.scrollsToTop = NO;
    self.contentTV.layer.cornerRadius = 5.f;
    self.contentTV.layer.borderColor = HRGB(0xaeaeae).CGColor;
    self.contentTV.layer.borderWidth = PX1_LINE;

    WEAK_SELF;
    [self observeNotification:UIKeyboardWillShowNotification fromObject:nil withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }

        KVO_STRONG_SELF;
        if (!kvoSelf.contentTV.isFirstResponder) {
            return ;
        }
        NSDictionary *info = [notification userInfo];
        NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGSize keyboardSize = [value CGRectValue].size;
        if (@available(iOS 11.0, *)) {
            kvoSelf.bottomConstraint.constant = -keyboardSize.height+kvoSelf.superview.safeAreaInsets.bottom;
        }else{
            kvoSelf.bottomConstraint.constant = -keyboardSize.height;
        }
        
        
        kvoSelf.contentTV.contentSize = kvoSelf.contentTV.contentSize;

        kvoSelf.bgViewConstraint.constant = 0;
        CGSize size = kvoSelf.contentTV.contentSize;
        if (size.height > 100) {
            size.height = 100;
        }

        if (size.height < 30) {
            size.height = 30;
        }
        kvoSelf.heightConstraint.constant = kvoSelf.defaultheight + size.height - 30;
        kvoSelf.imageBtn.selected = NO;
        kvoSelf.imageInputView.hidden = YES;
        kvoSelf.expressionBtn.selected = NO;
        kvoSelf.expressionInputView.hidden = YES;

        NSNumber *during = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        [UIView animateWithDuration:during.doubleValue animations:^{
            KVO_STRONG_SELF;
            [kvoSelf.superview layoutIfNeeded];
        }];
    }];

    [self observeNotification:UIKeyboardWillHideNotification fromObject:nil withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }

        KVO_STRONG_SELF;
        if (!kvoSelf.contentTV.isFirstResponder) {
            return ;
        }
        kvoSelf.bottomConstraint.constant = 0.f;
        [kvoSelf resetHeight];
        NSDictionary *info = [notification userInfo];
        NSNumber *during = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        [UIView animateWithDuration:during.doubleValue animations:^{
            KVO_STRONG_SELF;
            [kvoSelf.superview layoutIfNeeded];
        }];
    }];

    [self observeNotification:UIApplicationWillChangeStatusBarOrientationNotification withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }

        KVO_STRONG_SELF;
        if (kvoSelf.contentTV.isFirstResponder) {
            [kvoSelf.contentTV resignFirstResponder];
        }

        kvoSelf.bottomConstraint.constant = 0.f;
        [kvoSelf resetInputView];

    }];

    [self observeObject:self.contentTV property:@"contentSize" withBlock:^(__weak id self, __weak id object, id old, id newVal) {
        KVO_STRONG_SELF;
        if (!kvoSelf.window) {
            return ;
        }
        CGSize size = kvoSelf.contentTV.contentSize;
        if (size.height > 100) {
            size.height = 100;
        }

        if (size.height < 30) {
            size.height = 30;
        }

        kvoSelf.heightConstraint.constant = size.height + kvoSelf.defaultheight - 30;
        if (kvoSelf.imageBtn.selected) {
            kvoSelf.heightConstraint.constant += 195;
        }

        if (kvoSelf.expressionBtn.selected) {
            kvoSelf.heightConstraint.constant += 240;
        }

        [UIView animateWithDuration:.3f animations:^{
            STRONG_SELF;
            [self.superview layoutIfNeeded];
        }];
    }];
}

- (void)resetHeight
{
    WEAK_SELF;
    self.heightConstraint.constant = self.defaultheight;
    [UIView animateWithDuration:.3f animations:^{
        STRONG_SELF;
        [self.superview layoutIfNeeded];
    }];
}

- (void)resetInputView
{
    if (!self.expressionBtn.selected && !self.imageBtn.selected) {
        return ;
    }

    if (!self.window) {
        return;
    }
    
    CGSize size = self.contentTV.contentSize;
    if (size.height > 100) {
        size.height = 100;
    }

    if (size.height < 30) {
        size.height = 30;
    }

    self.expressionBtn.selected = NO;
    self.imageBtn.selected = NO;
    self.expressionInputView.hidden = YES;
    self.imageInputView.hidden = YES;
    self.bgViewConstraint.constant = 0;
    [self.expressionInputView.collectionView reloadData];
    self.heightConstraint.constant = self.defaultheight + size.height - 30;
}

- (void)dealloc
{
    [self removeAllObservationsOfObject:self.contentTV];
}

- (IBAction)onPressedSendBtn:(id)sender {
    if (![QWBindingValue sharedInstance].isBindPhone) {
        UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"" message:@"应国家相关法律法规规定，您必须绑定手机号码后方可发表评论。"];
        [alert bk_addButtonWithTitle:@"取消" handler:^{
            
        }];
        [alert bk_addButtonWithTitle:@"确定" handler:^{
            NSDictionary *param = @{@"bind_phone":[NSNumber numberWithInt:1]};
            [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"myself" andParams:param]];
        }];
        [alert show];
    }
    else{
        [self.delegate inputView:self onPressedSendBtn:sender];
    }
    
}

- (IBAction)onPressedAddBookBtn:(id)sender {
    [self.delegate inputView:self onPressedAddBookBtn:sender];
}

- (IBAction)onPressedAddAtBtn:(id)sender {
    if (![QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        return;
    }
    [self.delegate inputView:self onPressedAddAtBtn:sender];
}

- (IBAction)onPressedAddExpressionBtn:(id)sender {
    [self.contentTV resignFirstResponder];
    self.imageBtn.selected = NO;

    CGSize size = self.contentTV.contentSize;
    if (size.height > 100) {
        size.height = 100;
    }

    if (size.height < 30) {
        size.height = 30;
    }

    if (IOS_SDK_LESS_THAN(8.0)) {
        self.expressionInputView.collectionView.backgroundColor = HRGB(0xFAFAFA);
    }

    if (self.expressionBtn.selected) {
        self.expressionBtn.selected = NO;
        self.bgViewConstraint.constant = 0;
        self.heightConstraint.constant = self.defaultheight + size.height - 30;
        [self.contentTV becomeFirstResponder];
    }
    else {
        [self.expressionInputView.collectionView reloadData];
        self.expressionBtn.selected = YES;
        self.bgViewConstraint.constant = 240;
        self.heightConstraint.constant = 240 + self.defaultheight + size.height - 30;
    }

    self.expressionInputView.hidden = !self.expressionBtn.selected;
    self.imageInputView.hidden = YES;
}

- (IBAction)onPressedAddImageBtn:(id)sender {
    [self.contentTV resignFirstResponder];
    self.expressionBtn.selected = NO;

    CGSize size = self.contentTV.contentSize;
    if (size.height > 100) {
        size.height = 100;
    }

    if (size.height < 30) {
        size.height = 30;
    }

    if (IOS_SDK_LESS_THAN(8.0)) {
        self.imageInputView.collectionView.backgroundColor = HRGB(0xFAFAFA);
    }

    if (self.imageBtn.selected) {
        self.imageBtn.selected = NO;
        self.bgViewConstraint.constant = 0;
        self.heightConstraint.constant = self.defaultheight + size.height - 30;
        [self.contentTV becomeFirstResponder];
    }
    else {
        self.imageBtn.selected = YES;
        self.bgViewConstraint.constant = 195;
        self.heightConstraint.constant = 195 + self.defaultheight + size.height - 30;
    }

    self.imageInputView.hidden = !self.imageBtn.selected;
    self.expressionInputView.hidden = YES;
}

- (void)expressionView:(QWExpressionView *)view didSelectedExpression:(NSString *)expression
{
    self.contentTV.text = [NSString stringWithFormat:@"%@ [%@] ", self.contentTV.text, expression];
    [self textViewDidChange:self.contentTV];
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.sendBtn.enabled = textView.text.length > 0;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (!text.length) {
        return YES;
    }

    if (textView == self.contentTV && self.contentTV.text.length >= 1024) {
        return NO;
    }

    return YES;
}

@end
