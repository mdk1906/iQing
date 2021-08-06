//
//  QWDiscussTVC.m
//  Qingwen
//
//  Created by Aimy on 8/11/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWDiscussTVC.h"

#import "QWDiscussTVCell.h"
#import "QWDiscussLogic.h"
#import "QWTableView.h"
#import "QWCommentTVC.h"
#import "QWNewDiscussVC.h"
#import "UITableView+loadingMore.h"
#import <MJRefresh.h>
#import <JSBadgeView.h>
#import "QWDetailTVC.h"
#import "QWInputView.h"
#import "QWVCAnimation.h"
#import "QWGameDetailVC.h"
#import "QWReadingPVC.h"
#import "QWSearchTVC.h"

@interface QWDiscussTVC () <UITableViewDelegate, UITableViewDataSource, QWInputViewDelegate>

@property (strong, nonatomic) IBOutlet QWTableView *tableView;

@property (nonatomic, strong) QWDiscussLogic *logic;

@property (nonatomic, strong) JSBadgeView *badgeView;

@property (strong, nonatomic) IBOutlet UILabel *titleView;
@property (strong, nonatomic) IBOutlet UIView *titleViewBg;
@property (strong, nonatomic) IBOutlet UIView *titleViewParent;

@property (strong, nonatomic) QWInputView *contentInputView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *filterBtn;

@property (nonatomic) BOOL showBest;

@end

@implementation QWDiscussTVC

+ (void)load
{
    QWMappingVO *vo = [QWMappingVO new];
    vo.className = [NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject;
    vo.storyboardName = @"QWDiscuss";

    [[QWRouter sharedInstance] registerRouterVO:vo withKey:@"discuss"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"讨论";
    if (self.extraData) {
        self.title = @"讨论";
        self.discussUrl = [self.extraData objectForCaseInsensitiveKey:@"url"];
    }
    //获取前一个Vc
//    [self getBarand];

    [self.tableView registerNib:[UINib nibWithNibName:@"QWDiscussImageTVCell" bundle:nil] forCellReuseIdentifier:@"image"];

    self.contentInputView = [QWInputView createWithNib];
    [self.view addSubview:self.contentInputView];
    [self.contentInputView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
    [self.contentInputView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view];
    if (@available(iOS 11.0, *)) {
        //[self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = true;
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = true;
        self.contentInputView.bottomConstraint = [self.contentInputView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor];
        self.contentInputView.bottomConstraint.active = true;

    }else{
        self.contentInputView.bottomConstraint = [self.contentInputView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view];
    }
    
    self.contentInputView.delegate = self;
    [self.contentInputView setLogic:self.logic];

    self.navigationItem.titleView = self.titleViewParent;
    
    self.titleView.textColor = HRGB(0x505050);
    self.titleView.text = self.title;

    self.badgeView = [[JSBadgeView alloc] initWithParentView:self.titleViewBg alignment:JSBadgeViewAlignmentCenterRight];
    self.badgeView.badgeBackgroundColor = QWPINK;
    self.badgeView.badgePositionAdjustment = CGPointMake(0, -1);
    self.badgeView.badgeTextFont = [UIFont systemFontOfSize:12.f];
    self.badgeView.badgeTextColor = [UIColor whiteColor];

    if (IOS_SDK_MORE_THAN(8.0)) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }

    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableFooterView.tag = 999;

    if (_isChild) {
        if(ISIPHONEX){
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 88, 0);
        }else{
//            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, -64, 0);
        }
        
    }
    else {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 88, 0);

    }
    self.tableView.estimatedRowHeight = 125;

    WEAK_SELF;
    self.tableView.mj_header = [QWRefreshHeader headerWithRefreshingBlock:^{
        STRONG_SELF;
        [self getData];
    }];
    self.navigationItem.rightBarButtonItem = nil;
    [self getData];
    
}

- (void)showBookNameIntro
{
    [QWBookNameIntroView showOnView:[[UIApplication sharedApplication].delegate window]];
}

- (QWDiscussLogic *)logic
{
    if (!_logic) {
        _logic = [QWDiscussLogic logicWithOperationManager:self.operationManager];
    }

    return _logic;
}

- (IBAction)unwindToDiscussVC:(UIStoryboardSegue *)sender
{

}

- (IBAction)unwindToDiscussVCAndRefresh:(UIStoryboardSegue *)sender
{
    [self getData];
}

- (IBAction)unwindFromCommentToDiscussVCAndRefresh:(UIStoryboardSegue *)sender
{
    [self getData];
}

- (IBAction)onPressedFilterBtn:(id)sender {
    if (self.logic.loading) {
        return;
    }

    self.showBest = !self.showBest;

    if (self.showBest) {
        self.filterBtn.title = @"查看全部";
    }
    else {
        self.filterBtn.title = @"只看精品";
    }

    [self.tableView setContentOffset:CGPointMake(0, -64)];
    [self getData];
}

- (void)getData {
    WEAK_SELF;
    if (self.logic.loading) {
        return ;
    }

    self.logic.loading = true;
    self.tableView.emptyView.showError = NO;
    self.logic.discussVO = nil;
    self.logic.topDiscussVO = nil;
    self.logic.bestDiscussVO = nil;
    [self.tableView reloadData];

    [self.logic getDiscussLastCountWithUrl:self.discussUrl andCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;

        NSString *count = nil;

        if ( ! self.logic.discussLastCount ||self.logic.discussLastCount.integerValue < 1) {
            count = @"";
        }
        else if (self.logic.discussLastCount.integerValue > 99) {
            if (IOS_SDK_MORE_THAN(9.0)) {
                count = @"99+";
            }
            else {
                count = @" 99+";
            }
        }
        else {
            count = self.logic.discussLastCount.stringValue;
        }

        self.badgeView.badgeText = count;
    }];

    if (self.showBest) {
        [self.logic getBestDiscussWithUrl:self.discussUrl andCompleteBlock:^(id aResponseObject, NSError *anError) {
            STRONG_SELF;
            self.logic.loading = false;
            [self.tableView reloadData];
            [self showBookNameIntro];
            self.tableView.emptyView.showError = YES;
            self.tableView.tableFooterView = [UIView new];
            self.tableView.tableFooterView.tag = 999;
            [self.tableView.mj_header endRefreshing];
        }];
    }
    else {
        [self.logic getTopDiscussWithUrl:self.discussUrl andCompleteBlock:^(id aResponseObject, NSError *anError) {
            STRONG_SELF;
            [self.logic getDiscussWithUrl:self.discussUrl andCompleteBlock:^(id aResponseObject, NSError *anError) {
                STRONG_SELF;

                if (self.logic.topDiscussVO) {
                    NSMutableArray *items = self.logic.topDiscussVO.results.mutableCopy;
                    [items addObjectsFromArray:self.logic.discussVO.results];
                    self.logic.discussVO.results = (id)items;
                }

                [self.tableView reloadData];
                [self showBookNameIntro];
                self.logic.loading = false;
                self.tableView.emptyView.showError = YES;
                self.tableView.tableFooterView = [UIView new];
                self.tableView.tableFooterView.tag = 999;
                [self.tableView.mj_header endRefreshing];
            }];
        }];
    }

    if ([QWGlobalValue sharedInstance].isLogin) {
        [self.logic getAuthorWithUrl:self.discussUrl andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {

        }];
    }
}

- (void)getMoreData {
    WEAK_SELF;
    if (self.showBest) {
        [self.logic getBestDiscussWithUrl:self.discussUrl andCompleteBlock:^(id aResponseObject, NSError *anError) {
            STRONG_SELF;
            [self.tableView reloadData];
            self.tableView.tableFooterView = nil;
        }];
    }
    else {
        [self.logic getDiscussWithUrl:self.discussUrl andCompleteBlock:^(id aResponseObject, NSError *anError) {
            STRONG_SELF;
            [self.tableView reloadData];
            self.tableView.tableFooterView = nil;
        }];
    }
}

- (void)getBarand {
    WEAK_SELF;
    [self.logic getBrandWithUrl:self.discussUrl andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (aResponseObject && !anError) {
            
            NSMutableArray *vcs = self.navigationController.viewControllers.mutableCopy;
            if (vcs.count < 2) {
                return;
            }
            NSString *work_url = [aResponseObject objectForKey:@"work_url"];
            NSNumber *work_type = [aResponseObject objectForKey:@"work_type"];
            NSNumber *work_id = [aResponseObject objectForKey:@"work_id"];
//            work_url = @"https://api.iqing.in/activity/29/";
//            work_type = @3;
            UIViewController *previousVC = [vcs objectAtIndex:vcs.count - 2];
            
            switch (work_type.integerValue) {
                case 1: //书
                    if (![previousVC isKindOfClass:[QWDetailTVC class]] && ![previousVC isKindOfClass:[QWReadingPVC class]]) {
                        QWDetailTVC *tvc = [QWDetailTVC createFromStoryboardWithStoryboardID:@"detail" storyboardName:@"QWDetail"];
                        tvc.book_url = work_url;
                        [vcs insertObject:tvc atIndex:vcs.count - 1];
                    }
                    break;
                case 2: //演绘
                    if (![previousVC isKindOfClass:[QWGameDetailVC class]]) {
                        QWGameDetailVC *tvc = [QWGameDetailVC createFromStoryboardWithStoryboardID:@"detail" storyboardName:@"QWGame"];
                        tvc.book_url = work_url;
                        [vcs insertObject:tvc atIndex:vcs.count - 1];
                    }
                    break;
                case 3:// 活动
                    if (![previousVC isKindOfClass:[QWActivityVC class]] && ![previousVC isKindOfClass:[QWSearchTVC class]]) {
                        QWActivityPageVC *tvc = [QWActivityPageVC createFromStoryboardWithStoryboardID:@"activitypage" storyboardName:@"QWActivity"];
                        tvc.url = work_url;
                        tvc.inId = @"1";
                        [vcs insertObject:tvc atIndex:vcs.count - 1];
                    }
                    break;
                case 4://专题
                    if (![previousVC isKindOfClass:[QWActivityVC class]] && ![previousVC isKindOfClass:[QWSearchTVC class]]) {
                        QWActivityPageVC *tvc = [QWActivityPageVC createFromStoryboardWithStoryboardID:@"activitypage" storyboardName:@"QWActivity"];
                        tvc.url = work_url;
                        tvc.topic = true;
                        tvc.inId = @"1";
                        [vcs insertObject:tvc atIndex:vcs.count - 1];
                    }
                    break;
                case 6://书单
                    if (![previousVC isKindOfClass:[QWBooksListDetails class]]) {
                        QWBooksListDetails *tvc = [QWBooksListDetails createFromStoryboardWithStoryboardID:@"BookListsDetails" storyboardName:@"QWBookListsDetails"];
                        tvc.bookListID = work_id;
                        tvc.work_url = work_url;
                        [vcs insertObject:tvc atIndex:vcs.count - 1];
                    }
                    break;
                default://综合讨论区
                    
                    break;
            }
            [self.navigationController setViewControllers:vcs animated:NO];
        }
    }];
}

#pragma mark TableView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.contentInputView resetInputView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.showBest) {
        return self.logic.bestDiscussVO.results.count;
    }
    else {
        return self.logic.discussVO.results.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section + 1 == self.tableView.numberOfSections) {
        return 40;
    }

    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView autolayoutView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DiscussItemVO *vo = nil;
    if (self.showBest) {
        vo = self.logic.bestDiscussVO.results[indexPath.section];
    }
    else {
        vo = self.logic.discussVO.results[indexPath.section];
    }
    if (indexPath.row == 0) {
        return [QWDiscussTVCell heightForCellData:vo];
    }
    else {
        return [QWDiscussImageTVCell height1ForCellData:vo];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DiscussItemVO *vo = nil;
    if (self.showBest) {
        vo = self.logic.bestDiscussVO.results[indexPath.section];
    }
    else {
        vo = self.logic.discussVO.results[indexPath.section];
    }

    if (indexPath.row == 0) {
        QWDiscussTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

        if (IOS_SDK_MORE_THAN(8.0)) {
            cell.layoutMargins = UIEdgeInsetsZero;
        }
        
        [cell updateWithDiscussItemVO:vo];
        return cell;
    }
    else {
        QWDiscussImageTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"image" forIndexPath:indexPath];
        cell.collectionView.userInteractionEnabled = NO;

        if (IOS_SDK_MORE_THAN(8.0)) {
            cell.layoutMargins = UIEdgeInsetsZero;
        }

        [cell updateWithDiscussItemVO:vo];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_isChild) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"QWDiscuss" bundle:nil];
        QWCommentTVC *tvc = [sb instantiateViewControllerWithIdentifier:@"discussdetail"];
        tvc.own = self.logic.own;
        
        DiscussItemVO *vo = nil;
        if (self.showBest) {
            vo = self.logic.bestDiscussVO.results[indexPath.section];
        }
        else {
            vo = self.logic.discussVO.results[indexPath.section];
        }
        tvc.itemVO = vo;
        tvc.own = self.logic.own;
        [self.parentViewController.navigationController pushViewController:tvc animated:true];
    }
    else {
        [self performSegueWithIdentifier:@"comment" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
    }

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.showBest) {
        if ((!tableView.tableFooterView || tableView.tableFooterView.tag == 999)) {
            if ((self.logic.bestDiscussVO.results.count - 1 == indexPath.section) && self.logic.bestDiscussVO.results.count < self.logic.bestDiscussVO.count.integerValue && self.logic.bestDiscussVO.next.length > 0) {//计算是否是最后一个cell
                [tableView showLoadingMore];//显示loadingmore
                [self getMoreData];//调用加载新数据的函数
            }
        }
    }
    else {
        if ((!tableView.tableFooterView || tableView.tableFooterView.tag == 999)) {
            if ((self.logic.discussVO.results.count - 1 == indexPath.section) && self.logic.discussVO.results.count < self.logic.discussVO.count.integerValue && self.logic.discussVO.next.length > 0) {//计算是否是最后一个cell
                [tableView showLoadingMore];//显示loadingmore
                [self getMoreData];//调用加载新数据的函数
            }
        }
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
    DiscussItemVO *itemVO = nil;
    if (self.showBest) {
        itemVO = self.logic.bestDiscussVO.results[indexPath.section];
    }
    else {
        itemVO = self.logic.discussVO.results[indexPath.section];
    }
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    pb.string = itemVO.content;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"newdiscuss"]) {
        QWNewDiscussVC *vc = (id)[segue.destinationViewController topViewController];
        vc.discussUrl = self.discussUrl;

    }
    else if ([segue.identifier isEqualToString:@"comment"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        QWCommentTVC *vc = segue.destinationViewController;
        vc.own = self.logic.own;

        DiscussItemVO *vo = nil;
        if (self.showBest) {
            vo = self.logic.bestDiscussVO.results[indexPath.section];
        }
        else {
            vo = self.logic.discussVO.results[indexPath.section];
        }

        vc.itemVO = vo;
        vc.own = self.logic.own;
    }
}

- (IBAction)toNewDiscuss
{
    if (![QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        return;
    }

    [self performSegueWithIdentifier:@"newdiscuss" sender:nil];
}

- (void)inputView:(QWInputView *)inputView onPressedSendBtn:(id)sender
{
    if (![QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        return;
    }

    if (!self.contentInputView.contentTV.text.length) {
        [self showToastWithTitle:@"内容不能为空" subtitle:nil type:ToastTypeError];
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
    [self.logic createDiscussWithUrl:self.discussUrl content:self.contentInputView.contentTV.text paths:self.contentInputView.imageInputView.imageUrls andCompleteBlock:^(id aResponseObject, NSError *anError) {
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
                self.contentInputView.contentTV.text = nil;
                [self.contentInputView.imageInputView clear];
                [self.contentInputView resetInputView];
                [self showToastWithTitle:@"发帖成功" subtitle:nil type:ToastTypeNormal];
                [self getData];
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }

        [self hideLoading];
    }];
}

- (void)inputView:(QWInputView *)inputView onPressedAddBookBtn:(id)sender
{
    WEAK_SELF;
    [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"search" andParams:@{@"searchbookname": @1}] callbackBlock:^id(NSDictionary *params) {
        __strong typeof(weakSelf)self = weakSelf;
        NSString *book_name = params[@"book_name"];
        self.contentInputView.contentTV.text = [NSString stringWithFormat:@"%@ 《%@》 ", self.contentInputView.contentTV.text, book_name];
        [self.contentInputView textViewDidChange:self.contentInputView.contentTV];
        return nil;
    }];
}

- (void)inputView:(QWInputView *)inputView onPressedAddAtBtn:(id)sender
{
    WEAK_SELF;
    [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"myattention" andParams:@{@"searchusername": @1}] callbackBlock:^id(NSDictionary *params) {
        __strong typeof(weakSelf)self = weakSelf;
        NSString *nickname = params[@"nickname"];
        self.contentInputView.contentTV.text = [NSString stringWithFormat:@"%@ @%@ ", self.contentInputView.contentTV.text, nickname];
        [self.contentInputView textViewDidChange:self.contentInputView.contentTV];
        return nil;
    }];
}
//-(void)leftBtnClicked:(id)sender{
//    [self.navigationController popToRootViewControllerAnimated:YES];
//}
@end
