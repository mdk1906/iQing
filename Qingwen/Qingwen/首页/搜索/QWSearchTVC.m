//
//  QWSearchTVC.m
//  Qingwen
//
//  Created by Aimy on 7/30/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWSearchTVC.h"

#import "QWSearchLogic.h"
#import "QWTableView.h"
#import "QWDetailTVC.h"
#import "UITableView+loadingMore.h"
#import "QWSearchEmptyView.h"
#import "QWSearchAnimation.h"
#import "BBView.h"
#import "SerchHotWordVO.h"
@interface QWSearchTVC () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource,BBDelegate>
{
    UIView *headView;
    BOOL historyOpen;
}
@property (strong, nonatomic) QWSearchLogic *logic;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) IBOutlet QWTableView *tableView;

@property (nonatomic, strong) QWSearchEmptyView *emptyView;

@property (nonatomic) BOOL firstAppear;

@property (nonatomic, strong) NSArray *historys;

@property (nonatomic) BOOL showHistory;

@property (nonatomic) BOOL searchForName;

@property (nonatomic, strong) QWSearchPageVC *searchPageVC;

//@property (nonatomic ,strong)SerchHotWordVO *hotwordVO;

@property (nonatomic,strong)NSMutableArray *hotwordVOArr;

@property (nonatomic,strong)NSMutableArray *hotwordArr;

@property (nonatomic, strong)BestItemVO *hotImgBook;

@end

@implementation QWSearchTVC

+ (void)load
{
    QWMappingVO *vo = [QWMappingVO new];
    vo.className = [NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject;
    vo.storyboardName = @"QWSearch";
    
    [[QWRouter sharedInstance] registerRouterVO:vo withKey:@"search"];
}

- (QWSearchPageVC *)searchPageVC {
    if (_searchPageVC == nil) {
        _searchPageVC = [QWSearchPageVC createFromStoryboardWithStoryboardID:@"searchpage" storyboardName:@"QWSearch"];
        [self addChildViewController:_searchPageVC];
    }
    return  _searchPageVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    self.tableView.emptyView.errorImage = [UIImage imageNamed:@"empty_5_none"];
    //    self.tableView.emptyView.errorMsg = @"暂无搜索";
    self.view.backgroundColor = [UIColor whiteColor];
    self.historys = [QWFileManager loadHistory];
    
    self.searchBar.frame = CGRectMake(0, 7, UISCREEN_WIDTH, 30);
    self.navigationItem.titleView = self.searchBar;
    [self.searchBar setImage:[UIImage imageNamed:@"best_search"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.searchBar setValue:HRGB(0x505050) forKeyPath:@"_searchField.textColor"];
    [self.searchBar setValue:HRGB(0x505050) forKeyPath:@"_searchField._placeholderLabel.textColor"];
    
    if (self.extraData) {
        if ([[self.extraData objectForCaseInsensitiveKey:@"searchbookname"] boolValue]) {
            self.searchForName = 1;
            self.searchPageVC.extraData = self.extraData;
            WEAK_SELF;
            [self.searchPageVC.firstVC observeProperty:@"selecedBook" withBlock:^(id self, id oldValue, id newValue) {
                KVO_STRONG_SELF;
                BOOL selectBook = [newValue boolValue];
                if (selectBook) {
                    NSLog(@"%@",[NSThread currentThread]);
                    [kvoSelf leftBtnClicked:nil];
                }
            }];
            
            [self.searchPageVC.secondVC observeProperty:@"selecedBook" withBlock:^(id self, id oldValue, id newValue) {
                KVO_STRONG_SELF;
                BOOL selectBook = [newValue boolValue];
                if (selectBook) {
                    NSLog(@"%@",[NSThread currentThread]);
                    [kvoSelf leftBtnClicked:nil];
                }
            }];
        }
        
        if ([self.extraData objectForCaseInsensitiveKey:@"book_name"]) {
            
            NSString *book_name = [self.extraData objectForCaseInsensitiveKey:@"book_name"];
            
            book_name = [book_name stringByReplacingOccurrencesOfString:@"《" withString:@""];
            book_name = [book_name stringByReplacingOccurrencesOfString:@"》" withString:@""];
            
            self.searchBar.text = book_name;
            [self searchBarSearchButtonClicked:_searchBar];
        }
    }
    self.tableView.bounces = YES;
    self.tableView.backgroundColor = [UIColor whiteColor];
//    self.tableView.hidden = YES;
    
//        self.tableView.separatorInset = UIEdgeInsetsZero;
//        if (IOS_SDK_MORE_THAN(8.0)) {
//            self.tableView.layoutMargins = UIEdgeInsetsZero;
//        }

        self.navigationItem.hidesBackButton = YES;

//        self.emptyView = [QWSearchEmptyView createWithNib];
//        [self.view addSubview:self.emptyView];
//        [self.emptyView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view];
//        [self.emptyView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.view];
//        [self.emptyView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
//        [self.emptyView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view];
//
//        if (self.historys.count) {
//            self.showHistory = YES;
//            self.emptyView.hidden = YES;
//        }
}

- (IBAction)rightBtnClicked:(id)sender {
    [self.searchBar resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    _searchBar.delegate = nil;
}

- (QWSearchLogic *)logic
{
    if (!_logic) {
        _logic = [QWSearchLogic logicWithOperationManager:self.operationManager];
    }
    
    return _logic;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"self.historys = %@",self.historys);
    historyOpen = YES;
    [self getHotWord];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:HRGB(0xF8F8F8)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageWithColor:HRGB(0xF8F8F8)]];
    if (!self.firstAppear) {
        self.firstAppear = YES;
        [self.searchBar becomeFirstResponder];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)getSuggestes {
    [self.logic.operationManager cancelAllOperations];
    [self.logic getSuggestWithKeywords:self.searchBar.text andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        [self.tableView reloadData];
    }];
}
-(void)getHotWord{
    _hotwordVOArr = [NSMutableArray new];
    _hotwordArr = [NSMutableArray new];
    NSMutableDictionary *params = @{}.mutableCopy;
    
    
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/hotword/",[QWOperationParam currentDomain]] params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (aResponseObject && !anError) {
            NSArray *arr = aResponseObject[@"results"];
            
            for (NSDictionary *dict in arr) {
                SerchHotWordVO *model = [SerchHotWordVO voWithDict:dict];
                [self->_hotwordVOArr addObject:model];
                [self->_hotwordArr addObject:model.word];
            }
            [self getserchImg];
            
        }
        else {
            
        }
    }];
    [self.operationManager requestWithParam:param];
    
}
-(void)getserchImg{
    NSMutableDictionary *params = @{}.mutableCopy;
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/recommend/?type=15&limit=6&channel=1",[QWOperationParam currentDomain]] params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (aResponseObject && !anError) {
            if ([aResponseObject[@"count"] intValue] >= 1) {
                NSArray *result = aResponseObject[@"results"];
                self.hotImgBook = [BestItemVO voWithDict:result[0]];
                [self createHotWordView];
            }
        }
        else {
            
        }
    }];
    [self.operationManager requestWithParam:param];
}
-(void)createHotWordView{
    
    headView = [UIView new];
    headView.backgroundColor = [UIColor whiteColor];
    if (ISIPHONEX || ISIPHONEXR || ISIPHONEXSMAX) {
        headView.frame = CGRectMake(0, 80 + 22, UISCREEN_WIDTH, UISCREEN_HEIGHT - 80 - 22);
    }
    else{
        headView.frame = CGRectMake(0, 80, UISCREEN_WIDTH, UISCREEN_HEIGHT - 80);
    }
    
    self.tableView.tableHeaderView = headView;
    
    UILabel *everyOneLab = [UILabel new];
    everyOneLab.frame = CGRectMake(17, 16, UISCREEN_WIDTH, 18);
    everyOneLab.textColor = HRGB(0x505050);
    everyOneLab.text = @"大家都在搜";
    everyOneLab.font = FONT(13);
    [headView addSubview:everyOneLab];
    
    BBView *hotBBview = [BBView new];
    hotBBview.delegate = self;
    NSArray *bubbleStringArray = _hotwordArr;
    
    UIColor *textColor = HRGB(0x505050);
    
    UIColor *bgColor = HRGB(0xf6f6f6);
    hotBBview.frame = CGRectMake(0, kMaxY(everyOneLab.frame) + 3, UISCREEN_WIDTH, [hotBBview fillBubbleViewWithButtons:bubbleStringArray bgColor:bgColor textColor:textColor fontSize:14]);
    
    [hotBBview createBubbleViewWithButtons:bubbleStringArray bgColor:bgColor textColor:textColor fontSize:14 withType:@"everyone"];
    
    [headView addSubview:hotBBview];
    
    UIImageView *img = [UIImageView new];
    img.layer.cornerRadius = 7;
    img.userInteractionEnabled = YES;
    [img bk_tapped:^{
        
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:self->_hotImgBook.href]];
    }];
    img.layer.masksToBounds = YES;
    img.frame = CGRectMake(17, kMaxY(hotBBview.frame) + 17, UISCREEN_WIDTH-34, (UISCREEN_WIDTH-34)/2);
    [img qw_setImageUrlString:self.hotImgBook.cover placeholder:nil animation:YES];
    [headView addSubview:img];
    
    UILabel *searchHistoryLab = [UILabel new];
    searchHistoryLab.frame = CGRectMake(17, kMaxY(img.frame) + 20, UISCREEN_WIDTH, 18);
    searchHistoryLab.textColor = HRGB(0x505050);
    searchHistoryLab.text = @"搜索历史";
    searchHistoryLab.font = FONT(13);
    [headView addSubview:searchHistoryLab];
    
    UIButton *openHistoryBtn = [UIButton new];
    openHistoryBtn.frame = CGRectMake(UISCREEN_WIDTH - 18 - 50, kMaxY(img.frame) + 20, 50, 18);
    if (historyOpen == YES) {
        [openHistoryBtn setTitle:@"展开" forState:0];
    }
    else{
        [openHistoryBtn setTitle:@"收回" forState:0];
    }
    
    openHistoryBtn.titleLabel.font = FONT(13);
    [openHistoryBtn setTitleColor:HRGB(0x999999) forState:0];
    [openHistoryBtn addTarget:self action:@selector(openHistoryBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.historys.count < 7) {
        openHistoryBtn.hidden = YES;
    }
    [headView addSubview:openHistoryBtn];
    
    BBView *histirysBBview = [BBView new];
    histirysBBview.delegate = self;
    NSMutableArray *historys = self.historys.mutableCopy;
    
    if (historys.count >= 6 && historyOpen == YES) {
        historys = [historys subarrayWithRange:NSMakeRange(0, 6)].mutableCopy;
    }
    else{
        if (historys.count >= 50) {
            historys = [historys subarrayWithRange:NSMakeRange(0, 50)].mutableCopy;
        }
        else{
            historys = self.historys.mutableCopy;
        }
        
    }
    histirysBBview.frame = CGRectMake(0, kMaxY(searchHistoryLab.frame) + 3, UISCREEN_WIDTH, [histirysBBview fillBubbleViewWithButtons:historys bgColor:bgColor textColor:textColor fontSize:14]);
//    histirysBBview.frame = CGRectMake(0, kMaxY(searchHistoryLab.frame) + 3, UISCREEN_WIDTH, 200);
    
    [histirysBBview createBubbleViewWithButtons:historys bgColor:bgColor textColor:textColor fontSize:14 withType:@"history"];
    
    [headView addSubview:histirysBBview];
    
    UIButton *deleteHistoryBtn = [UIButton new];
    deleteHistoryBtn.frame = CGRectMake(0, kMaxY(histirysBBview.frame) + 35, UISCREEN_WIDTH, 18);
    deleteHistoryBtn.titleLabel.font = FONT(13);
    [deleteHistoryBtn setTitleColor:HRGB(0x999999) forState:0];
    [deleteHistoryBtn setTitle:@"清空搜索历史" forState:0];
    [deleteHistoryBtn setImage:[UIImage imageNamed:@"BAI-垃圾桶"] forState:0];
    [deleteHistoryBtn addTarget:self action:@selector(deleteHistoryBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:deleteHistoryBtn];
    
}
-(void)openHistoryBtnClick:(UIButton *)btn{
    if ([btn.titleLabel.text isEqualToString:@"展开"]) {
        historyOpen = NO;
        [headView removeFromSuperview];
        [self createHotWordView];
    }
    else{
        historyOpen = YES;
        [headView removeFromSuperview];
        [self createHotWordView];
    }
}
-(void)deleteHistoryBtnClick{
    
    self.historys = [NSArray array];
    [QWFileManager saveHistory:self.historys];
    
    [headView removeFromSuperview];
    [self createHotWordView];
}

#pragma mark - BubbleButton Delegate
-(void)didClickBubbleButton:(UIButton *)bubble {
    // Do something here
    // Use bubble.tag to use your data in the array
    // -- or bubble.titleLabel.text to access the string
    // -- etc.
    
    // Removing all buttons for demo purposes
    if (bubble.tag <= self.hotwordArr.count) {
        SerchHotWordVO *model = self.hotwordVOArr[bubble.tag];
        NSString *url = model.href;
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:url]];
    }
    if (bubble.tag - 1000 <= self.historys.count) {
        self.searchBar.text = self.historys[bubble.tag - 1000];
        [self searchBarSearchButtonClicked:self.searchBar];
    }
    
}

#pragma mark - search bar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (self.searchBar.text.length) {
        self.showHistory = NO;
        self.emptyView.hidden = YES;
        [self.searchPageVC.view removeFromSuperview];
        [self getSuggestes];
    }
    else {
        self.logic.suggests = nil;
        if (self.historys.count) {
            self.showHistory = YES;
        }
        else {
            self.emptyView.hidden = YES;
        }
        [self.searchPageVC.view removeFromSuperview];
        [self.tableView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (!searchBar.text.length) {
        return ;
    }
    
    NSMutableArray *historys = self.historys.mutableCopy;
    [historys insertObject:searchBar.text atIndex:0];
    //    if (historys.count > 3) {
    //        historys = [historys subarrayWithRange:NSMakeRange(0, 3)].mutableCopy;
    //    }
    self.historys = historys;
    [QWFileManager saveHistory:self.historys];
    
    [self.searchBar resignFirstResponder];
    
    //    WEAK_SELF;
    //    self.logic.searchVO = nil;
    //    self.emptyView.hidden = YES;
    //    self.showHistory = NO;
    //    [self.tableView reloadData];
    //    self.tableView.emptyView.showError = NO;
    //    [self.logic searchWithKeywords:searchBar.text andType:SearchTypeNone andCompleteBlock:^(id aResponseObject, NSError *anError) {
    //        STRONG_SELF;
    //        [self.tableView reloadData];
    //        self.tableView.emptyView.showError = YES;
    //    }];
    
    self.searchPageVC.keyWords = self.searchBar.text;
    [self.searchPageVC update];
    [self.searchPageVC willMoveToParentViewController:self];
    
    [self.view addSubview:self.searchPageVC.view];
    self.searchPageVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.searchPageVC.view autoCenterInSuperview];
    [self.searchPageVC.view autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view];
    [self.searchPageVC.view autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.view];
}

- (IBAction)onPressedDeleteHistoryBtn:(id)sender event:(UIEvent *)event
{
    UITouch *touch = event.allTouches.anyObject;
    CGPoint point = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    NSMutableArray *historys = self.historys.mutableCopy;
    if (historys.count >= indexPath.row) {
        [historys removeObjectAtIndex:indexPath.row];
    }
    self.historys = historys;
    [QWFileManager saveHistory:self.historys];
    [self.tableView reloadData];
    
    if (self.historys.count) {
        self.emptyView.hidden = YES;
    }
    else {
        self.emptyView.hidden = YES;
    }
}

#pragma mark - table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (self.logic.suggests.count > 0) {
//        return 30;
//    }
//    if (self.showHistory) {
//        return 30;
//    }
//    return PX1_LINE;
//}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if (self.showHistory) {
//        UILabel *label = [UILabel new];
//        label.text = @"   搜索历史";
//        label.textColor = HRGB(0xcccccc);
//        label.font = [UIFont systemFontOfSize:12.0];
//        label.backgroundColor = [UIColor whiteColor];
//        return label;
//    }
//
//    return nil;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (self.showHistory || self.logic.suggests.count > 0) {
//        return 44;
//    }
//    return 130;
    return 0.05;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.logic.suggests.count > 0) {
        QWSearchHistoryTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"history" forIndexPath:indexPath];
        SuggestVO *vo = self.logic.suggests[indexPath.row];
        [cell updateWithHistory:vo.suggestion];
        cell.deleteHistoryBtn.hidden = YES;
        return cell;
    }
    if (self.showHistory) {
        QWSearchHistoryTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"history" forIndexPath:indexPath];
        [cell updateWithHistory:self.historys[indexPath.row]];
        cell.deleteHistoryBtn.hidden = false;
        return cell;
    } else {
        
        return [UITableViewCell new];
    }
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (self.logic.suggests.count > 0) {
//        SuggestVO *vo = self.logic.suggests[indexPath.row];
//        self.searchBar.text = vo.suggestion;
//        [self searchBarSearchButtonClicked:self.searchBar];
//
//    }
//    if (self.showHistory) {
//        self.searchBar.text = self.historys[indexPath.row];
//        [self searchBarSearchButtonClicked:self.searchBar];
//    }
//}

#pragma mark - animtion

- (id<UIViewControllerAnimatedTransitioning>)pushAnimations
{
    return [QWSearchAnimation animationWithType:YES];
}

- (id<UIViewControllerAnimatedTransitioning>)popAnimations
{
    return [QWSearchAnimation animationWithType:NO];
}

@end
