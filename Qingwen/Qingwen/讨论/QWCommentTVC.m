//
//  QWCommentTVC.m
//  Qingwen
//
//  Created by Aimy on 8/11/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWCommentTVC.h"

#import "QWDiscussLogic.h"
#import "QWTableView.h"
#import "QWCommentTVCell.h"
#import "QWCommentHeadTVCell.h"
#import "QWNewCommentVC.h"
#import "UITableView+loadingMore.h"
#import <UINavigationController+FDFullscreenPopGesture.h>
#import "QWInputView.h"
#import "QWBlacListManager.h"
#import <MJRefresh.h>

@interface QWCommentTVC () <UITableViewDataSource, UITableViewDelegate, QWInputViewDelegate, QWDiscussImageTVCellDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet QWTableView *tableView;

@property (nonatomic, strong) QWDiscussLogic *logic;
@property (nonatomic, strong) QWUserLogic *userLogic;

@property (nonatomic) BOOL lonely;

@property (strong, nonatomic) QWInputView *contentInputView;

@property (nonatomic, strong) NSString *discussUrl;

@property (nonatomic) BOOL hasNewComment;

@end

@implementation QWCommentTVC

+ (void)load
{
    QWMappingVO *vo = [QWMappingVO new];
    vo.className = [NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject;
    vo.storyboardName = @"QWDiscuss";
    vo.storyboardID = @"discussdetail";

    [[QWRouter sharedInstance] registerRouterVO:vo withKey:@"discussdetail"];
}

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

    if (IOS_SDK_MORE_THAN(8.0)) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }

    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 88, 0);
    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableFooterView.tag = 999;

    WEAK_SELF;
    self.tableView.mj_header = [QWRefreshHeader headerWithRefreshingBlock:^{
        STRONG_SELF;
        [self getData];
    }];

    if (self.extraData) {
        self.discussUrl = [self.extraData objectForCaseInsensitiveKey:@"url"];
        self.own = [self.extraData objectForCaseInsensitiveKey:@"own"];
    }

    if (self.discussUrl) { //说明是外链跳转进来，需要处理返回逻辑
        WEAK_SELF;
        [self.logic getDiscussDetailWithUrl:self.discussUrl andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            STRONG_SELF;
            if (!anError && [DiscussItemVO class]) {
                self.itemVO = aResponseObject;
                [self addDiscussTVCWithBrand:self.itemVO.brand];
                [self getData];
            }
        }];

        if ([QWGlobalValue sharedInstance].isLogin && !self.own) {
            [self.logic getAuthorWithUrl:self.discussUrl andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {

            }];
        }
    }
    else {
        [self getData];
    }
}

- (QWDiscussLogic *)logic
{
    if (!_logic) {
        _logic = [QWDiscussLogic logicWithOperationManager:self.operationManager];
    }

    return _logic;
}

- (QWUserLogic *)userLogic {
    if (!_userLogic) {
        _userLogic = [QWUserLogic logicWithOperationManager:self.operationManager];
    }
    return _userLogic;
}

- (void)addDiscussTVCWithBrand:(NSString *)brand {
    NSString *string;
    NSLog(@"%lu",(unsigned long)string.length);
    
    NSMutableArray *vcs = self.navigationController.viewControllers.mutableCopy;
    if (vcs.count > 1) {
        UIViewController *vc = [vcs objectAtIndex:vcs.count - 2];
        if (![vc isKindOfClass:[QWDiscussTVC class]]) {
            QWDiscussTVC *discussvc = [QWDiscussTVC createFromStoryboardWithStoryboardID:@"discuss" storyboardName:@"QWDiscuss"];
            discussvc.discussUrl = [NSString stringWithFormat:@"%@/v3/brand/%@/",[QWOperationParam currentBfDomain],brand];
            [vcs insertObject:discussvc atIndex:vcs.count -1];
            [self.navigationController setViewControllers:vcs];
        }
    }
}

- (void)showAddBookNameIntro
{
    [QWAddBookNameIntroView showOnView:[[UIApplication sharedApplication].delegate window]];
}

- (void)leftBtnClicked:(id)sender
{
    if (self.hasNewComment && !self.discussUrl) {
        [self cancelAllOperations];
        [self performSegueWithIdentifier:@"refreshdiscuss" sender:self];
    }
    else {
        [super leftBtnClicked:sender];
    }
}

- (IBAction)unwindToCommentVC:(UIStoryboardSegue *)sender
{

}

- (IBAction)unwindToCommentVCAndRefresh:(UIStoryboardSegue *)sender
{
    self.itemVO.updated_time = [NSDate date];
    [self getData];
    self.hasNewComment = YES;
    self.fd_interactivePopDisabled = YES;
}

- (void)getData {
    WEAK_SELF;
    self.logic.commentVO = nil;
    self.tableView.emptyView.showError = NO;
    [self.logic getCommentWithUrl:self.itemVO.url lonely:self.lonely andCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        [self showAddBookNameIntro];
        if (self.logic.commentVO) {
            NSMutableArray *items = self.logic.commentVO.results.mutableCopy;
            [items insertObject:self.itemVO atIndex:0];
            self.logic.commentVO.results = (id)items;
        }
        else {
            self.logic.commentVO = [DiscussVO new];
            if (self.itemVO) {
                self.logic.commentVO.results = (id)@[self.itemVO];
            }
            else {
                self.logic.commentVO.results = (id)@[];
            }
        }

        self.tableView.emptyView.showError = YES;
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
    }];
    [self.logic getAchievementInfoWithCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        
    }];
}

- (void)getDataWithID { 
    [self showLoading];
    self.hasNewComment = YES;
    [self.logic getDiscussDetailWithID:self.itemVO.nid andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        [self hideLoading];
        if (!anError && [DiscussItemVO class]) {
            self.itemVO = aResponseObject;
            [self getData];
        }
    }];
}

- (void)getMoreData {
    WEAK_SELF;
    [self.logic getCommentWithUrl:self.itemVO.url lonely:self.lonely andCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        [self.tableView reloadData];
        self.tableView.tableFooterView = [UIView new];
        self.tableView.tableFooterView.tag = 999;
    }];
}

- (void)showMenu {

    if (self.own.boolValue) {
        [self showMenuOwn];
    }
    else {
        [self showMenuOther];
    }
}

- (void)showMenuOther {
    NSArray *routerArray = [self getRouterArrayFormItem:self.itemVO];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] bk_initWithTitle:self.itemVO.content];
    WEAK_SELF;
    [routerArray enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL * _Nonnull stop) {
        STRONG_SELF;
        if (!obj) {
            return;
        }
        NSString *router = [obj objectForKey:@"value"];
        NSLog(@"roter123 = %@",router);
        NSString *key = [obj objectForKey:@"key"];
        NSLog(@"key123 = %@",key);
        if (router.length == 0 || router == nil || key.length == 0 || obj == nil) {
            return;
        }
        [actionSheet bk_addButtonWithTitle:key handler:^{
            STRONG_SELF;
            [[QWRouter sharedInstance] routerWithUrlString:router];
        }];
    }];
    
    [actionSheet bk_addButtonWithTitle:@"回复" handler:^{
        STRONG_SELF;
        [self.contentInputView.contentTV becomeFirstResponder];
    }];

    [actionSheet bk_addButtonWithTitle:@"复制" handler:^{
        STRONG_SELF;
        DiscussItemVO *itemVO = self.itemVO;
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        pb.string = itemVO.content;
        [self showToastWithTitle:@"复制成功" subtitle:nil type:ToastTypeAlert];
    }];

    [actionSheet bk_addButtonWithTitle:@"举报" handler:^{
        STRONG_SELF;
        [self doReport:self.itemVO];
    }];
    
    
    [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:^{

    }];
    
    [actionSheet showInView:self.view];
}

- (void)showMenuOwn {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] bk_initWithTitle:self.itemVO.content];
    
    NSArray *routerArray = [self getRouterArrayFormItem:self.itemVO];
    WEAK_SELF;
    [routerArray enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL * _Nonnull stop) {
        STRONG_SELF;
        if (!obj) {
            return;
        }
        NSString *router = [obj objectForKey:@"value"];
        NSString *key = [obj objectForKey:@"key"];
        if (router.length == 0 || router == nil || key.length == 0 || obj == nil) {
            return;
        }
        [actionSheet bk_addButtonWithTitle:key handler:^{
            STRONG_SELF;
            [[QWRouter sharedInstance] routerWithUrlString:router];
        }];
    }];
    
    if ([self.itemVO.tags filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"nid == %@", @"5693513f08c9d53e3326d877"]].firstObject) {
        [actionSheet bk_addButtonWithTitle:@"取消加精" handler:^{
            STRONG_SELF;
            [self showLoading];
            [self.logic setDiggestWithUrl:self.itemVO.url type:YES andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
                STRONG_SELF;
                [self hideLoading];
                if (!anError) {
                    NSNumber *code = aResponseObject[@"code"];
                    if (code && ! [code isEqualToNumber:@0]) {//有错误
                        NSString *message = aResponseObject[@"data"];
                        if (message.length) {
                            [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                        }
                        else {
                            [self showToastWithTitle:@"取消加精失败" subtitle:nil type:ToastTypeError];
                        }
                    }
                    else {
                        [self getDataWithID];
                        [self showToastWithTitle:@"取消加精成功" subtitle:nil type:ToastTypeError];
                    }
                }
                else {
                    [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
                }
            }];
        }];
    }
    else {
        [actionSheet bk_addButtonWithTitle:@"加精" handler:^{
            STRONG_SELF;
            [self showLoading];
            [self.logic setDiggestWithUrl:self.itemVO.url type:NO andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
                STRONG_SELF;
                [self hideLoading];
                if (!anError) {
                    NSNumber *code = aResponseObject[@"code"];
                    if (code && ! [code isEqualToNumber:@0]) {//有错误
                        NSString *message = aResponseObject[@"data"];
                        if (message.length) {
                            [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                        }
                        else {
                            [self showToastWithTitle:@"加精失败" subtitle:nil type:ToastTypeError];
                        }
                    }
                    else {
                        [self getDataWithID];
                        [self showToastWithTitle:@"加精成功" subtitle:nil type:ToastTypeError];
                    }
                }
                else {
                    [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
                }
            }];
        }];
    }

    if (self.itemVO.top.boolValue) {
        [actionSheet bk_addButtonWithTitle:@"取消置顶" handler:^{
            STRONG_SELF;
            [self showLoading];
            [self.logic setTopWithUrl:self.itemVO.url type:YES andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
                STRONG_SELF;
                [self hideLoading];
                if (!anError) {
                    NSNumber *code = aResponseObject[@"code"];
                    if (code && ! [code isEqualToNumber:@0]) {//有错误
                        NSString *message = aResponseObject[@"data"];
                        if (message.length) {
                            [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                        }
                        else {
                            [self showToastWithTitle:@"取消置顶失败" subtitle:nil type:ToastTypeError];
                        }
                    }
                    else {
                        self.itemVO.top = @0;
                        [self.tableView reloadData];
                        [self showToastWithTitle:@"取消置顶成功" subtitle:nil type:ToastTypeError];
                    }
                }
                else {
                    [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
                }
            }];
        }];
    }
    else {
        [actionSheet bk_addButtonWithTitle:@"置顶" handler:^{
            STRONG_SELF;
            [self showLoading];
            [self.logic setTopWithUrl:self.itemVO.url type:NO andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
                STRONG_SELF;
                [self hideLoading];
                if (!anError) {
                    NSNumber *code = aResponseObject[@"code"];
                    if (code && ! [code isEqualToNumber:@0]) {//有错误
                        NSString *message = aResponseObject[@"data"];
                        if (message.length) {
                            [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                        }
                        else {
                            [self showToastWithTitle:@"置顶失败" subtitle:nil type:ToastTypeError];
                        }
                    }
                    else {
                        self.itemVO.top = @1;
                        [self.tableView reloadData];
                        [self showToastWithTitle:@"置顶成功" subtitle:nil type:ToastTypeError];
                    }
                }
                else {
                    [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
                }
            }];
        }];
    }

    [actionSheet bk_addButtonWithTitle:@"回复" handler:^{
        STRONG_SELF;
        [self.contentInputView.contentTV becomeFirstResponder];
    }];

    [actionSheet bk_addButtonWithTitle:@"复制" handler:^{
        STRONG_SELF;
        DiscussItemVO *itemVO = self.itemVO;
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        pb.string = itemVO.content;
        [self showToastWithTitle:@"复制成功" subtitle:nil type:ToastTypeAlert];
    }];

    [actionSheet bk_addButtonWithTitle:@"举报" handler:^{
        STRONG_SELF;
        [self doReport:self.itemVO];
    }];

    [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:^{
        
    }];

    [actionSheet showInView:self.view];
}

- (void)showMenuPost:(DiscussItemVO *)itemVO {
    NSArray *routerArray = [self getRouterArrayFormItem:itemVO];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] bk_initWithTitle:itemVO.content];
    
    WEAK_SELF;
    [routerArray enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL * _Nonnull stop) {
        STRONG_SELF;
        if (!obj) {
            return;
        }
        NSString *router = [obj objectForKey:@"value"];
        NSString *key = [obj objectForKey:@"key"];
        if (router.length == 0 || router == nil || key.length == 0 || obj == nil) {
            return;
        }
        [actionSheet bk_addButtonWithTitle:key handler:^{
            STRONG_SELF;
            [[QWRouter sharedInstance] routerWithUrlString:router];
        }];
    }];
    
    [actionSheet bk_addButtonWithTitle:@"回复" handler:^{
        STRONG_SELF;
        [self performSegueWithIdentifier:@"comment" sender:itemVO];
    }];

    [actionSheet bk_addButtonWithTitle:@"复制" handler:^{
        STRONG_SELF;
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        pb.string = itemVO.content;
        [self showToastWithTitle:@"复制成功" subtitle:nil type:ToastTypeAlert];
    }];
    
    [actionSheet bk_addButtonWithTitle:@"举报" handler:^{
        STRONG_SELF;
        [self doReport:itemVO];
    }];
    
    if ([itemVO.user.nid.stringValue isEqualToString:[QWGlobalValue sharedInstance].nid.stringValue]) {
        [actionSheet bk_addButtonWithTitle:@"删除此回复" handler:^{
            [self deleteReport:itemVO];
        }];
    } else {
        [actionSheet bk_addButtonWithTitle:@"拉黑此用户" handler:^{
            [[QWBlacListManager sharedInstance] addToBlackListWithUser:itemVO.user];
            [self getData];
        }];
    }
    [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:^{

    }];
    
    [actionSheet showInView:self.view];
}

- (NSArray *)getRouterArrayFormItem:(DiscussItemVO *)itemVO {
    if (itemVO.content.length == 0) {
        return NULL;
    }
    NSMutableArray *routerArray = @[].mutableCopy;
    
    {
        WEAK_SELF;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"《([^《》]{1,})》" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray<NSTextCheckingResult *> *result = [regex matchesInString:itemVO.content options:0 range:NSMakeRange(0, itemVO.content.length)];
        [result enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            STRONG_SELF;
            NSMutableDictionary *params = @{}.mutableCopy;
            params[@"book_name"] = [itemVO.content substringWithRange:obj.range];
            NSString *routerValue = [NSString getRouterVCUrlStringFromUrlString:@"search" andParams:params];
            
            NSMutableDictionary *router = @{}.mutableCopy;
            
            router[@"key"] = [itemVO.content substringWithRange:obj.range];
            router[@"value"] = routerValue;
            [routerArray addObject:router];
        }];
    }
    
    {
        WEAK_SELF;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@([^@《》\\[\\] ]{1,})( |$)" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray<NSTextCheckingResult *> *result = [regex matchesInString:itemVO.content options:0 range:NSMakeRange(0, itemVO.content.length)];
        [result enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            STRONG_SELF;
            NSMutableDictionary *params = @{}.mutableCopy;
            NSString *username = [itemVO.content substringWithRange:obj.range];
            username = [username substringWithRange:NSMakeRange(1, username.length - 1)];
            username = [username stringByReplacingOccurrencesOfString:@" " withString:@""];
            params[@"username"] = username;
            NSString *routerValue = [NSString getRouterVCUrlStringFromUrlString:@"user" andParams:params];
            
            NSMutableDictionary *router = @{}.mutableCopy;
            router[@"key"] = username;
            router[@"value"] = routerValue;
            [routerArray addObject:router];
        }];
    }
    
    {
        WEAK_SELF;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray<NSTextCheckingResult *> *result = [regex matchesInString:itemVO.content options:0 range:NSMakeRange(0, itemVO.content.length)];
        [result enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            STRONG_SELF;
            NSMutableDictionary *params = @{}.mutableCopy;
            NSString *url = [itemVO.content substringWithRange:obj.range];
            params[@"url"] = url;
            
            NSMutableDictionary *router = @{}.mutableCopy;
            router[@"key"] = url;
            router[@"value"] = [NSString getRouterVCUrlStringFromUrlString:url];
            [routerArray addObject:router];
        }];
    }
    
    return routerArray;
}

- (IBAction)onPressedReplyBtn:(id)sender event:(UIEvent *)event {
    UITouch *touch = event.allTouches.anyObject;
    CGPoint point = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    [self performSegueWithIdentifier:@"comment" sender:self.logic.commentVO.results[indexPath.section]];
}

- (void)onPressedBackgroundViewInImageCell:(QWDiscussImageTVCell *)imageCell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:imageCell];
    if (indexPath.section == 0) {
        END_EDITING;
        [self showMenu];
    }
    else {
        END_EDITING;
        [self showMenuPost:self.logic.commentVO.results[indexPath.section]];
    }
}

- (void)doReport:(DiscussItemVO *)itemVO {
    BOOL type = self.itemVO != itemVO;
    UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:type ? @"是否举报该回复?" : @"是否举报该帖子?" message:nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].placeholder = @"请输入举报理由（选填）";
    WEAK_SELF;
    [alertView bk_addButtonWithTitle:@"举报" handler:^{
        STRONG_SELF;
        [self showLoading];
        [self.logic submitReportWithId:itemVO.nid type:type content: [alertView textFieldAtIndex:0].text andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            [self hideLoading];
            if (!anError) {
                NSNumber *code = aResponseObject[@"code"];
                if (code && ! [code isEqualToNumber:@0]) {//有错误
                    NSString *message = aResponseObject[@"data"];
                    if (message.length) {
                        [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                    }
                    else {
                        [self showToastWithTitle:@"举报失败" subtitle:nil type:ToastTypeError];
                    }
                }
                else {
                    [self showToastWithTitle:@"感谢你的举报，我们的审核人员会在2个工作日之内做好处理。" subtitle:nil type:ToastTypeError];
                }
            }
            else {
                [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
            }
        }];
    }];

    [alertView bk_addButtonWithTitle:@"放弃" handler:^{

    }];

    [alertView show];
}

- (void)deleteReport:(DiscussItemVO *)itemVO {
    BOOL type = self.itemVO != itemVO;
    UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:type ? @"是否要删除你的回复?" : @"是否举报该帖子?" message:nil];
    WEAK_SELF;
    [alertView bk_addButtonWithTitle:@"删除" handler:^{
        STRONG_SELF;
        [self showLoading];
        [self.logic deleteDiscussWithId:itemVO.nid type:type andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            [self hideLoading];
            if (!anError) {
                NSNumber *code = aResponseObject[@"code"];
                if (code && ! [code isEqualToNumber:@0]) {//有错误
                    NSString *message = aResponseObject[@"data"];
                    if (message.length) {
                        [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                    }
                    else {
                        [self showToastWithTitle:@"删除失败" subtitle:nil type:ToastTypeError];
                    }
                }
                else {
                    [self showToastWithTitle:@"删除成功" subtitle:nil type:ToastTypeError];
                    [self getData];
                }
            }
            else {
                [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
            }
        }];
    }];
    
    [alertView bk_addButtonWithTitle:@"取消" handler:^{
        
    }];
    [alertView show];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.logic.commentVO.results.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DiscussItemVO *itemVO = self.logic.commentVO.results[indexPath.section];

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return [QWCommentHeadTVCell heightForCellData:itemVO];
        }
        else {
            return [QWDiscussImageTVCell height1ForCellData:itemVO];
        }
    }
    else {
        if (indexPath.row == 0) {
            return [QWCommentTVCell heightForCellData:itemVO];
        }
        else {
            return [QWDiscussImageTVCell height1ForCellData:itemVO];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DiscussItemVO *itemVO = self.logic.commentVO.results[indexPath.section];

    if (indexPath.row == 1) {
        QWDiscussImageTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"image" forIndexPath:indexPath];
        cell.delegate = self;
        if (indexPath.section == 0) {
            cell.collectionView.backgroundColor = [UIColor whiteColor];
        }
        else {
            cell.collectionView.backgroundColor = HRGB(0xf8f8f8);
        }
        if (IOS_SDK_MORE_THAN(8.0)) {
            cell.layoutMargins = UIEdgeInsetsZero;
        }

        [cell updateWithDiscussItemVO:itemVO];
        return cell;
    }

    if (indexPath.section == 0) {
        QWCommentHeadTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"head" forIndexPath:indexPath];

        if (IOS_SDK_MORE_THAN(8.0)) {
            cell.layoutMargins = UIEdgeInsetsZero;
        }

        [cell updateWithDiscussItemVO:itemVO];
        return cell;
    }
    else {
        QWCommentTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

        if (IOS_SDK_MORE_THAN(8.0)) {
            cell.layoutMargins = UIEdgeInsetsZero;
        }

        [cell updateWithCommentItemVO:itemVO];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        END_EDITING;
        [self showMenu];
    }
    else {
        END_EDITING;
        [self showMenuPost:self.logic.commentVO.results[indexPath.section]];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((!tableView.tableFooterView || tableView.tableFooterView.tag == 999)) {
        if ((self.logic.commentVO.results.count == indexPath.section + 1) && self.logic.commentVO.results.count - 1 < self.logic.commentVO.count.integerValue && self.logic.commentVO.next.length > 0) {//计算是否是最后一个cell
            [tableView showLoadingMore];//显示loadingmore
            [self getMoreData];//调用加载新数据的函数
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
    DiscussItemVO *itemVO = self.logic.commentVO.results[indexPath.section];
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    pb.string = itemVO.content;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"comment"]) {
        DiscussItemVO *itemVO = sender;
        QWNewCommentVC *vc = segue.destinationViewController;
        vc.itemVO = itemVO;
        vc.discussUrl = self.itemVO.url;
    }
}

- (IBAction)onPressedLonelyBtn:(UIBarButtonItem *)sender {
    self.lonely = !self.lonely;
    if (self.lonely) {
        self.navigationItem.rightBarButtonItem.title = @"查看全部";
    }
    else {
        self.navigationItem.rightBarButtonItem.title = @"只看楼主";
    }

    [self getData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.contentInputView resetInputView];
}

- (void)inputView:(QWInputView *)inputView onPressedSendBtn:(id)sender {

    if (![QWGlobalValue sharedInstance].isLogin) {
        [self.contentInputView.contentTV resignFirstResponder];
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
    WEAK_SELF;
    [self.logic createCommentWithUrl:self.itemVO.url content:self.contentInputView.contentTV.text refer:nil paths:self.contentInputView.imageInputView.imageUrls andCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
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
                self.itemVO.updated_time = [NSDate date];
                self.hasNewComment = YES;
                self.fd_interactivePopDisabled = YES;
                [self getData];
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

- (void)inputView:(QWInputView *)inputView onPressedAddAtBtn:(id)sender {
    WEAK_SELF;
    [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"myattention" andParams:@{@"searchusername": @1}] callbackBlock:^id(NSDictionary *params) {
        __strong typeof(weakSelf)self = weakSelf;
        NSString *nickname = params[@"nickname"];
        self.contentInputView.contentTV.text = [NSString stringWithFormat:@"%@ @%@ ", self.contentInputView.contentTV.text, nickname];
        return nil;
    }];
}

@end
