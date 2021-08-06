//
//  QWGameDetailVC.m
//  Qingwen
//
//  Created by Aimy on 5/15/16.
//  Copyright © 2016 iQing. All rights reserved.
//

#import "QWGameDetailVC.h"
#import "QWGameDetailHeadTVCell.h"
#import "QWGameDetailRelatedTVCell.h"
#import "QWDetailFavoriteRelatedTVCell.h"
#import "QWGameDetailLogic.h"
#import "QWBookCommentsLogic.h"
#import "QWTBC.h"
#import "QWDiscussTVC.h"
#import "NSDate+Utilities.h"
#import <MXParallaxHeader/MXParallaxHeader.h>
#import "QWGameVC.h"
#import "QWVoteInfo.h"
#import "QWAnnouncementView.h"
typedef NS_ENUM(NSInteger, QWDetailType) {
    QWDetailTypeHead = 0,
    QWDetailTypeDiscuss,
//    QWDetailTypeDirectory,
    QWDetailTypeBookComments,
    QWDetailTypeFaith,    //豪无人性
    QWDetailAward,              //投石动态
//    QWDetailTypeHeavyCharge,
//    QWDetailTypeCharge,
    QWDetailTypeFavoriteRelated,
    QWDetailTypeRelated,

    QWDetailTypeCount
};

@interface QWGameDetailVC () <UITableViewDataSource, UITableViewDelegate, QWGameDetailHeadTVCellDelegate, QWGameDetailHeadViewDelegate>

@property (strong, nonatomic) IBOutlet QWTableView *tableView;

@property (nonatomic, strong) QWGameDetailLogic *logic;
@property (nonatomic, strong) QWDiscussLogic *discusslogic;
@property (nonatomic, strong) QWUserLogic *userLogic;
@property (nonatomic, strong) QWBookCommentsLogic *gameCommentslogic;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareBtn;

@property (strong, nonatomic) IBOutlet UILabel *collectionLabel;
@property (strong, nonatomic) IBOutlet UIButton *collectionBtn;
@property (strong, nonatomic) IBOutlet UIButton *gotoReadingBtn;

@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIImageView *bookImageView;

@property (nonatomic, strong) QWGameDetailHeadView *headView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBarHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *footerView;

@property (nonatomic) BOOL showAll;
@property (nonatomic) CGFloat height;

//投票
@property (strong,nonatomic) UIButton *voteBtn;
@property  (nonatomic, strong) NSNumber *voteId;
@property (nonatomic,strong) QWVoteInfo *voteInfo;
@property (nonatomic,strong) NSDictionary *voteActivityDic;

//奖券view
@property (strong,nonatomic) UIView *ticketBackView;
@property (strong,nonatomic) UIImageView *ticketImgView;
@property (strong,nonatomic) NSDictionary *ticketData;
@end

@implementation QWGameDetailVC

+ (void)load
{
    QWMappingVO *vo = [QWMappingVO new];
    vo.className = [NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject;
    vo.storyboardName = @"QWGame";
    vo.storyboardID = @"detail";
    
    [[QWRouter sharedInstance] registerRouterVO:vo withKey:@"gamedetail"];
}

- (void)addBlurView {
    
    self.bookImageView = [UIImageView new];
    self.bookImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.bookImageView.clipsToBounds = YES;

    if (IOS_SDK_MORE_THAN(8.0)) {
        self.blurView = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        self.blurView.translatesAutoresizingMaskIntoConstraints = NO;
        self.blurView.alpha = .9f;
        [self.bookImageView addSubview:self.blurView];
        [self.blurView autoCenterInSuperview];
        [self.blurView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.bookImageView];
        [self.blurView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.bookImageView withMultiplier:3.0];
        
    }else {
        UIView *view = [UIView new];
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        [self.bookImageView addSubview:view];
        [view autoCenterInSuperview];
        [view autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.bookImageView];
        [view autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.bookImageView withMultiplier:3.0];
    }
    self.tableView.parallaxHeader.view = self.bookImageView;
    self.tableView.parallaxHeader.height = 230;
    self.tableView.parallaxHeader.mode = MXParallaxHeaderModeFill;
//    self.tableView.parallaxHeader.minimumHeight = 64;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addBlurView];
    self.headView = [QWGameDetailHeadView createWithNib];
    self.headView.delegate = self;
    self.headView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView.parallaxHeader setStickyView:self.headView withHeight:230];
//
//
    self.automaticallyAdjustsScrollViewInsets = NO;
//    if(ISIPHONEX){
//        if (@available(iOS 11.0, *)) {
//            UIWindow *window = UIApplication.sharedApplication.keyWindow;
//            CGFloat bottomPadding = window.safeAreaInsets.bottom;
//            self.tableHeightConstraint.constant = -bottomPadding;
//        }
//
//    }
    if(!ISIPHONEX){
        
        self.tableView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0);
    }else{
        self.tableView.contentInset = UIEdgeInsetsMake(-44, 0, 0, 0);
    }
    if (@available(iOS 11.0, *)) {
        UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
        [self.footerView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor].active = true;
    }
    self.tableView.emptyView.errorImage = [UIImage imageNamed:@"empty_5_none"];
    self.tableView.emptyView.errorMsg = @"没有找到该演绘~";

    if (self.extraData) {
        self.book_url = [self.extraData objectForCaseInsensitiveKey:@"book_url"];
        self.book_name = [self.extraData objectForCaseInsensitiveKey:@"book_name"];
        self.bookId = [[self.extraData objectForCaseInsensitiveKey:@"id"] toNumberIfNeeded].stringValue;
    }

    if (self.book_url.length) {
        WEAK_SELF;
        self.tableView.emptyView.showError = NO;
        [self.logic getDetailWithBookUrl:self.book_url andCompleteBlock:^(id aResponseObject, NSError *anError) {
            STRONG_SELF;
            if (anError) {
                self.tableView.parallaxHeader.height = 0;
                
                if ([anError.localizedDescription rangeOfString:@"404"].location != NSNotFound) {
                    self.tableView.emptyView.errorMsg = @"没有找到该演绘~";
                }
            }

            if (!anError) {
                [self getData];
            }

            [self configNavigationBar];
            self.tableView.emptyView.showError = YES;
        }];
    }
    else if (self.bookId.length) {
        WEAK_SELF;
        self.tableView.emptyView.showError = NO;
        [self.logic getDetailWithBookId:self.bookId andCompleteBlock:^(id aResponseObject, NSError *anError) {
            STRONG_SELF;
            if (anError) {
                self.tableView.parallaxHeader.height = 0;
                if ([anError.localizedDescription rangeOfString:@"404"].location != NSNotFound) {
                    self.tableView.emptyView.errorMsg = @"没有找到该演绘~";
                }
            }

            if (!anError) {
                [self getData];
            }

            [self configNavigationBar];
            self.tableView.emptyView.showError = YES;
        }];
    }
    //显示奖券通知
    WEAK_SELF;
    [self observeNotification:@"gameTicketParams" withBlock:^(__weak id self, NSNotification *notification) {
        KVO_STRONG_SELF;
        if (!notification) {
            return ;
        }
        weakSelf.ticketData = [NSDictionary new];
        NSDictionary *dict = notification.object;
        NSString *url = dict[@"content_url"];
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[@"token"] = [QWGlobalValue sharedInstance].token;
        QWOperationParam *param = [QWInterface postWithUrl:url params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
            if (aResponseObject && !anError) {
                weakSelf.ticketData = aResponseObject[@"data"];
                if ([weakSelf.ticketData[@"num"] intValue] >0) {
                    [weakSelf showTicketWhenSeccess];
                }
            }
        }];
        param.requestType = QWRequestTypePost;
        [weakSelf.operationManager requestWithParam:param];
    }];
}

- (void)resize:(CGSize)size
{
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if (!self.logic.attention) {
//
//    }
//    else {
//
//    }
    

    if (!self.logic.check) {
        [self check];
    }
    else {
        [self.tableView reloadData];
    }
    
    [self getAttention];
    [self getRelation];
    [self.tableView reloadData];
    [self configNavigationBar];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

#define HEIGHT_LENGTH 64

- (void)configNavigationBar
{
    if (self.tableView.contentOffset.y > HEIGHT_LENGTH + 64) {
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:nil];
        self.navigationItem.leftBarButtonItem.tintColor = HRGB(0x505050);
        self.shareBtn.tintColor = HRGB(0x505050);
        self.title = self.logic.bookVO.nid.stringValue;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    else if (self.tableView.contentOffset.y > HEIGHT_LENGTH) {
        CGFloat alpha = (self.tableView.contentOffset.y - HEIGHT_LENGTH) / 64;
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[HRGB(0xF8F8F8) colorWithAlphaComponent:alpha]] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[UIImage imageWithColor:[HRGB(0xF8F8F8) colorWithAlphaComponent:alpha]]];
        self.navigationItem.leftBarButtonItem.tintColor = HRGB(0x505050);
        self.shareBtn.tintColor = HRGB(0x505050);
        self.title = nil;
    }
    else {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
        self.navigationItem.leftBarButtonItem.tintColor = HRGB(0xF8F8F8);
        self.shareBtn.tintColor = HRGB(0xF8F8F8);
        self.title = nil;
        [self setNeedsStatusBarAppearanceUpdate];
    }

    if (!self.logic.bookVO) {
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:nil];
        self.navigationItem.leftBarButtonItem.tintColor = HRGB(0x505050);
        self.shareBtn.tintColor = HRGB(0x505050);
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.tableView.contentOffset.y > HEIGHT_LENGTH || !self.logic.bookVO) {
        return UIStatusBarStyleDefault;
    }
    else {
        return UIStatusBarStyleLightContent;
    }
}

- (QWGameDetailLogic *)logic
{
    if (!_logic) {
        _logic = [QWGameDetailLogic logicWithOperationManager:self.operationManager];
    }

    return _logic;
}

- (QWUserLogic *)userLogic
{
    if (!_userLogic) {
        _userLogic = [QWUserLogic logicWithOperationManager:self.operationManager];
    }

    return _userLogic;
}

- (QWDiscussLogic *)discusslogic
{
    if (!_discusslogic) {
        _discusslogic = [QWDiscussLogic logicWithOperationManager:self.operationManager];
    }

    return _discusslogic;
}

- (void)getData
{
    self.logic.bookVO.game = YES;
    BookCD *bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == YES", self.logic.bookVO.nid] inContext:[QWFileManager qwContext]];
    if (!bookCD) {//如果没有阅读过，则创建一个
        bookCD = [BookCD MR_createEntityInContext:[QWFileManager qwContext]];
    }
    [bookCD updateWithBookVO:self.logic.bookVO];
    bookCD.lastReadTime = [NSDate date];
    bookCD.read = YES;
    [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];

    self.navigationItem.rightBarButtonItem = self.shareBtn;

    [self.tableView reloadData];
//    [self showChargeIntro];
    [self getAttention];
    [self getRelation];
    [self getLike];
    [self getRelativeFav];

//    [self check];
    self.logic.check = @1;
    [self.gotoReadingBtn setTitle:@"立即开始" forState:UIControlStateNormal];

    [self update];
}

- (void)getGameComments
{
    WEAK_SELF;
    if(self.logic.bookVO.nid){
        [self.gameCommentslogic getCommentsWithCompleteBlock:self.logic.bookVO.nid workType:[NSNumber numberWithInt:2] andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            STRONG_SELF;
            [self.tableView reloadData];
        }];
    }
}

- (void)getAttention
{
    if (! [QWGlobalValue sharedInstance].isLogin) {
        return;
    }

    WEAK_SELF;
    [self.logic getAttentionWithCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        self.collectionBtn.selected = self.logic.attention.boolValue;
        self.collectionLabel.text = @"加入书单";//self.collectionBtn.selected ? @"已收藏" : @"收藏";

        [self.tableView reloadData];
    }];
}

- (void)getRelation
{
    if (! [QWGlobalValue sharedInstance].isLogin) {
        return;
    }
    
    self.userLogic.userVO = self.logic.bookVO.author.firstObject;
    if (self.userLogic.userVO) {
        WEAK_SELF;
        [self.userLogic getUserRelationWithUrl:self.userLogic.userVO.relationship_url completeBlock:^(id aResponseObject, NSError *anError) {
            STRONG_SELF;
            [self.tableView reloadData];
        }];
    }
}

- (void)showChargeIntro
{
    [QWChargeIntroView showOnView:self.view];
}

- (void)update
{
//    [self getHeavyCharge];
//    [self getCharge];
    [self getAward];
    [self getFaith];
    [self getGameComments];
    [self getDiscuss];
}

- (void)check
{
    if (! [QWGlobalValue sharedInstance].isLogin) {
        return;
    }

    WEAK_SELF;
    [self.logic checkWithCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (self.logic.check.boolValue) {
            [self.gotoReadingBtn setTitle:@"立即开始" forState:UIControlStateNormal];
        }
    }];
}

- (void)getAward {
    WEAK_SELF;
    [self.logic getAwardDymicPageWithCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        [self.tableView reloadData];
    }];
}

- (void)getFaith {
    WEAK_SELF;
    [self.logic getFaithPageWithCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        [self.tableView reloadData];
    }];
}

- (void)getHeavyCharge
{
    WEAK_SELF;
    [self.logic getHeavyChargeWithCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        [self.tableView reloadData];
    }];
}

- (void)getCharge
{
    WEAK_SELF;
    [self.logic getChargeWithCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        [self.tableView reloadData];
    }];
}

- (void)getDiscuss
{
    WEAK_SELF;
    [self.logic getDiscussLastCountWithCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        [self.tableView reloadData];
    }];

    [self.discusslogic getDiscussWithUrl:self.logic.bookVO.bf_url andCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        [self.tableView reloadData];
    }];
}

- (void)getLike
{
    WEAK_SELF;
    [self.logic getLikeWithCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        [self.tableView reloadData];
    }];
}

- (void)getRelativeFav
{
    WEAK_SELF;
    if(self.logic.bookVO.nid){
        [self.gameCommentslogic getRelativeFavoriteWithCompleteBlock:self.logic.bookVO.nid workType:[NSNumber numberWithInt:2] andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            STRONG_SELF;
            [self.tableView reloadData];
        }];
    }
}

- (void)doCharge:(BOOL)heavy
{
    [(QWTBC *)self.tabBarController doChargeWithBook:self.logic.bookVO heavy:heavy];
}

- (void)onPressedShareBtn:(id)sender
{
    BookVO *book = self.logic.bookVO;
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"title"] = book.title;
    params[@"image"] = book.cover;
    params[@"intro"] = book.intro;
    params[@"url"] = book.share_url;
    params[@"type"] = @"game";
    params[@"workId"] = [NSString stringWithFormat:@"%@",book.nid];
    [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"share" andParams:params]];
}

- (IBAction)onPressedCollectionBtn:(id)sender {
    
    BookVO *book = self.logic.bookVO;
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"id"] = book.nid;
    params[@"type"] = @"game";
    params[@"isCollection"] = self.logic.attention;
    params[@"surl"] = self.logic.attention.boolValue ? self.logic.bookVO.unsubscribe_url : self.logic.bookVO.subscribe_url;
    [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"addCollection" andParams:params]];
    
//    WEAK_SELF;
//    [self showLoading];
//    [self.logic doAttentionWithCompleteBlock:^(id aResponseObject, NSError *anError) {
//        STRONG_SELF;
//        if (!anError) {
//            NSNumber *code = aResponseObject[@"code"];
//            if (code && ! [code isEqualToNumber:@0]) {//有错误
//                NSString *message = aResponseObject[@"data"];
//                if (message.length) {
//                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
//                }
//                else {
//                    [self showToastWithTitle:@"收藏失败" subtitle:nil type:ToastTypeError];
//                }
//            }
//            else {
//                self.collectionBtn.selected = self.logic.attention.boolValue;
//                self.collectionLabel.text = self.collectionBtn.selected ? @"已收藏" : @"收藏";
//
//                [self.tableView reloadData];
//            }
//        }
//        else {
//            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
//        }
//        [self hideLoading];
//    }];
}

- (IBAction)onPressedChargeBtn:(id)sender {
    [(QWTBC *)self.tabBarController doChargeWithBook:self.logic.bookVO heavy:YES];
}

- (IBAction)onPressedReadingBtn:(id)sender {
    if (self.logic.canRead == NO) {
        QWAnnouncementView *view = [[QWAnnouncementView alloc] initWithFrame2:CGRectMake(0, 0, UISCREEN_WIDTH, UISCREEN_HEIGHT)];
        [self.view addSubview:view];
    }
    else{
        
   
    if ([QWGlobalValue sharedInstance].isLogin && [QWGlobalValue sharedInstance].channel_token == nil) {
        [self.logic getChannelTokenWithCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            if (aResponseObject && !anError) {
                [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"game" andParams:@{@"content_url": self.logic.bookVO.content_url, @"url": self.logic.bookVO.url, @"id":self.logic.bookVO.nid}]];
                
            }
            else {
                [self showToastWithTitle:@"获取channel_token失败，请重新登录" subtitle:nil type:ToastTypeError];
            }
        }];
    }
    else  {
        if (self.logic.check.boolValue) {
            [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"game" andParams:@{@"content_url": self.logic.bookVO.content_url, @"url": self.logic.bookVO.url, @"id":self.logic.bookVO.nid}]];
            //        QWGameVC *vc = [[QWGameVC alloc] init];
            //        vc.contentUrl = self.logic.bookVO.content_url;
            //        vc.bookUrl = self.logic.bookVO.url;
            //        vc.modalPresentationStyle = UIModalPresentationFullScreen;
            //        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            //        [self presentViewController:vc animated:YES completion:nil];
        }
        else {
            if ([QWGlobalValue sharedInstance].user.gold.integerValue >= self.logic.bookVO.current_price.integerValue) {
                UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"提示" message:[NSString stringWithFormat:@"是否花%@重石购买此演绘", self.logic.bookVO.current_price]];
                [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];
                
                WEAK_SELF;
                [alertView bk_addButtonWithTitle:@"确认购买" handler:^{
                    STRONG_SELF;
                    [self showLoading];
                    [self.logic doBuyWithCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
                        STRONG_SELF;
                        if (!anError) {
                            NSNumber *code = aResponseObject[@"code"];
                            if (code && ! [code isEqualToNumber:@0]) {//有错误
                                NSString *message = aResponseObject[@"data"];
                                if (message.length) {
                                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                                }
                                else {
                                    [self showToastWithTitle:@"购买失败" subtitle:nil type:ToastTypeError];
                                }
                            }
                            else {
                                self.logic.check = @1;
                                [self showToastWithTitle:@"购买成功" subtitle:nil type:ToastTypeError];
                                [self.gotoReadingBtn setTitle:@"立即开始" forState:UIControlStateNormal];
                            }
                        }
                        else {
                            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
                        }
                        [self hideLoading];
                    }];
                }];
                
                [alertView show];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"提示" message:@"重石余额不足"];
                [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];
                [alertView bk_addButtonWithTitle:@"去充值" handler:^{
                    [(QWTBC *)self.tabBarController doCharge];
                }];
                
                [alertView show];
            }
        }
    }
    }

}

#pragma mark - QWDetailHeadTVCellDelegate

- (void)headCell:(QWGameDetailHeadTVCell *)headCell didClickedAttentionBtn:(id)sender
{
    if (! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        return;
    }

    if (!self.userLogic.userVO.follow_url.length) {
        return;
    }
    if (self.userLogic.myself.integerValue == 1) {
        return;
    }
    WEAK_SELF;
    [self showLoading];
    [self.userLogic doFriendAttentionWithCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"data"];
                if (message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:@"关注失败" subtitle:nil type:ToastTypeError];
                }
            }
            else {
                [self.tableView reloadData];
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }
        [self hideLoading];
    }];
}

- (void)headCell:(QWGameDetailHeadTVCell *)headCell didClickedShowAllBtn:(id)sender
{
    self.showAll = YES;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - table view

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self configNavigationBar];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.logic.bookVO) {
        return QWDetailTypeCount;
    }
    else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == QWDetailTypeHead || section == QWDetailTypeDiscuss || section == QWDetailTypeBookComments) {
        return 1;
    }
    else if (section == QWDetailAward) {
        if (self.logic.awardDymicPageVO.results.count > 0) {
            return 1 + self.logic.awardDymicPageVO.results.count;
        }
        else {
            return 2;
        }
    }
    else {
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == QWDetailTypeHead) {

        if (self.showAll) {
            return self.height;
        }

        return [QWGameDetailHeadTVCell minHeightWithBook:self.logic.bookVO];
    }
    else if (indexPath.section == QWDetailTypeRelated && indexPath.row == 1) {
        return [QWGameDetailRelatedTVCell heightForCellData:nil];
    }
    else if ((indexPath.section == QWDetailTypeFavoriteRelated && indexPath.row == 1)){
        return [QWDetailFavoriteRelatedTVCell heightForCellData:nil];
    }
    else if ((indexPath.section == QWDetailTypeFaith) && indexPath.row == 1) {
        return  85;
    }
    else if (indexPath.section == QWDetailAward && indexPath.row == 1 && self.logic.awardDymicPageVO.results.count == 0) {
        return 49 * 3;
    }

    else {
        return 49;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return PX1_LINE * 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == QWDetailTypeHead) {
        QWGameDetailHeadTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"head" forIndexPath:indexPath];
        [self.bookImageView qw_setImageUrlString:[QWConvertImageString convertPicURL:self.logic.bookVO.cover imageSizeType:QWImageSizeTypeGameCover] placeholder:nil animation:YES];
        [self.headView updateWithBook:self.logic.bookVO];

        self.height = [cell heightWithBook:self.logic.bookVO];
        
        [cell updateWithData:self.logic.bookVO andAttention:self.userLogic.follow isMyself:self.userLogic.myself discussCount:self.discusslogic.discussVO.count showAll:self.showAll];
        cell.delegate = self;
        return cell;
    }
    else if (indexPath.section == QWDetailTypeFavoriteRelated && indexPath.row == 1) {
        QWDetailFavoriteRelatedTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"relatedfavcell" forIndexPath:indexPath];
        [cell updateWithListVO:self.gameCommentslogic.relatetiveFavoritesVO];
        return cell;
    }
    else if (indexPath.section == QWDetailTypeRelated && indexPath.row == 1) {
        QWGameDetailRelatedTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"relatedcell" forIndexPath:indexPath];
        [cell updateWithListVO:self.logic.likeList];
        return cell;
    }
    else if (indexPath.section == QWDetailTypeFaith && indexPath.row == 1) {
        QWDetailLargeChargeTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chargecell" forIndexPath:indexPath];
        [cell updateChagreWithListVO:self.logic.faithPageVO chargeType:@2];
        cell.doChargeBlock = ^(){
            [self doCharge:true];
        };
        return cell;
    }
    else {
        if (indexPath.section == QWDetailTypeDiscuss) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.imageView.image = [UIImage imageNamed:@"detail_list_icon_3"];
            cell.textLabel.attributedText = nil;

            BookCD *bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == YES", self.logic.bookVO.nid] inContext:[QWFileManager qwContext]];

            BOOL showTag = YES;
            if (bookCD.lastViewDiscuss.isToday) {
                showTag = NO;
            }

            if (showTag && self.logic.discussLastCount.integerValue > 0) {
                NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
                [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"讨论 " attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.f], NSForegroundColorAttributeName: HRGB(0x505050)}]];
                NSTextAttachment *attachment = [NSTextAttachment new];
                attachment.bounds = CGRectMake(0, -4, 26, 17);
                attachment.image = [UIImage imageNamed:@"detail_new_discuss"];
                [attributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
                cell.textLabel.attributedText = attributedString;
            }
            else {
                cell.textLabel.text = @"讨论";
            }

            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            if (self.discusslogic.discussVO.count.integerValue > 0) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"共%@条", self.discusslogic.discussVO.count];
            }
            else {
                cell.detailTextLabel.text = @" ";
            }
            return cell;
        }
        else if (indexPath.section == QWDetailTypeBookComments){
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.imageView.image = [UIImage imageNamed:@"detail_list_icon_comments"];
            cell.textLabel.attributedText = nil;
            BookCD *bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == YES", self.logic.bookVO.nid] inContext:[QWFileManager qwContext]];
            
            if (!bookCD.lastViewBookComments || [bookCD.lastViewBookComments compare:[self.gameCommentslogic.commentsVO.results.firstObject updated_time]] == NSOrderedAscending) {
                NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
                [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"书评 " attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.f], NSForegroundColorAttributeName: HRGB(0x505050)}]];
                NSTextAttachment *attachment = [NSTextAttachment new];
                attachment.bounds = CGRectMake(0, -4, 26, 17);
                attachment.image = [UIImage imageNamed:@"detail_new_discuss"];
                [attributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
                cell.textLabel.attributedText = attributedString;
            }
            else {
                cell.textLabel.text = @"书评";
            }
            
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right_pink"]];
            if (self.gameCommentslogic.commentsVO.count > 0) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"共%@条", self.gameCommentslogic.commentsVO.count];
                cell.detailTextLabel.textColor = [UIColor colorQWPinkDark];
            }
            else {
                cell.detailTextLabel.text = @" ";
            }
            
            return cell;
        }
        else if (indexPath.section == QWDetailAward) {
            if (indexPath.row == 0) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
                cell.imageView.image = [UIImage imageNamed:@"detail_list_icon_award"];
                cell.textLabel.attributedText = nil;
                cell.textLabel.text = @"投石动态";
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.detailTextLabel.text = @" ";
                return cell;
            }
            else {
                if (self.logic.awardDymicPageVO.results.count) {
                    QWDetailChargeTVCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:@"charge" forIndexPath:indexPath];
                    //                    [cell updateWithUser:self.logic.heavyUserPageVO.results[indexPath.row - 1]];
                    //                    [cell updateWithUserGold:self.logic.heavyUserPageVO.results[indexPath.row - 1]];
                    [cell updateWithUser:self.logic.awardDymicPageVO.results[indexPath.row -1]];
                    [cell updateAwardWithUserVO:self.logic.awardDymicPageVO.results[indexPath.row -1]];
                    
                    return cell;
                }
                else {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chargeempty" forIndexPath:indexPath];
                    UILabel *emptyLabel = [cell viewWithTag:444];
                    emptyLabel.text = @"暂无投石动态";
                    return cell;
                }
            }
        }
        else if (indexPath.section == QWDetailTypeFaith && indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.imageView.image = [UIImage imageNamed:@"detail_list_icon_7"];
            cell.textLabel.attributedText = nil;
            cell.textLabel.text = @"信仰殿堂";
            if (self.logic.faithPageVO.results.count) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.detailTextLabel.text = @"查看更多";
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.detailTextLabel.text = @" ";
            }
            return cell;
        }
        else if(indexPath.section == QWDetailTypeRelated && indexPath.row == 0){
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.imageView.image = [UIImage imageNamed:@"detail_list_icon_5"];
            cell.textLabel.attributedText = nil;
            cell.textLabel.text = @"系列作品";

            if (self.logic.likeList.count.integerValue) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                if (self.logic.likeList.count.integerValue > 99) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"共99+部作品"];
                }
                else {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"共%d部作品", (int)self.logic.likeList.count.integerValue];
                }
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.detailTextLabel.text = @" ";
            }

            return cell;
        }
        else{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.imageView.image = [UIImage imageNamed:@"detail_list_icon_8"];
            cell.textLabel.attributedText = nil;
            cell.textLabel.text = @"相关书单";
            
            if (self.gameCommentslogic.relatetiveFavoritesVO.count.integerValue > 0) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"查看更多"];
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.detailTextLabel.text = @" ";
            }
            
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == QWDetailTypeDiscuss) {
        if (self.logic.canRead == NO) {
            QWAnnouncementView *view = [[QWAnnouncementView alloc] initWithFrame2:CGRectMake(0, 0, UISCREEN_WIDTH, UISCREEN_HEIGHT)];
            [self.view addSubview:view];
        }
        else{
            BookCD *bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == YES", self.logic.bookVO.nid] inContext:[QWFileManager qwContext]];
            if (self.logic.discussLastCount.integerValue > 0) {
                bookCD.lastViewDiscuss = [NSDate date];
            }
            [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];
            NSMutableDictionary *params = @{}.mutableCopy;
            params[@"url"] = self.logic.bookVO.bf_url;
            [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"discuss" andParams:params]];
        }
        
    }
    else if (indexPath.section == QWDetailTypeBookComments) {
        BookCD *bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == YES", self.logic.bookVO.nid] inContext:[QWFileManager qwContext]];
        if (!bookCD.lastViewBookComments || [bookCD.lastViewBookComments compare:[self.gameCommentslogic.commentsVO.results.firstObject updated_time]] == NSOrderedAscending) {
            bookCD.lastViewBookComments = [self.gameCommentslogic.commentsVO.results.firstObject updated_time];
        }
        
        [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"work_id"] = self.logic.bookVO.nid;
        params[@"work_type"] = [NSNumber numberWithInt:(2)];
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"book_comments" andParams:params]];
    }
    else if (indexPath.section == QWDetailTypeRelated && indexPath.row == 0 && self.logic.likeList.results.count) {
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"book_url"] = self.logic.bookVO.like_url;
        params[@"title"] =@"相关作品";
        params[@"hidefilter"] = @1;
        params[@"game"] = @1;
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"list" andParams:params]];
    }
    else if (indexPath.section == QWDetailTypeFavoriteRelated && indexPath.row == 0 && self.gameCommentslogic.relatetiveFavoritesVO.results.count) {
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"work_id"] = self.logic.bookVO.nid;
        params[@"title"] =@"相关书单";
        params[@"work_type"] = @2;
        params[@"type"] = @1;
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"relative_favorite" andParams:params]];
    }
    else if (indexPath.section == QWDetailTypeFaith) {
        if (indexPath.row == 0) {
            if (self.logic.faithPageVO.results.count == 0) {
                return;
            }
            NSMutableDictionary *params = @{}.mutableCopy;
            params[@"url"] = [NSString stringWithFormat:@"%@/game/%@/points/",[QWOperationParam currentDomain], self.logic.bookVO.nid];
            params[@"title"] = @"信仰殿堂";
            params[@"gold"] = @2;
            [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"userlist" andParams:params]];
        }
        else {
            if (self.logic.heavyUserPageVO.results.count == 0) {
                [self doCharge:YES];
                return ;
            }
        }
    }
    else if (indexPath.section == QWDetailAward) {
        if (self.logic.awardDymicPageVO.results.count == 0) {
            [self doCharge:true];
            return;
        }
        if (indexPath.row == 0) {
            return ;
        }
        
        UserVO *vo = self.logic.awardDymicPageVO.results[indexPath.row - 1];
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"profile_url"] = vo.user.profile_url;
        params[@"username"] = vo.user.username;
        
        if (vo.user.sex) {
            params[@"sex"] = vo.user.sex;
        }
        
        if (vo.user.avatar) {
            params[@"avatar"] = vo.user.avatar;
        }
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"user" andParams:params]];
    }

}

#pragma mark - 投票
-(void)createVoteBtn{
    BookVO *book = self.logic.bookVO;
    
    _voteId =book.extra[@"vote"];
    if (book.extra == nil) {
        
    }
    else{
        NSLog(@"vote1234 = %@",_voteId);
        if ([_voteId.stringValue isEqualToString:@"0"]) {
            
        }
        else{
            [self getVoteInfoData];
            [self getVoteActivityData];
            _voteBtn = [UIButton new];
            if(UISCREEN_HEIGHT == 812.0){//iphoneX
                _voteBtn.frame = CGRectMake(UISCREEN_WIDTH-98, 256, 98, 68);
            }
            else{
                _voteBtn.frame = CGRectMake(UISCREEN_WIDTH-98, 204, 98, 68);
            }
            
            [_voteBtn setImage:[UIImage imageNamed:@"按钮本体带投影"] forState:normal];
            [_voteBtn addTarget:self action:@selector(voteBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_voteBtn];
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getVoteInfoData) name:LOGIN_STATE_CHANGED object:nil];
        }
    }
    
}
-(void)getVoteInfoData{
    WEAK_SELF;
    [self.logic getVoteInfoWithCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        NSLog(@"voterest = %@",aResponseObject);
        self.voteInfo = [[QWVoteInfo alloc] initWithDictionary:aResponseObject];
    }];
}
-(void)getVoteActivityData{
    WEAK_SELF;
    [self.logic getVoteActivityInfoWithCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        NSLog(@"VoteActivity = %@",aResponseObject);
        NSDictionary *results = aResponseObject;
        NSDictionary *content = results[@"content"];
        NSArray *note = content[@"note"];
        NSMutableString *noteStr = [[NSMutableString alloc] init];
        //        for (NSString *str in note) {
        //            [noteStr appendString:[NSString stringWithFormat:@"%@\n",str]];
        //        }
        for (int i = 0; i < note.count; i++) {
            if (i == 0) {
                
            }
            else{
                
                [noteStr appendString:[NSString stringWithFormat:@"%@\n",note[i]]];
            }
        }
        self.voteActivityDic = @{@"title":results[@"title"],@"can_poll_score":[NSString stringWithFormat:@"%@",results[@"can_poll_score"]],@"content":noteStr,@"week":note[0]};
    }];
}
-(void)voteBtnClick{
    NSLog(@"click");
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        
        return;
    }
    
    [self createVoteView];
}
-(void)createVoteView{
    CGFloat width = UISCREEN_WIDTH-40;
    UIView *backView = [UIView new];
    [self.view addSubview:backView];
    backView.backgroundColor = [UIColor grayColor];
    backView.alpha = 0.7;
    backView.tag = 9999;
    backView.frame = CGRectMake(0, 0, UISCREEN_WIDTH, UISCREEN_HEIGHT);
    
    UIView *voteView = [UIView new];
    voteView.backgroundColor = [UIColor colorVote];
    voteView.layer.cornerRadius = 10;
    voteView.layer.masksToBounds = YES;
    voteView.tag = 9998;
    [self.view addSubview:voteView];
    
    UIButton *shutDownBtn = [UIButton new];
    shutDownBtn.frame = CGRectMake(UISCREEN_WIDTH-50, (UISCREEN_HEIGHT-461)/2-20, 40, 40);
    //    [shutDownBtn setTitle:@"x" forState:UIControlStateNormal];
    [shutDownBtn setImage:[UIImage imageNamed:@"关闭"] forState:UIControlStateNormal];
    [shutDownBtn setTitleColor:[UIColor colorVote] forState:UIControlStateNormal];
    shutDownBtn.titleLabel.font = FONT(20);
    shutDownBtn.layer.cornerRadius = 20;
    shutDownBtn.layer.masksToBounds = YES;
    shutDownBtn.layer.borderColor = [UIColor colorVote].CGColor;
    shutDownBtn.layer.borderWidth = 1;
    shutDownBtn.backgroundColor = [UIColor whiteColor];
    shutDownBtn.tag = 9997;
    [shutDownBtn addTarget:self action:@selector(shutDownClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shutDownBtn];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(14, 21, width, 20)];
    titleLab.textColor = HRGB(0xffffff);
    titleLab.font = [UIFont systemFontOfSize:14];
    titleLab.text = _voteActivityDic[@"title"];
    [voteView addSubview:titleLab];
    
    UILabel *viceTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(14, kMaxY(titleLab.frame)+16.4, 200, 20)];
    viceTitleLab.textColor = HRGB(0xffffff);
    viceTitleLab.font = [UIFont systemFontOfSize:18];
    viceTitleLab.text = self.voteInfo.title;
    [voteView addSubview:viceTitleLab];
    
    UILabel *weekLab = [[UILabel alloc] initWithFrame:CGRectMake(14, kMaxY(viceTitleLab.frame)+13.4, 200, 20)];
    weekLab.textColor = HRGB(0xffffff);
    weekLab.font = [UIFont systemFontOfSize:16.8];
    weekLab.text = _voteActivityDic[@"week"];
    [voteView addSubview:weekLab];
    
    UILabel *voteLab = [[UILabel alloc] initWithFrame:CGRectMake(14, kMaxY(weekLab.frame)+13.6, [QWSize autoWidth:self.voteInfo.score.stringValue width:2000 height:60 num:80], 60)];
    voteLab.textColor = HRGB(0xffffff);
    voteLab.font = [UIFont systemFontOfSize:60];
    voteLab.text = self.voteInfo.score.stringValue;
    voteLab.font = [UIFont fontWithName:@"Helvetica-Bold" size:60];
    [voteView addSubview:voteLab];
    
    UILabel *piaoLab = [[UILabel alloc] initWithFrame:CGRectMake(kMaxX(voteLab.frame)+10.3, kMaxY(weekLab.frame)+44.5, 20, 20)];
    piaoLab.textColor = HRGB(0xffffff);
    piaoLab.font = [UIFont systemFontOfSize:16.8];
    piaoLab.text = @"票";
    [voteView addSubview:piaoLab];
    
    UIImageView *jiangbeiImg = [UIImageView new];
    jiangbeiImg.image = [UIImage imageNamed:@"Group 14"];
    jiangbeiImg.frame = CGRectMake(width-89-22, 56, 89, 96);
    [voteView addSubview:jiangbeiImg];
    
    UILabel *rankLab = [[UILabel alloc] initWithFrame:CGRectMake(14, kMaxY(piaoLab.frame)+22.3, UISCREEN_WIDTH, 12)];
    rankLab.textColor = HRGB(0xffffff);
    rankLab.font = [UIFont systemFontOfSize:12];
    rankLab.text = [NSString stringWithFormat:@"当前排名：%@ ↑",self.voteInfo.rank];
    [voteView addSubview:rankLab];
    
    YYLabel *contentLab = [YYLabel new];
    NSString *introText = _voteActivityDic[@"content"];
    contentLab.numberOfLines = 0;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:introText attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:11], NSForegroundColorAttributeName: HRGB(0xffffff)}];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    attributedString.yy_lineSpacing = 11;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, contentLab.text.length)];
    CGSize size = CGSizeMake(UISCREEN_WIDTH - 20, CGFLOAT_MAX);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:size text:attributedString];
    contentLab.textLayout = layout;
    contentLab.frame = CGRectMake(14, kMaxY(rankLab.frame)+15.3, width-28, layout.textBoundingSize.height);
    [voteView addSubview:contentLab];
    
    UIView *dibuView = [UIView new];
    dibuView.frame = CGRectMake(0, kMaxY(contentLab.frame)+13.5, width, 144);
    dibuView.backgroundColor = [UIColor whiteColor];
    [voteView addSubview:dibuView];
    
    UIButton *minusBtn = [UIButton new];
    minusBtn.frame = CGRectMake(14, 12, 48, 48);
    [minusBtn setTitle:@"-" forState:UIControlStateNormal];
    minusBtn.titleLabel.font = FONT(20);
    [minusBtn setTitleColor:HRGB(0x3e3531) forState:UIControlStateNormal];
    minusBtn.backgroundColor = HRGB(0xf8f2ef);
    [minusBtn addTarget:self action:@selector(minusClick) forControlEvents:UIControlEventTouchUpInside];
    [dibuView addSubview:minusBtn];
    
    UIButton *addBtn = [UIButton new];
    addBtn.frame = CGRectMake(width-48-14, 12, 48, 48);
    [addBtn setTitle:@"+" forState:UIControlStateNormal];
    addBtn.titleLabel.font = FONT(20);
    [addBtn setTitleColor:HRGB(0x3e3531) forState:UIControlStateNormal];
    addBtn.backgroundColor = HRGB(0xf8f2ef);
    [addBtn addTarget:self action:@selector(addClick) forControlEvents:UIControlEventTouchUpInside];
    [dibuView addSubview:addBtn];
    
    UILabel *touLab = [[UILabel alloc] initWithFrame:CGRectMake(122.4, 25.3, 14, 16)];
    touLab.textColor = HRGB(0x51423b);
    touLab.font = [UIFont systemFontOfSize:13];
    touLab.text = @"投";
    [dibuView addSubview:touLab];
    
    UILabel *voteNumLab = [[UILabel alloc] initWithFrame:CGRectMake(kMaxX(touLab.frame), 9.7, width-244-14-14, 33.6)];
    voteNumLab.textColor = [UIColor colorVote];
    voteNumLab.textAlignment = NSTextAlignmentCenter;
    voteNumLab.font = [UIFont systemFontOfSize:33.6];
    voteNumLab.font = [UIFont fontWithName:@"Helvetica-Bold" size:33.6];
    voteNumLab.text = @"1";
    voteNumLab.tag = 9994;
    [dibuView addSubview:voteNumLab];
    
    UILabel *piao2Lab = [[UILabel alloc] initWithFrame:CGRectMake(width-122-14, 25.3, 14, 16)];
    piao2Lab.textColor = HRGB(0x51423b);
    piao2Lab.font = [UIFont systemFontOfSize:13];
    piao2Lab.text = @"票";
    [dibuView addSubview:piao2Lab];
    
    UILabel *shengyuLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 47, width, 13)];
    shengyuLab.textColor = HRGB(0xc0c0c0);
    shengyuLab.font = [UIFont systemFontOfSize:11];
    shengyuLab.text = [NSString stringWithFormat:@"还剩%@票免费人气票",self.voteInfo.can_poll_score];
    shengyuLab.textAlignment = NSTextAlignmentCenter;
    [dibuView addSubview:shengyuLab];
    
    UIButton *dibuVoteBtn = [UIButton new];
    dibuVoteBtn.frame = CGRectMake(14, kMaxY(addBtn.frame)+12, width-28, 60);
    [dibuVoteBtn setTitle:@"投票" forState:normal];
    dibuVoteBtn.layer.cornerRadius = 3.6;
    dibuVoteBtn.layer.masksToBounds = YES;
    dibuVoteBtn.backgroundColor = [UIColor colorVote];
    [dibuVoteBtn addTarget:self action:@selector(dibuVoteClick) forControlEvents:UIControlEventTouchUpInside];
    [dibuView addSubview:dibuVoteBtn];
    voteView.frame = CGRectMake(20, (UISCREEN_HEIGHT-461)/2, width, kMaxY(dibuView.frame));
    
    
    
    NSString *heavyStoneStr = @"";
    //    [QWGlobalValue sharedInstance].user.gold.stringValue = ;
    //    NSString *gold = [QWGlobalValue sharedInstance].user.gold.stringValue;
    NSString *gold = self.voteInfo.gold.stringValue;
    if  (gold != nil){
        heavyStoneStr = [NSString stringWithFormat:@"我的重石余额：%@",gold];
    }else {
        heavyStoneStr = @"我的重石余额：0";
    }
    UILabel *heavyStoneLab = [[UILabel alloc] initWithFrame:CGRectMake(20, kMaxY(voteView.frame)+14, [QWSize autoWidth:heavyStoneStr width:2000 height:12 num:12], 12)];
    heavyStoneLab.textColor = HRGB(0xffffff);
    heavyStoneLab.font = [UIFont systemFontOfSize:12];
    heavyStoneLab.text = heavyStoneStr;
    [self.view addSubview:heavyStoneLab];
    heavyStoneLab.tag = 9996;
    
    UIButton *topupBtn = [UIButton new];
    topupBtn.frame = CGRectMake(kMaxX(heavyStoneLab.frame)+15, kMaxY(voteView.frame)+14, [QWSize autoWidth:@"去充值" width:2000 height:12 num:12], 12);
    [topupBtn setTitle:@"去充值" forState:UIControlStateNormal];
    topupBtn.titleLabel.font = FONT(12);
    [topupBtn setTitleColor:[UIColor colorVote] forState:UIControlStateNormal];
    [topupBtn addTarget:self action:@selector(gototopupClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topupBtn];
    topupBtn.tag = 9995;
}
-(void)minusClick{
    UILabel *numLab = (UILabel *)[self.view viewWithTag:9994];
    
    if ([numLab.text isEqualToString:@"1"]) {
        
    }
    else{
        int num = numLab.text.intValue;
        num--;
        numLab.text = [NSString stringWithFormat:@"%d",num];
        
    }
}
-(void)addClick{
    UILabel *numLab = (UILabel *)[self.view viewWithTag:9994];
    int num = numLab.text.intValue;
    num++;
    numLab.text = [NSString stringWithFormat:@"%d",num];
    
}
-(void)shutDownClick{
    UIView *backView = [self.view viewWithTag:9999];
    [backView removeFromSuperview];
    UIView *voteView = [self.view viewWithTag:9998];
    [voteView removeFromSuperview];
    UIButton *btn = (UIButton *)[self.view viewWithTag:9997];
    [btn removeFromSuperview];
    UILabel *heavyStoneLab = (UILabel *)[self.view viewWithTag:9996];
    [heavyStoneLab removeFromSuperview];
    UIButton *btn2= (UIButton *)[self.view viewWithTag:9995];
    [btn2 removeFromSuperview];
    
}
-(void)dibuVoteClick{
    UILabel *numLab = (UILabel *)[self.view viewWithTag:9994];
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"item_id"] = self.voteInfo.id;
    params[@"score"] = numLab.text;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    QWOperationParam *param = [QWInterface postWithUrl:[NSString stringWithFormat:@"%@", self.voteInfo.poll_url] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            if ([aResponseObject[@"msg"] isEqualToString:@"success"]) {
                [self showToastWithTitle:@"投票成功" subtitle:nil type:ToastTypeAlert];
                
            }else{
                [self showToastWithTitle:aResponseObject[@"msg"] subtitle:nil type:ToastTypeAlert];
            }
            [self shutDownClick];
            [self getVoteInfoData];
            [self getVoteActivityData];
        }
        
    }];
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
    
}
#pragma mark - 奖券弹框
-(void)showTicketWhenSeccess{
    
    _ticketBackView = [UIView new];
    _ticketBackView.frame = CGRectMake(0, 0, UISCREEN_WIDTH, UISCREEN_HEIGHT);
    _ticketBackView.alpha = 0.8;
    _ticketBackView.backgroundColor = HRGB(0x000000);
    [self.view addSubview:_ticketBackView];
        [_ticketBackView bk_tapped:^{
            [self->_ticketBackView removeFromSuperview];
            [self->_ticketImgView removeFromSuperview];
            
        }];
    
    _ticketImgView = [UIImageView new];
    _ticketImgView.userInteractionEnabled = YES;
    _ticketImgView.frame = CGRectMake(16, (UISCREEN_HEIGHT-(UISCREEN_WIDTH-32)*0.793)/2, UISCREEN_WIDTH-32, (UISCREEN_WIDTH-32)*0.793);
    _ticketImgView.image = [UIImage imageNamed:@"弹窗"];
    [self.view addSubview:_ticketImgView];
    [_ticketImgView bk_tapped:^{
        //跳转到活动页面
        [self->_ticketBackView removeFromSuperview];
        [self->_ticketImgView removeFromSuperview];
        ActivityVO *vo = [ActivityVO voWithDict:self->_ticketData[@"activity"]];
        QWActivityPageVC *vc = [QWActivityPageVC createFromStoryboardWithStoryboardID:@"activitypage" storyboardName:@"QWActivity" bundleName:nil];
        vc.activityVO = vo;
        vc.inId = @"1";
        [self.navigationController pushViewController:vc animated:true];
    }];
    

}

@end
