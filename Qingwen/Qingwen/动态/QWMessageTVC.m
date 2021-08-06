//
//  QWMessageTVC.m
//  Qingwen
//
//  Created by Aimy on 8/19/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWMessageTVC.h"

#import "QWMessageLogic.h"

#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

#import "QWMessageBookTVCell.h"
#import "UITableView+loadingMore.h"
#import "QWTableView.h"
#import "QWMessageLoginView.h"
#import "QWReachability.h"
#import <MJRefresh.h>
#import "BookCD.h"
#import <UITableView+FDTemplateLayoutCell.h>

@interface QWMessageTVC () <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, strong) QWMessageLogic *logic;

@property (strong, nonatomic) IBOutlet QWTableView *tableView;

@property (nonatomic, strong) QWMessageLoginView *loginView;

@end

@implementation QWMessageTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.loginView = [QWMessageLoginView createWithNib];
    [self.view addSubview:self.loginView];
    [self.loginView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view];
    [self.loginView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view];
    [self.loginView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
    [self.loginView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view];

    self.tableView.emptyView.errorImage = [UIImage imageNamed:@"empty_3_none"];
    self.tableView.emptyView.errorMsg = @"关注作者好友、收藏小说可在此获得动态信息(>△<)";

    self.tableView.separatorInset = UIEdgeInsetsZero;
    if (IOS_SDK_MORE_THAN(8.0)) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }

    WEAK_SELF;
    [self observeNotification:LOGIN_STATE_CHANGED withBlock:^(__weak id self, NSNotification *notification) {
        KVO_STRONG_SELF;
        if ( ! notification) {
            return ;
        }

        kvoSelf.logic.messageListVO = nil;
        [kvoSelf.tableView reloadData];
        kvoSelf.loginView.hidden = [QWGlobalValue sharedInstance].isLogin;

        [kvoSelf getData];
    }];

    self.tableView.mj_header = [QWRefreshHeader headerWithRefreshingBlock:^{
        STRONG_SELF;
        [self getData];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.tableView reloadData];
    self.loginView.hidden = [QWGlobalValue sharedInstance].isLogin;
    self.tableView.emptyView.errorImage = [UIImage imageNamed:@"empty_1_none"];
    WEAK_SELF;
    [self observeObject:[QWReachability sharedInstance] property:@"currentNetStatus" withBlock:^(__weak id self, __weak id object, id old, id newVal) {
        KVO_STRONG_SELF;
        if ([QWReachability sharedInstance].isConnectedToNet && kvoSelf.logic.messageListVO == nil) {
            [kvoSelf getData];
        }
    }];
}

- (void)update
{
    [self.tableView.mj_header beginRefreshing];
}

- (QWMessageLogic *)logic
{
    if ( ! _logic) {
        _logic = [QWMessageLogic logicWithOperationManager:self.operationManager];
    }

    return _logic;
}

- (void)repeateClickTabBarItem:(NSInteger)count
{
    if (count % 2 == 0) {
        [self getData];
    }
}

- (void)getData
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [self.tableView.mj_header endRefreshing];
        return ;
    }

    if ( ! [QWGlobalValue sharedInstance].user.feed_url.length) {
        [self.tableView.mj_header endRefreshing];
        [self showToastWithTitle:@"请重新登录" subtitle:nil type:ToastTypeError];
        return;
    }

    if ([self migrate]) {
        [self.tableView.mj_header endRefreshing];
        return;
    }

    if (self.logic.isLoading) {
        [self.tableView.mj_header endRefreshing];
        return ;
    }

    self.logic.loading = YES;

    WEAK_SELF;
    self.logic.messageListVO = nil;
    self.tableView.emptyView.showError = NO;
    [self.logic getFeedWithUrl:@"https://box.iqing.in/user/explore/" completeBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        [self.tableView reloadData];
        self.loginView.hidden = [QWGlobalValue sharedInstance].isLogin;
        [self.tableView.mj_header endRefreshing];
        self.tableView.emptyView.showError = YES;
        self.logic.loading = NO;
    }];
}

- (void)getMoreData {

    if (self.logic.isLoading) {
        return ;
    }

    self.logic.loading = YES;

    WEAK_SELF;
    [self.logic getFeedWithUrl:[QWGlobalValue sharedInstance].user.feed_url completeBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        [self.tableView reloadData];
        self.loginView.hidden = [QWGlobalValue sharedInstance].isLogin;
        self.tableView.tableFooterView = nil;
        self.logic.loading = NO;
    }];
}

- (BOOL)migrate
{
    NSArray *results = [BookCD MR_findByAttribute:@"attention" withValue:@YES andOrderBy:@"attentionTime" ascending:NO inContext:[QWFileManager qwContext]];
    if (results.count) {
        WEAK_SELF;
        UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"同步" message:@"是否同步本地关注到云端"];
        [alertView bk_addButtonWithTitle:@"同步" handler:^{
            STRONG_SELF;
            NSArray *ids = [results valueForKeyPath:@"@distinctUnionOfObjects.nid"];
            [self.tabBarController showLoading];
            [self.logic migrateWithBookIds:ids andCompleteBlock:^(id aResponseObject, NSError *anError) {
                STRONG_SELF;
                if (!anError && aResponseObject) {
                    NSNumber *code = aResponseObject[@"code"];
                    if ([code isEqualToNumber:@0]) {
                        [self clearAttention];
                        UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"提示" message:@"同步成功"];
                        [alertView bk_addButtonWithTitle:@"确认" handler:^{
                            STRONG_SELF;
                            [self getData];
                        }];
                        [alertView show];
                    }
                    else {
                        NSString *message = aResponseObject[@"data"];

                        if (!message.length) {
                            message = @"同步失败";
                        }

                        UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"错误" message:message];
                        [alertView bk_addButtonWithTitle:@"返回" handler:^{
                            STRONG_SELF;
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                        [alertView show];
                    }

                    [self.tabBarController hideLoading];
                }
                else {
                    [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
                }
            }];
        }];

        [alertView bk_addButtonWithTitle:@"不同步" handler:^{
            STRONG_SELF;
            [self clearAttention];
            [self getData];
        }];

        [alertView show];

        return YES;
    }
    
    return NO;
}

- (void)clearAttention
{
    NSArray *results = [BookCD MR_findByAttribute:@"attention" withValue:@YES andOrderBy:@"attentionTime" ascending:NO inContext:[QWFileManager qwContext]];
    for (BookCD *book in results) {
        book.attention = NO;
        book.attentionTime = nil;
    }
    [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.logic.messageListVO.results.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return PX1_LINE;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageVO *itemVO = self.logic.messageListVO.results[indexPath.section];

    if (!itemVO.isValid) {
        return 0;
    }

    if (itemVO.type.integerValue == 1) {
        return [tableView fd_heightForCellWithIdentifier:@"cell1" cacheByIndexPath:indexPath configuration:^(id cell) {
            QWMessageBookTVCell *tempCell = cell;
            [tempCell updateWithMessage:itemVO];
        }];
    }
    else {
        return [tableView fd_heightForCellWithIdentifier:@"cell2" cacheByIndexPath:indexPath configuration:^(id cell) {
            QWMessageBookTVCell *tempCell = cell;
            [tempCell updateWithMessage:itemVO];
        }];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageVO *itemVO = self.logic.messageListVO.results[indexPath.section];
    
    if (itemVO.type.integerValue == 1) {
        QWMessageBookTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];

        if (IOS_SDK_MORE_THAN(8.0)) {
            cell.layoutMargins = UIEdgeInsetsZero;
        }

        [cell updateWithMessage:itemVO];
        return cell;
    }
    else if (itemVO.type.integerValue == 3) {
        QWMessageBookTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2" forIndexPath:indexPath];

        if (IOS_SDK_MORE_THAN(8.0)) {
            cell.layoutMargins = UIEdgeInsetsZero;
        }

        [cell updateWithMessage:itemVO];
        return cell;
    }
    else {
        return [UITableViewCell new];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.tableFooterView) {
        if ((self.logic.messageListVO.results.count - 1 == indexPath.section) && self.logic.messageListVO.results.count < self.logic.messageListVO.count.integerValue) {//计算是否是最后一个cell
            [tableView showLoadingMore];//显示loadingmore
            [self getMoreData];//调用加载新数据的函数
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MessageVO *itemVO = self.logic.messageListVO.results[indexPath.section];
    [[QWRouter sharedInstance] routerWithUrlString:itemVO.intent];
}

- (void)dealloc {
    
    [self removeAllObservationsOfObject:[QWReachability sharedInstance]];

}

@end
