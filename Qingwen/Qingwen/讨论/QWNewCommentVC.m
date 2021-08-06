//
//  QWNewCommentVC.m
//  Qingwen
//
//  Created by Aimy on 8/11/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWNewCommentVC.h"

#import "DiscussItemVO.h"
#import "QWDiscussLogic.h"
#import "QWInputView.h"
#import "QWCommentTVCell.h"
#import "QWTableView.h"
@interface QWNewCommentVC () <QWInputViewDelegate>

@property (strong, nonatomic) IBOutlet QWTableView *tableView;

@property (strong, nonatomic) QWInputView *contentInputView;

@property (nonatomic, strong) QWDiscussLogic *logic;

@end

@implementation QWNewCommentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.tableView registerNib:[UINib nibWithNibName:@"QWDiscussImageTVCell" bundle:nil] forCellReuseIdentifier:@"image"];

    self.contentInputView = [QWInputView createWithNib];
    [self.view addSubview:self.contentInputView];
    [self.contentInputView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
    [self.contentInputView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view];
    if (@available(iOS 11.0, *)) {
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = true;
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = true;
        self.contentInputView.bottomConstraint = [self.contentInputView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor];
        self.contentInputView.bottomConstraint.active = true;
    }else{
        self.contentInputView.bottomConstraint = [self.contentInputView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view];
    }
    self.contentInputView.delegate = self;
    [self.contentInputView setLogic:self.logic];

    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 88, 0);

    if (IOS_SDK_MORE_THAN(8.0)) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }

    self.title = [NSString stringWithFormat:@"%@楼", self.itemVO.order];
    self.tableView.emptyView.showError = YES;
}

- (QWDiscussLogic *)logic
{
    if (!_logic) {
        _logic = [QWDiscussLogic logicWithOperationManager:self.operationManager];
    }

    return _logic;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.contentInputView resetInputView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return [QWCommentTVCell heightForCellData:self.itemVO];
    }
    else {
        return [QWDiscussImageTVCell height1ForCellData:self.itemVO];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        QWCommentTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

        if (IOS_SDK_MORE_THAN(8.0)) {
            cell.layoutMargins = UIEdgeInsetsZero;
        }

        [cell updateWithCommentItemVO:self.itemVO];
        return cell;
    }
    else {
        QWDiscussImageTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"image" forIndexPath:indexPath];
        cell.collectionView.backgroundColor = HRGB(0xf8f8f8);
        if (IOS_SDK_MORE_THAN(8.0)) {
            cell.layoutMargins = UIEdgeInsetsZero;
        }

        [cell updateWithDiscussItemVO:self.itemVO];
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return YES;
    }

    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender
{
    if (action == NSSelectorFromString(@"copy:")) {
        return YES;
    }

    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender
{
    DiscussItemVO *itemVO = self.itemVO;
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    pb.string = itemVO.content;
}

- (void)inputView:(QWInputView *)inputView onPressedSendBtn:(id)sender {

    if (![QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        return;
    }

    if (!self.contentInputView.contentTV.text.length) {
        [self showToastWithTitle:@"评论不能为空" subtitle:nil type:ToastTypeError];
        return;
    }

    if (self.contentInputView.contentTV.text.length > 1024) {
        [self showToastWithTitle:@"内容不能大于1024个字符" subtitle:nil type:ToastTypeError];
        return;
    }

    if ([self.logic isPureExpression:self.contentInputView.contentTV.text]) {
        [self showToastWithTitle:@"别只有表情哦，再说两句吧！" subtitle:nil type:ToastTypeError];
        return;
    }

    if (self.contentInputView.imageInputView.isLoading) {
        [self showToastWithTitle:@"请等待图片上传完成" subtitle:nil type:ToastTypeError];
        return;
    }

    [self.contentInputView.contentTV resignFirstResponder];

    [self showLoading];
    [self.logic createCommentWithUrl:self.discussUrl content:self.contentInputView.contentTV.text refer:self.itemVO.order paths:self.contentInputView.imageInputView.imageUrls andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (anError == nil) {
            self.contentInputView.contentTV.text = nil;
            [self.inputView resetHeight];
            if (aResponseObject[@"code"]) {
                NSNumber *code = aResponseObject[@"code"];
                if ([code isEqualToNumber:@-1]) {
                    [self showToastWithTitle:@"发送失败" subtitle:nil type:ToastTypeError];
                }
                else {
                    NSString *message = aResponseObject[@"data"];
                    if (message.length) {
                        [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                    }
                    else {
                        [self showToastWithTitle:@"发送失败" subtitle:nil type:ToastTypeError];
                    }
                }
            }
            else {
                [self.contentInputView.imageInputView clear];
                [self.contentInputView resetInputView];
                self.contentInputView.contentTV.text = nil;
                [self showToastWithTitle:@"发表评论成功" subtitle:nil type:ToastTypeNormal];
                [self performSegueWithIdentifier:@"refreshcomment" sender:self];
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }

        [self hideLoading];
    }];
}

- (void)inputView:(QWInputView *)inputView onPressedAddBookBtn:(id)sender {
    WEAK_SELF;
    [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"search" andParams:@{@"searchbookname": @1}] callbackBlock:^id(NSDictionary *params) {
        __strong typeof(weakSelf)self = weakSelf;
        NSString *book_name = params[@"book_name"];
        self.contentInputView.contentTV.text = [NSString stringWithFormat:@"%@ 《%@》 ", self.contentInputView.contentTV.text, book_name];
        return nil;
    }];
}

- (void)inputView:(QWInputView *)inputView onPressedAddAtBtn:(id)sender{
    WEAK_SELF;
    [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"myattention" andParams:@{@"searchusername": @1}] callbackBlock:^id(NSDictionary *params) {
        __strong typeof(weakSelf)self = weakSelf;
        NSString *nickname = params[@"nickname"];
        self.contentInputView.contentTV.text = [NSString stringWithFormat:@"%@ @%@ ", self.contentInputView.contentTV.text, nickname];
        return nil;
    }];
}

@end
