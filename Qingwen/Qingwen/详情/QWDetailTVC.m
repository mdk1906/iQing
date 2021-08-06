//
//  QWDetailInformationTVC.m
//  Qingwen
//
//  Created by Aimy on 9/9/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWTableView.h"
#import "QWDetailCategoryTVCell.h"
#import "QWDetailTVC.h"
#import "QWDetailLogic.h"
#import "BookVO.h"
#import "ListVO.h"
#import "QWDetailHeadTVCell.h"
#import "QWDiscussTVCell.h"
#import "QWDiscussLogic.h"
#import "QWBookCommentsLogic.h"
#import "QWDetailRelatedTVCell.h"
#import "QWDetailFavoriteRelatedTVCell.h"
#import "QWDetailAttentionCell.h"
#import <UITableView+FDTemplateLayoutCell/UITableView+FDTemplateLayoutCell.h>
#import "BookCD.h"
#import "VolumeCD.h"
#import "QWDetailDirectoryVC.h"
#import "QWDiscussTVC.h"
#import "QWReadingManager.h"
#import "VolumeList.h"
#import "BookContinueReadingCD.h"
#import <ActionSheetPicker.h>
#import "NSDate+Utilities.h"
#import "QWTBC.h"
#import "QWSubscriberAlertTypeTwo.h"
#import "QWVoteInfo.h"
#import "QWAnnouncementView.h"
typedef NS_ENUM(NSInteger, QWDetailType) {
    QWDetailTypeHead = 0,
    QWDetailTypeAttention,
    QWDetailTypeDiscuss,
    QWDetailTypeDirectory,
    QWDetailTypeBookComments,
//    QWDetailTypeHeavyCharge,
//    QWDetailTypeCharge,
    QWDetailTypeFaith,    //豪无人性
    QWDetailSubscriber,         //订阅动态
    QWDetailAward,              //投石动态
    QWDetailTypeFavoriteRelated,
    QWDetailTypeRelated,
    QWDetailTypeCount,
    QWDetailTypeStoneCharge,  //轻石榜

};

@interface QWDetailTVC () <UITableViewDataSource, UITableViewDelegate, QWDetailHeadViewDelegate, QWDetailHeadTVCellDelegate, QWDetailAttentionCellDelegate, QWSummonsSelectViewDelegate>

@property (strong, nonatomic) IBOutlet QWTableView *tableView;

@property (nonatomic, strong) QWDetailLogic *logic;
@property (nonatomic, strong) QWDiscussLogic *discusslogic;
@property (nonatomic, strong) QWBookCommentsLogic *bookCommentslogic;
@property (nonatomic, strong) QWUserLogic *userLogic;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareBtn;

@property (nonatomic) BOOL showAll;

@property (nonatomic) CGFloat height;

@property (strong, nonatomic) IBOutlet UIButton *collectionBtn;
@property (strong, nonatomic) IBOutlet UILabel *collectionLabel;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tbHeightConstraint;

@property (strong,nonatomic) UIButton *voteBtn;
@property  (nonatomic, strong) NSNumber *voteId;
@property (nonatomic,strong) QWVoteInfo *voteInfo;
@property (nonatomic,strong) NSDictionary *voteActivityDic;
@property (strong, nonatomic) QWSummonsSelectView *selectedView;
//奖券view
@property (strong,nonatomic) UIView *ticketBackView;
@property (strong,nonatomic) UIImageView *ticketImgView;
@property (strong,nonatomic) NSArray *ticketData;
@end

@implementation QWDetailTVC

+ (void)load
{
    QWMappingVO *vo = [QWMappingVO new];
    vo.className = [NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject;
    vo.storyboardName = @"QWDetail";
    vo.storyboardID = @"detail";

    [[QWRouter sharedInstance] registerRouterVO:vo withKey:@"book"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.tableView.emptyView.errorImage = [UIImage imageNamed:@"empty_5_none"];
    self.tableView.emptyView.errorMsg = @"没有找到这本书~";

    float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (ver >= 10 && ver < 11) {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    }
    if(!ISIPHONEX){
        
        self.tableView.contentInset = UIEdgeInsetsMake(-64, 0, 44, 0);
    }else{
        self.tableView.contentInset = UIEdgeInsetsMake(-54, 0, 44, 0);
    }
    if (@available(iOS 11.0, *)) {
        UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
        [self.footerView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor].active = true;
    }
    
    
    
    
    
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
                if ([anError.localizedDescription rangeOfString:@"404"].location != NSNotFound) {
                    self.tableView.emptyView.errorMsg = @"没有找到这本书~";
                }
            }

            if (!anError) {
                NSNumber *code = aResponseObject[@"code"];
                if (code && [code isEqualToNumber:@-21]) {//有错误
                    NSString *message = aResponseObject[@"msg"];
                    self.tableView.emptyView.errorImage = [UIImage imageNamed:@"empty_7_none"];
                    self.tableView.emptyView.errorMsg = message;
                }else{
                    self.logic.bookVO = [BookVO voWithDict:aResponseObject];
                    [self getData];
                }
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
                if ([anError.localizedDescription rangeOfString:@"404"].location != NSNotFound) {
                    self.tableView.emptyView.errorMsg = @"没有找到这本书~";
                }
            }

            if (!anError) {
                NSNumber *code = aResponseObject[@"code"];
                if (code && [code isEqualToNumber:@-21]) {//有错误
                    NSString *message = aResponseObject[@"msg"];
                    self.tableView.emptyView.errorImage = [UIImage imageNamed:@"empty_7_none"];
                    self.tableView.emptyView.errorMsg = message;
                }else{
                    self.logic.bookVO = [BookVO voWithDict:aResponseObject];
                    [self getData];
                }
            }

            [self configNavigationBar];
            self.tableView.emptyView.showError = YES;
        }];
    }
    else if (self.book_name.length) {
        WEAK_SELF;
        self.tableView.emptyView.showError = NO;
        [self.logic getDetailWithBookName:self.book_name andCompleteBlock:^(id aResponseObject, NSError *anError) {
            STRONG_SELF;
            if (anError) {
                if ([anError.localizedDescription rangeOfString:@"404"].location != NSNotFound) {
                    self.tableView.emptyView.errorMsg = @"没有找到这本书~";
                }
            }

            if (!anError) {
                NSNumber *code = aResponseObject[@"code"];
                if (code && [code isEqualToNumber:@-21]) {//有错误
                    NSString *message = aResponseObject[@"msg"];
                    self.tableView.emptyView.errorImage = [UIImage imageNamed:@"empty_7_none"];
                    self.tableView.emptyView.errorMsg = message;
                }else{
                    self.logic.bookVO = [BookVO voWithDict:aResponseObject];
                    [self getData];
                }
            }

            [self configNavigationBar];
            self.tableView.emptyView.showError = YES;
        }];
    }
    
    
}

- (void)configReadingHistory
{
    BookContinueReadingCD *readingCD = [BookContinueReadingCD MR_findFirstByAttribute:@"bookId" withValue:self.logic.bookVO.nid inContext:[QWFileManager qwContext]];
    if (readingCD) {
        VolumeVO *volumeVO = self.logic.volumeList.results[readingCD.volumeIndex.integerValue];
        VolumeCD *volumeCD = [VolumeCD MR_findFirstByAttribute:@"nid" withValue:volumeVO.nid inContext:[QWFileManager qwContext]];
        if (!volumeCD) {
            volumeCD = [VolumeCD MR_createEntityInContext:[QWFileManager qwContext]];
            [volumeCD updateWithVolumeVO:volumeVO bookId:self.logic.bookVO.nid];
        }

        volumeCD.chapterIndex = readingCD.chapterIndex;
        volumeCD.location = readingCD.location;
        [volumeCD setReading];

        [readingCD MR_deleteEntityInContext:[QWFileManager qwContext]];
        [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];
    }
}

- (void)resize:(CGSize)size
{
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if (!self.logic.attention) {
//        [self getAttention];
//    }
//    else {
//        [self.tableView reloadData];
//    }
    [self getAttention];
    [self.tableView reloadData];
    [self configNavigationBar];
    self.tableView.tableFooterView = [UIView new];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    
}

#define HEIGHT_LENGTH 36

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

- (QWDetailLogic *)logic
{
    if (!_logic) {
        _logic = [QWDetailLogic logicWithOperationManager:self.operationManager];
    }

    return _logic;
}

- (QWDiscussLogic *)discusslogic
{
    if (!_discusslogic) {
        _discusslogic = [QWDiscussLogic logicWithOperationManager:self.operationManager];
    }

    return _discusslogic;
}

- (QWBookCommentsLogic *)bookCommentslogic
{
    if (!_bookCommentslogic) {
        _bookCommentslogic = [QWBookCommentsLogic logicWithOperationManager:self.operationManager];
    }
    
    return _bookCommentslogic;
}

- (QWUserLogic *)userLogic
{
    if (!_userLogic) {
        _userLogic = [QWUserLogic logicWithOperationManager:self.operationManager];
    }
    return _userLogic;
}

- (void)getData
{
    BookCD *bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == NO", self.logic.bookVO.nid] inContext:[QWFileManager qwContext]];
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
    [self update];
    [self createVoteBtn];
    
    [self.logic getAchievementInfoWithCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        
    }];
}

- (void)getAttention
{
    WEAK_SELF;
    [self.logic getAttentionWithCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        self.collectionBtn.selected = self.logic.attention.boolValue;
        NSLog(@"getAttention = %@",self.logic.attention);
        self.logic.bookVO.collection = self.logic.attention;
        self.collectionLabel.text = @"加入书单";//self.collectionBtn.selected ? @"加入书单" : @"加入书单";
        [self.tableView reloadData];
    }];
}

//引导页
- (void)showChargeIntro
{
    [QWChargeIntroView showOnView:self.view];
}

- (void)update
{
    [self getSubscriber];
    [self getAward];
    [self getFaith];
//    [self getHeavyCharge];
//    [self getCharge];
    [self getDiscuss];
    [self getBookComments];
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

- (void)getSubscriber {
    WEAK_SELF;
    [self.logic getSubscriberListWithCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        [self.tableView reloadData];
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

- (void)getBookComments
{
    WEAK_SELF;
    if(self.logic.bookVO.nid){
        [self.bookCommentslogic getCommentsWithCompleteBlock:self.logic.bookVO.nid workType:[NSNumber numberWithInt:1] andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            STRONG_SELF;
            [self.tableView reloadData];
        }];
    }
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
        [self.bookCommentslogic getRelativeFavoriteWithCompleteBlock:self.logic.bookVO.nid workType:[NSNumber numberWithInt:1] andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            STRONG_SELF;
            [self.tableView reloadData];
        }];
    }
}

- (void)doCharge:(BOOL)heavy
{
    [(QWTBC *)self.tabBarController doChargeWithBook:self.logic.bookVO heavy:heavy];
}

//订阅
- (void)doSubscriber {
    if (self.logic.bookVO.need_pay.boolValue == false) {
        [self showToastWithTitle:@"尚未有付费章节" subtitle:nil type:ToastTypeAlert];
        return;
    }
    [self showLoading];
    WEAK_SELF;
    [self.logic getSubscriberInfoWithCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (aResponseObject && !anError) {
           SubscriberVO *subscriberVO = [SubscriberVO voWithDict:aResponseObject];
            if (subscriberVO.amount.floatValue > 0) {
                QWSubscriberAlertTypeOne *alert = [QWSubscriberAlertTypeOne alertViewWithButtonAction:^(QWSubscriberActionType type) {
                }];
                [alert updateAlertWithSubscriberVO:subscriberVO];
                [alert show];
            }else {
                [self showToastWithTitle:@"暂无你需要订阅的章节＝－＝" subtitle:nil type:ToastTypeAlert];
            }
        }
        [self hideLoading];
    }];
}

- (void)onPressedShareBtn:(id)sender
{
    BookVO *book = self.logic.bookVO;
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"title"] = book.title;
    params[@"image"] = book.cover;
    params[@"intro"] = book.intro;
    params[@"url"] = book.share_url;
    params[@"type"] = @"book";
    params[@"workId"] = [NSString stringWithFormat:@"%@",book.nid];
    [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"share" andParams:params]];
}

- (IBAction)onPressedCollectionBtn:(id)sender {
    BookVO *book = self.logic.bookVO;
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"id"] = book.nid;
    params[@"type"] = @"book";
    params[@"isCollection"] = self.logic.attention;
    params[@"surl"] = self.logic.attention.boolValue ? self.logic.bookVO.unsubscribe_url : self.logic.bookVO.subscribe_url;
     [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"addCollection" andParams:params]];
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
//                if (self.logic.attention.boolValue) {
//                    [self showToastWithTitle:@"收藏成功" subtitle:nil type:ToastTypeAlert];
//                }else {
//                    [self showToastWithTitle:@"取消收藏" subtitle:nil type:ToastTypeAlert];
//                }
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
    NSLog(@"(QWTBC *)self.tabBarController = %@",(QWTBC *)self.tabBarController);
    NSLog(@"self.tabBarController = %@",self.tabBarController);
    if (self.tabBarController == NULL) {
        self.selectedView = [QWSummonsSelectView createWithNib];
        self.selectedView.type = 1;
        self.selectedView.chargeType = 0;
        self.selectedView.delegate = self;
        self.selectedView.frame = self.view.bounds;
        [self.selectedView updateDisplay];
        [self.view addSubview:self.selectedView];
    }
    else{
        [(QWTBC *)self.tabBarController doChargeWithBook:self.logic.bookVO heavy:YES];
    }
    
    
}

- (IBAction)onPressedReadingBtn:(id)sender {
    if (self.logic.volumeList) {
        [self gotoReadingWithBook:self.logic.bookVO volumes:self.logic.volumeList];
    }
    else {
        [self showLoading];
        WEAK_SELF;
        NSString *newUrl = [NSString stringWithFormat:@"%@?quick=true",self.logic.bookVO.chapter_url];
        [self.logic getDirectoryWithUrl:newUrl andCompleteBlock:^(id aResponseObject, NSError *anError) {
            STRONG_SELF;
            if ( ! anError) {
                if (self.navigationController.topViewController == self) {
                    [self gotoReadingWithBook:self.logic.bookVO volumes:self.logic.volumeList];
                }
            }

            [self hideLoading];
        }];
    }
}
- (IBAction)onPressedSubscriberBtn:(id)sender {
    [self doSubscriber];
}

#pragma mark - QWDetailHeadTVCellDelegate

- (void)headCell:(QWDetailHeadTVCell *)headCell didClickedChargeBtn:(id)sender
{
    [self doCharge:NO];
}

- (void)headCell:(QWDetailHeadTVCell *)headCell didClickedHeavyChargeBtn:(id)sender
{
    [self doCharge:YES];
}

- (void)headCell:(QWDetailHeadTVCell *)headCell didClickedDiscussBtn:(id)sender
{
    
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"url"] = self.logic.bookVO.bf_url;
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"discuss" andParams:params]];
    
    
}

- (void)headCell:(QWDetailHeadTVCell *)headCell didClickedShowAllBtn:(id)sender
{
    self.showAll = !self.showAll;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)headCell:(QWDetailHeadTVCell *)headCell didClickedAttentionBtn:(id)sender
{
    WEAK_SELF;
   
    [self showLoading];
    [self.logic doAttentionWithCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"data"];
                if (message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:@"收藏失败" subtitle:nil type:ToastTypeError];
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

- (void)headCell:(QWDetailHeadView *)headCell didClickedDirectoryBtn:(id)sender
{
    [self performSegueWithIdentifier:@"directory" sender:sender];
}

- (void)headCell:(QWDetailHeadView *)headCell didClickedGotoReadingBtn:(id)sender
{
    if (self.logic.volumeList) {
        [self gotoReadingWithBook:self.logic.bookVO volumes:self.logic.volumeList];
    }
    else {
        [self showLoading];
        WEAK_SELF;
        NSString *newUrl = [NSString stringWithFormat:@"%@?quick=true",self.logic.bookVO.chapter_url];
        [self.logic getDirectoryWithUrl:newUrl andCompleteBlock:^(id aResponseObject, NSError *anError) {
            STRONG_SELF;
            if ( ! anError) {
                if (self.navigationController.topViewController == self) {
                    [self gotoReadingWithBook:self.logic.bookVO volumes:self.logic.volumeList];
                }
            }

            [self hideLoading];
        }];
    }
}

#pragma mark - QWDetailHeadViewDelegate

- (void)headView:(QWDetailHeadView *)view didClickedShowAllBtn:(id)sender {
    self.showAll = YES;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}


- (void)headView:(QWDetailHeadView *)view didClickedDirectoryBtn:(id)sender
{
    [self performSegueWithIdentifier:@"directory" sender:sender];
}

- (void)headView:(QWDetailHeadView *)view didClickedGotoReadingBtn:(id)sender
{
    if (self.logic.volumeList) {
        [self gotoReadingWithBook:self.logic.bookVO volumes:self.logic.volumeList];
    }
    else {
        [self showLoading];
        WEAK_SELF;
        [self.logic getDirectoryWithUrl:self.logic.bookVO.chapter_url andCompleteBlock:^(id aResponseObject, NSError *anError) {
            STRONG_SELF;
            if ( ! anError) {
                if (self.navigationController.topViewController == self) {
                    [self gotoReadingWithBook:self.logic.bookVO volumes:self.logic.volumeList];
                }
            }

            [self hideLoading];
        }];
    }
}

- (void)headView:(QWDetailHeadView *)view didClickedChargeBtn:(id)sender
{
    [self doCharge:NO];
}

- (void)headView:(QWDetailHeadView *)view didClickedHeavyChargeBtn:(id)sender
{
    [self doCharge:YES];
}

#pragma mark - QWAttentionCellDelegate 

- (void)attentionCell:(QWDetailAttentionCell *)attentionCell didClickedAttentionBtn:(id)sender
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
    if (section == QWDetailTypeHead || section == QWDetailTypeAttention || section == QWDetailTypeDiscuss || section == QWDetailTypeDirectory || section == QWDetailTypeBookComments) {
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
    else if (section == QWDetailSubscriber) {
        if (self.logic.bookVO.need_pay.boolValue) {
            if (self.logic.subscriberPageVO.results.count > 0 ) {
                return 1 + self.logic.subscriberPageVO.results.count;
            }
            else {
                return 2;
            }
        }else {
            return 0;
        }
    }
    else {
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == QWDetailTypeHead) {
        CGFloat fullHeight = self.height;
        CGFloat minHeight = [QWDetailHeadView minHeightWithBook:self.logic.bookVO];
        
        if(ISIPHONEX){
            fullHeight = self.height + 64;
            minHeight += 54;
        }
        
        if (self.showAll) {
            return fullHeight;
        }
        return minHeight;
    }
    else if (indexPath.section == QWDetailTypeAttention) {
        return 60;
    }
    else if ((indexPath.section == QWDetailTypeFavoriteRelated && indexPath.row == 1)){
        return [QWDetailFavoriteRelatedTVCell heightForCellData:nil];
    }
    else if (indexPath.section == QWDetailTypeRelated && indexPath.row == 1) {
        return [QWDetailRelatedTVCell heightForCellData:nil];
    }
    else if ((indexPath.section == QWDetailTypeFaith || indexPath.section == QWDetailTypeStoneCharge) && indexPath.row == 1) {
        return  85;
    }
    else if (indexPath.section == QWDetailAward && indexPath.row == 1 && self.logic.awardDymicPageVO.results.count == 0) {
        return 49 * 3;
    }
    else if (indexPath.section == QWDetailSubscriber && indexPath.row == 1 && self.logic.subscriberPageVO.results.count == 0) {
        return 49 * 3;
    }
    else {
        return 49;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 2 * PX1_LINE;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == QWDetailTypeHead) {
        QWDetailHeadTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"head" forIndexPath:indexPath];
        [cell updateWithData:self.logic.bookVO andAttention:self.logic.attention discussCount:self.discusslogic.discussVO.count showAll:self.showAll];
        self.height = [cell.headView heightWithBook:self.logic.bookVO];
        cell.delegate = self;
        cell.headView.delegate = self;
        return cell;
    }
    else if (indexPath.section == QWDetailTypeAttention) {
        QWDetailAttentionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"attention" forIndexPath:indexPath];
        [cell updateAttentionCell:self.logic.bookVO.author.firstObject attention:self.userLogic.follow];
        cell.delegate = self;
        return cell;
    }
    else if (indexPath.section == QWDetailTypeFavoriteRelated && indexPath.row == 1) {
        QWDetailFavoriteRelatedTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"relatedfavcell" forIndexPath:indexPath];
        [cell updateWithListVO:self.bookCommentslogic.relatetiveFavoritesVO];
        return cell;
    }
    else if (indexPath.section == QWDetailTypeRelated && indexPath.row == 1) {
        QWDetailRelatedTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"relatedcell" forIndexPath:indexPath];
        [cell updateWithListVO:self.logic.likeList];
        return cell;
    }
    else if (indexPath.section == QWDetailTypeFaith && indexPath.row == 1) {
        QWDetailLargeChargeTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chargecell" forIndexPath:indexPath];
        [cell updateChagreWithListVO:self.logic.faithPageVO chargeType:@2];
        WEAK_SELF;
        cell.doChargeBlock = ^(){
            STRONG_SELF;
            [self doCharge:true];
        };
        return cell;
    }
    else if (indexPath.section == QWDetailTypeStoneCharge && indexPath.row == 1) {
        QWDetailLargeChargeTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chargecell" forIndexPath:indexPath];
        [cell updateChagreWithListVO:self.logic.userPageVO chargeType:@0];
        WEAK_SELF;
        cell.doChargeBlock = ^(){
            STRONG_SELF;
            [self doCharge:false];
        };
        return cell;
    }
    
    else {
        if (indexPath.section == QWDetailTypeDiscuss) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.imageView.image = [UIImage imageNamed:@"detail_list_icon_3"];
            cell.textLabel.attributedText = nil;

            BookCD *bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == NO", self.logic.bookVO.nid] inContext:[QWFileManager qwContext]];

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


            if (self.discusslogic.discussVO.count.integerValue > 0) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"共%@条", self.discusslogic.discussVO.count];
                cell.detailTextLabel.textColor = [UIColor colorQWPinkDark];
            }
            else {
                cell.detailTextLabel.text = @" ";
            }
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right_pink"]];
            return cell;
        }
        else if (indexPath.section == QWDetailTypeDirectory) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.imageView.image = [UIImage imageNamed:@"detail_list_icon_2"];
            cell.textLabel.attributedText = nil;

            BookCD *bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == NO", self.logic.bookVO.nid] inContext:[QWFileManager qwContext]];

            if (!bookCD.lastViewDirectory || [bookCD.lastViewDirectory compare:self.logic.bookVO.updated_time] == NSOrderedAscending) {
                NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
                [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"目录 " attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.f], NSForegroundColorAttributeName: HRGB(0x505050)}]];
                NSTextAttachment *attachment = [NSTextAttachment new];
                attachment.bounds = CGRectMake(0, -4, 26, 17);
                attachment.image = [UIImage imageNamed:@"detail_new_discuss"];
                [attributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
                cell.textLabel.attributedText = attributedString;
            }
            else {
                cell.textLabel.text = @"目录";
            }

            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right_pink"]];
            if (self.logic.bookVO.chapter_count.integerValue > 0) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"共%@章", self.logic.bookVO.chapter_count];
                cell.detailTextLabel.textColor = [UIColor colorQWPinkDark];
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
            BookCD *bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == NO", self.logic.bookVO.nid] inContext:[QWFileManager qwContext]];
            cell.textLabel.text = @"书评";
            if(self.bookCommentslogic.commentsVO.results.count > 0){
                if (!bookCD.lastViewBookComments || [bookCD.lastViewBookComments compare:[self.bookCommentslogic.commentsVO.results.firstObject updated_time]] == NSOrderedAscending) {
                    cell.textLabel.text = @"";
                    NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
                    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"书评 " attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.f], NSForegroundColorAttributeName: HRGB(0x505050)}]];
                    NSTextAttachment *attachment = [NSTextAttachment new];
                    attachment.bounds = CGRectMake(0, -4, 26, 17);
                    attachment.image = [UIImage imageNamed:@"detail_new_discuss"];
                    [attributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
                    cell.textLabel.attributedText = attributedString;
                }
            }
            
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right_pink"]];
            if (self.bookCommentslogic.commentsVO.count > 0) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"共%@条", self.bookCommentslogic.commentsVO.count];
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
        else if (indexPath.section == QWDetailSubscriber) {
            if (indexPath.row == 0) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
                cell.imageView.image = [UIImage imageNamed:@"detail_list_icon_subscriber"];
                cell.textLabel.attributedText = nil;
                cell.textLabel.text = @"订阅动态";
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.detailTextLabel.text = @" ";
                return cell;
            }
            else {
                if (self.logic.subscriberPageVO.results.count) {
                    QWDetailChargeTVCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:@"charge" forIndexPath:indexPath];
                    [cell updateWithSubscriber:self.logic.subscriberPageVO.results[indexPath.row - 1]];
                    [cell updateWithUser:self.logic.subscriberPageVO.results[indexPath.row - 1]];

                    return cell;
                }
                else {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chargeempty" forIndexPath:indexPath];
                    UILabel *emptyLabel = [cell viewWithTag:444];
                    emptyLabel.text = @"暂无订阅动态";
                    return cell;
                }
            }
        }
        //
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
        else if (indexPath.section == QWDetailTypeStoneCharge && indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.imageView.image = [UIImage imageNamed:@"detail_list_icon_6"];
            cell.textLabel.attributedText = nil;
            cell.textLabel.text = @"轻石榜";
            if (self.logic.userPageVO.results.count) {
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
            cell.textLabel.text = @"相关作品";

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
        }else{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.imageView.image = [UIImage imageNamed:@"detail_list_icon_8"];
            cell.textLabel.attributedText = nil;
            cell.textLabel.text = @"相关书单";
            
            if (self.bookCommentslogic.relatetiveFavoritesVO.count.integerValue > 0) {
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
        }else{
            BookCD *bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == NO", self.logic.bookVO.nid] inContext:[QWFileManager qwContext]];
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
        BookCD *bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == NO", self.logic.bookVO.nid] inContext:[QWFileManager qwContext]];
        if (!bookCD.lastViewBookComments || [bookCD.lastViewBookComments compare:[self.bookCommentslogic.commentsVO.results.firstObject updated_time]] == NSOrderedAscending) {
            bookCD.lastViewBookComments = [self.bookCommentslogic.commentsVO.results.firstObject updated_time];
        }
        
        [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"work_id"] = self.logic.bookVO.nid;
        params[@"work_type"] = [NSNumber numberWithInt:(1)];
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"book_comments" andParams:params]];
        //[self performSegueWithIdentifier:@"directory" sender:self];
    }
    else if (indexPath.section == QWDetailTypeDirectory) {
        BookCD *bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == NO", self.logic.bookVO.nid] inContext:[QWFileManager qwContext]];
        if (!bookCD.lastViewDirectory || [bookCD.lastViewDirectory compare:self.logic.bookVO.updated_time] == NSOrderedAscending) {
            bookCD.lastViewDirectory = [NSDate date];
        }

        [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];
        [self performSegueWithIdentifier:@"directory" sender:self];
    }
    else if (indexPath.section == QWDetailTypeFavoriteRelated && indexPath.row == 0 && self.bookCommentslogic.relatetiveFavoritesVO.results.count) {
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"work_id"] = self.logic.bookVO.nid;
        params[@"title"] =@"相关书单";
        params[@"work_type"] = @1;
        params[@"type"] = @1;
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"relative_favorite" andParams:params]];
    }
    else if (indexPath.section == QWDetailTypeRelated && indexPath.row == 0 && self.logic.likeList.results.count) {
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"book_url"] = self.logic.bookVO.like_url;
        params[@"title"] =@"相关作品";
        params[@"hidefilter"] = @1;
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"list" andParams:params]];
    }
    else if (indexPath.section == QWDetailTypeFaith) {
        if (indexPath.row == 0) {
            if (self.logic.faithPageVO.results.count == 0) {
                return;
            }
            NSMutableDictionary *params = @{}.mutableCopy;
            params[@"url"] = [NSString stringWithFormat:@"%@/book/%@/points/",[QWOperationParam currentDomain], self.logic.bookVO.nid];
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
    else if (indexPath.section == QWDetailSubscriber) {

        if (self.logic.subscriberPageVO.results.count == 0 ){
            if (self.logic.bookVO.need_pay.boolValue) {
                [self doSubscriber];
            }
             return ;
        }
        if (indexPath.row == 0) {
            return ;
        }
        UserVO *vo = self.logic.subscriberPageVO.results[indexPath.row - 1];
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
    else if (indexPath.section == QWDetailTypeStoneCharge && indexPath.row == 0) {
        if (self.logic.userPageVO.results.count == 0) {
            [self doCharge:NO];
            return ;
        }
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"url"] = [NSString stringWithFormat:@"%@merit_rank/", self.logic.bookVO.url];
        params[@"title"] = @"轻石榜";
        params[@"user_url"] = [NSString stringWithFormat:@"%@merit_rank_places/", self.logic.bookVO.url];
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"userlist" andParams:params]];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"directory"]) {
        QWDetailDirectoryVC *directoryVC = segue.destinationViewController;
        directoryVC.title = self.logic.bookVO.title;
        directoryVC.bookVO = self.logic.bookVO;
    }
}

- (void)gotoReadingWithBook:(BookVO *)book volumes:(VolumeList *)volumes
{
    if (self.logic.canRead == NO) {
        QWAnnouncementView *view = [[QWAnnouncementView alloc] initWithFrame2:CGRectMake(0, 0, UISCREEN_WIDTH, UISCREEN_HEIGHT)];
        [self.view addSubview:view];
    }
    else{
        
    
    [self configReadingHistory];

    if (volumes.results.count == 0) {
        [self showToastWithTitle:@"目录为空" subtitle:nil type:ToastTypeAlert];
        return;
    }

    //设置阅读进度
    {
        BookCD *bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == NO", book.nid] inContext:[QWFileManager qwContext]];
        if (!bookCD) {//如果没有阅读过，则创建一个
            bookCD = [BookCD MR_createEntityInContext:[QWFileManager qwContext]];
            [bookCD updateWithBookVO:book];
        }

        VolumeCD *volumeCD = [VolumeCD findLastReadingVolumeWithBookId:book.nid];
        if (!volumeCD) {
            volumeCD = [VolumeCD MR_createEntityInContext:[QWFileManager qwContext]];
            [volumeCD updateWithVolumeVO:volumes.results.firstObject bookId:book.nid];
            volumeCD.chapterIndex = @0;
            volumeCD.location = @0;
        }

        if ( ! [volumes.results filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"nid == %@", volumeCD.nid]].firstObject) {
            //未找到阅读记录
            UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"提示" message:@"未找到阅读记录是否从第一卷开始阅读"];

            [alertView bk_addButtonWithTitle:@"否" handler:^{

            }];

            WEAK_SELF;
            [alertView bk_addButtonWithTitle:@"是" handler:^{
                STRONG_SELF;
                VolumeCD *volumeCD = [VolumeCD MR_findFirstOrCreateByAttribute:@"nid" withValue:[self.logic.volumeList.results.firstObject nid] inContext:[QWFileManager qwContext]];
                [volumeCD updateWithVolumeVO:self.logic.volumeList.results.firstObject bookId:bookCD.nid];
                volumeCD.chapterIndex = @0;
                volumeCD.location = @0;
                [volumeCD setReading];
                [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];
                [[QWReadingManager sharedInstance] startOfflineReadingWithBookId:bookCD.nid volumes:self.logic.volumeList];

                QWDetailDirectoryVC *directoryVC = [self.storyboard instantiateViewControllerWithIdentifier:@"directory"];
                directoryVC.title = self.logic.bookVO.title;
                directoryVC.bookVO = self.logic.bookVO;
                directoryVC.volumeList = self.logic.volumeList;
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"QWReading" bundle:nil];
                UIViewController *vc = [sb instantiateInitialViewController];
                NSMutableArray *vcs = self.navigationController.viewControllers.mutableCopy;
                [vcs addObjectsFromArray:@[directoryVC, vc]];
                [self.navigationController setViewControllers:vcs animated:YES];

            }];

            [alertView show];

            return ;
        }

        [volumeCD setReading];
        [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];
    }

    //开始阅读
    [[QWReadingManager sharedInstance] startOnlineReadingWithBookId:book.nid volumes:self.logic.volumeList];
    QWDetailDirectoryVC *directoryVC = [self.storyboard instantiateViewControllerWithIdentifier:@"directory"];
    directoryVC.title = self.logic.bookVO.title;
    directoryVC.bookVO = self.logic.bookVO;
    directoryVC.volumeList = self.logic.volumeList;
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"QWReading" bundle:nil];
    UIViewController *vc = [sb instantiateInitialViewController];
    NSMutableArray *vcs = self.navigationController.viewControllers.mutableCopy;
    [vcs addObjectsFromArray:@[directoryVC, vc]];
    [self.navigationController setViewControllers:vcs animated:YES];
        
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
    rankLab.font = [UIFont systemFontOfSize:16];
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"当前排名：%@  ↑",self.voteInfo.rank]];
    [AttributedStr addAttribute:NSFontAttributeName
     
                          value:[UIFont systemFontOfSize:12.0]
     
                          range:NSMakeRange(0, 5)];
    rankLab.attributedText = AttributedStr;
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
    
    UILabel *touLab = [[UILabel alloc] initWithFrame:CGRectMake(122.4-20, 25.3, 14, 16)];
    touLab.textColor = HRGB(0x51423b);
    touLab.font = [UIFont systemFontOfSize:13];
    touLab.text = @"投";
    [dibuView addSubview:touLab];
    
    UILabel *voteNumLab = [[UILabel alloc] initWithFrame:CGRectMake(kMaxX(touLab.frame), 9.7, width-244-14-14+40, 33.6)];
    voteNumLab.textColor = [UIColor colorVote];
    voteNumLab.textAlignment = NSTextAlignmentCenter;
    voteNumLab.font = [UIFont systemFontOfSize:33.6];
    voteNumLab.font = [UIFont fontWithName:@"Helvetica-Bold" size:33.6];
    voteNumLab.text = @"1";
    voteNumLab.tag = 9994;
    [dibuView addSubview:voteNumLab];
    
    UILabel *piao2Lab = [[UILabel alloc] initWithFrame:CGRectMake(width-122-14+20, 25.3, 14, 16)];
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
        heavyStoneStr = [NSString stringWithFormat:@"%@%@",self.voteInfo.balance_info,gold];
    }else {
        heavyStoneStr = [NSString stringWithFormat:@"%@0",self.voteInfo.balance_info];
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
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/vote/%@/query_notify/",[QWOperationParam currentDomain],self.voteId] andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if ([aResponseObject[@"code"] intValue] == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"提示" message:aResponseObject[@"msg"]];
            [alertView bk_addButtonWithTitle:@"取消" handler:^{
            
                    }];
            WEAK_SELF;
            [alertView bk_addButtonWithTitle:@"确定" handler:^{
                STRONG_SELF;
                NSMutableDictionary *params = @{}.mutableCopy;
                params[@"item_id"] = self.voteInfo.id;
                params[@"score"] = numLab.text;
                params[@"token"] = [QWGlobalValue sharedInstance].token;
                QWOperationParam *param = [QWInterface postWithUrl:[NSString stringWithFormat:@"%@", self.voteInfo.poll_url] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
                    if (aResponseObject && !anError) {
                        if ([aResponseObject[@"msg"] isEqualToString:@"success"]) {
                            [self showToastWithTitle:@"投票成功" subtitle:nil type:ToastTypeAlert];
                            NSDictionary *data = aResponseObject[@"data"];
                            NSDictionary *activity_data = data[@"activity_data"];
                            if (activity_data[@"count"] != 0) {
                                NSArray *dataArr = activity_data[@"data"];
                                for (NSDictionary *res in dataArr) {
                                    NSString *url = res[@"content_url"];
                                    [self getTicketDataWithUrl:url];
                                }
                            }
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
            }];
            
            [alertView show];
        }
        else{
            
        }
    }];
    param.requestType = QWRequestTypeGet;
    [self.operationManager requestWithParam:param];

}
-(void)gototopupClick{
    [(QWTBC *)self.tabBarController doCharge];
}

#pragma mark - 奖券弹框
-(void)getTicketDataWithUrl:(NSString *)url{
    self.ticketData = [NSArray array];
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    QWOperationParam *param = [QWInterface postWithUrl:url params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            
            NSDictionary *data = aResponseObject[@"data"];
            if ([data[@"count"] intValue] >0) {
                self->_ticketData = data[@"prize"];
                [self showTicketWhenSeccess];
            }
            else{
                
            }
            
        }
    }];
    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

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
    CGFloat ticketHeight = UISCREEN_WIDTH*1.173;
    _ticketImgView = [UIImageView new];
    _ticketImgView.frame = CGRectMake(0, (UISCREEN_HEIGHT-ticketHeight)/2, UISCREEN_WIDTH, ticketHeight);
    _ticketImgView.image = [UIImage imageNamed:@"奖品"];
    [self.view addSubview:_ticketImgView];
    [_ticketImgView bk_tapped:^{
        //跳转到活动页面
    }];
    
//    NSArray *contentArr = @[@{@"content":@"京东",@"number":@"X1"},
//                            @{@"content":@"淘宝",@"number":@"X14"},
//                            @{@"content":@"天猫",@"number":@"X999"},
//                            @{@"content":@"轻文",@"number":@"X800"},
//                            @{@"content":@"bilbili",@"number":@"X5"}];
    CGFloat LabHeight = ticketHeight * 0.261 / 5;
    for (int i = 0; i<_ticketData.count; i++) {
        NSDictionary *dict = _ticketData[i];
        UILabel *contentLab = [[UILabel alloc] init];
        contentLab.frame = CGRectMake(UISCREEN_WIDTH*0.28, ticketHeight*0.46+LabHeight*i, [QWSize autoWidth:dict[@"name"] width:500 height:LabHeight num:13], LabHeight);
        contentLab.textColor = HRGB(0xffffff);
        contentLab.font = [UIFont systemFontOfSize:13];
        contentLab.textAlignment = 0;
        contentLab.text = dict[@"name"];
        [_ticketImgView addSubview:contentLab];
        
        UILabel *numberLab = [[UILabel alloc] init];
        NSString *numberStr = [NSString stringWithFormat:@"X%@",dict[@"num"]];
        numberLab.frame = CGRectMake(UISCREEN_WIDTH*0.7-[QWSize autoWidth:numberStr width:500 height:LabHeight num:13], ticketHeight*0.46+LabHeight*i, [QWSize autoWidth:numberStr width:500 height:LabHeight num:13], LabHeight);
        numberLab.textColor = HRGB(0xffffff);
        numberLab.textAlignment = 2;
        numberLab.font = [UIFont systemFontOfSize:13];
        numberLab.text = numberStr;
        [_ticketImgView addSubview:numberLab];
    }
    
    UILabel *noteLab = [[UILabel alloc] initWithFrame:CGRectMake(UISCREEN_WIDTH*0.176, ticketHeight *0.76, UISCREEN_WIDTH*0.635, [QWSize customAutoHeigh:@"虚拟奖品将在1月12日前发放到您的账户中~\n获得实体奖品，\n请您同客服娘QQ：3012575446联系，\n登记领奖信息呦~" width:UISCREEN_WIDTH*0.635 num:13])];
    noteLab.textColor = HRGB(0xffffff);
    noteLab.font = [UIFont systemFontOfSize:13];
    noteLab.text = @"虚拟奖品将在1月12日前发放到您的账户中~获得实体奖品，\n请您同客服娘QQ：3012575446联系，登记领奖信息呦~";
    noteLab.numberOfLines = 0;
    noteLab.textAlignment = 1;
    [_ticketImgView addSubview:noteLab];
    
}

#pragma mark - 没有tabbar的时候的投石
-(void)selectView:(QWSummonsSelectView *)view didSelectedCount:(NSNumber *)indexCount type:(NSNumber *)type chargeType:(NSNumber *)chargeType
{
    if (!type.boolValue && [QWGlobalValue sharedInstance].user.coin.integerValue < indexCount.integerValue) {
        [self showToastWithTitle:@"轻石不够" subtitle:nil type:ToastTypeAlert];
        return;
    }
    
    if (type.boolValue && [QWGlobalValue sharedInstance].user.gold.integerValue < indexCount.integerValue) {
        [self showToastWithTitle:@"重石不够" subtitle:nil type:ToastTypeAlert];
        return;
    }
    
    [self showLoading];
    WEAK_SELF;
    if (chargeType.integerValue == 1){
        [self.logic doChargeToFavorite:type.integerValue amount:indexCount.integerValue andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            STRONG_SELF;
            [self hideLoading];
            if (!anError) {
                NSNumber *code = aResponseObject[@"code"];
                if (code && ! [code isEqualToNumber:@0]) {//有错误
                    NSString *message = aResponseObject[@"msg"];
                    if (message.length) {
                        [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                    }
                    else {
                        [self showToastWithTitle:@"投石失败" subtitle:nil type:ToastTypeError];
                    }
                }
                else {
                    //self.logic.bookVO.coin = @(self.logic.bookVO.coin.integerValue + indexCount.integerValue);
                    if ([type  isEqualToNumber: @0]){
                        [QWGlobalValue sharedInstance].user.coin = @([QWGlobalValue sharedInstance].user.coin.integerValue - indexCount.integerValue);
                    }else{
                        [QWGlobalValue sharedInstance].user.gold = @([QWGlobalValue sharedInstance].user.gold.integerValue - indexCount.integerValue);
                    }
                    //dry code
                    [[QWGlobalValue sharedInstance] save];
                    [self showToastWithTitle:@"投石成功" subtitle:nil type:ToastTypeError];
                    [self.selectedView removeFromSuperview];
                    self.selectedView = nil;
                    [[QWRouter sharedInstance].topVC update];
                }
            }
            else {
                [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
            }
        }];
        
    }
    else{
        if ([type  isEqualToNumber: @0]) {
            [self.logic doChargeWithCoin:indexCount.integerValue andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
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
                            [self showToastWithTitle:@"投石失败" subtitle:nil type:ToastTypeError];
                        }
                    }
                    else {
                        self.logic.bookVO.coin = @(self.logic.bookVO.coin.integerValue + indexCount.integerValue);
                        [QWGlobalValue sharedInstance].user.coin = @([QWGlobalValue sharedInstance].user.coin.integerValue - indexCount.integerValue);
                        [[QWGlobalValue sharedInstance] save];
                        [self showToastWithTitle:@"投石成功" subtitle:nil type:ToastTypeError];
                        [self.selectedView removeFromSuperview];
                        self.selectedView = nil;
                        [[QWRouter sharedInstance].topVC update];
                    }
                }
                else {
                    [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
                }
            }];
        }
        else {
            [self.logic doChargeWithGold:indexCount.integerValue andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
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
                            [self showToastWithTitle:@"投石失败" subtitle:nil type:ToastTypeError];
                        }
                    }
                    else {
                        self.logic.bookVO.gold = @(self.logic.bookVO.gold.integerValue + indexCount.integerValue);
                        [QWGlobalValue sharedInstance].user.gold = @([QWGlobalValue sharedInstance].user.gold.integerValue - indexCount.integerValue);
                        [[QWGlobalValue sharedInstance] save];
                        [self showToastWithTitle:@"投石成功" subtitle:nil type:ToastTypeError];
                        [self.selectedView removeFromSuperview];
                        self.selectedView = nil;
                        [[QWRouter sharedInstance].topVC update];
                    }
                }
                else {
                    [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
                }
            }];
        }
    }
}


@end
