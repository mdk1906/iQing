//
//  QWMyMissionVC.m
//  Qingwen
//
//  Created by qingwen on 2018/9/3.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import "QWMyMissionVC.h"
#import "QWMyMissionTableViewCell.h"
#import "MyMissionVO.h"

//玉米广告

#import <YumiMediationDebugCenter-iOS/YumiMediationDebugController.h>
#import <YumiMediationSDK/YumiMediationBannerView.h>
#import <YumiMediationSDK/YumiMediationVideo.h>
#import <YumiMediationSDK/YumiMediationInterstitial.h>

//穿山甲广告

#import <BUAdSDK/BURewardedVideoAd.h>
#import <BUAdSDK/BURewardedVideoModel.h>
@interface QWMyMissionVC () <UITableViewDelegate,
UITableViewDataSource,
YumiMediationVideoDelegate,
YumiMediationInterstitialDelegate,
BURewardedVideoAdDelegate>
@property (nonatomic,strong) QWTableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArr;

@property (nonatomic, strong)UIView *backView;
@property (nonatomic, strong)UIImageView *adImgView;
@property (nonatomic ,strong)UIButton *cancelBtn;

//玉米广告
@property (nonatomic) YumiMediationBannerView *yumiBanner;
@property (nonatomic) YumiMediationInterstitial *yumiInterstitial;

//穿山甲
@property (nonatomic, strong) BURewardedVideoAd *rewardedVideoAd;
@end

@implementation QWMyMissionVC


- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"了解更多" style:UIBarButtonItemStylePlain target:self action:@selector(rightClick)];
    self.navigationItem.rightBarButtonItem.tintColor = HRGB(0xffffff);
    self.tableView = [QWTableView new];
    if (ISIPHONEX) {
        self.tableView.frame = CGRectMake(0, -88, UISCREEN_WIDTH, UISCREEN_HEIGHT+88);
    }
    else{
        self.tableView.frame = CGRectMake(0, -64, UISCREEN_WIDTH, UISCREEN_HEIGHT+64);
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];

    [self createHeadView];
    [self getData];

    //加载视频广告
    [[YumiMediationVideo sharedInstance] loadAdWithPlacementID:QWRewardedAdKey
                                                     channelID:@""
                                                     versionID:@""];
    [YumiMediationVideo sharedInstance].delegate = self;
    
    //加载插屏广告
    
    self.yumiInterstitial =  [[YumiMediationInterstitial alloc]
                              initWithPlacementID:QWInterstitialAdKey
                              channelID:@""
                              versionID:@""
                              rootViewController:self];
    self.yumiInterstitial.delegate = self;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(watchAD) name:@"SignWatchAd" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(NOwatchAD) name:@"SignNOWatchAd" object:nil];
    
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    model.userId = QWCSJAdKey;
    model.isShowDownloadBar = YES;
    self.rewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID:QWCSJRewardedAdKey rewardedVideoModel:model];
    self.rewardedVideoAd.delegate = self;
    [self.rewardedVideoAd loadAdData];
    
//    NSLog(@"屏幕高度1 = %f",UISCREEN_HEIGHT);
//     NSLog(@"屏幕高度2 = %f",[UIScreen mainScreen].bounds.size.height);
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.tableView reloadData];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self configNavigationBar];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}
- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)getData{
    self.dataArr = [NSMutableArray new];
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"task_type"] = @"0";
    [self showLoading];
    NSString *url = [NSString stringWithFormat:@"%@/task/task_list/",[QWOperationParam currentDomain]];
//    NSString *url = @"http://apidoc.iqing.com/mock/19/task/task_list/";
    QWOperationParam *pm = [QWInterface postWithUrl:url params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (aResponseObject != nil) {
            NSDictionary *data = aResponseObject;
            NSArray *arr = data[@"data"];
            for (int i = 0; i < arr.count; i++) {
                MyMissionVO *model = [MyMissionVO voWithDict:arr[i]];
                [self.dataArr addObject:model];
            }
            [self.tableView reloadData];
            [self hideLoading];
        }
        else{
            [self hideLoading];
        }
    }];
    [self.operationManager requestWithParam:pm];
    
}
#define HEIGHT_LENGTH 36
- (void)configNavigationBar
{
    if (self.tableView.contentOffset.y > HEIGHT_LENGTH + 64) {
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:nil];
        self.navigationItem.leftBarButtonItem.tintColor = HRGB(0x505050);
        self.navigationItem.rightBarButtonItem.tintColor = HRGB(0x505050);
        self.title = @"每日任务";
        [self setNeedsStatusBarAppearanceUpdate];
    }
    else if (self.tableView.contentOffset.y > HEIGHT_LENGTH) {
        CGFloat alpha = (self.tableView.contentOffset.y - HEIGHT_LENGTH) / 64;
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[HRGB(0xF8F8F8) colorWithAlphaComponent:alpha]] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[UIImage imageWithColor:[HRGB(0xF8F8F8) colorWithAlphaComponent:alpha]]];
        self.navigationItem.leftBarButtonItem.tintColor = HRGB(0x505050);
        self.navigationItem.rightBarButtonItem.tintColor = HRGB(0x505050);
        self.title = nil;
    }
    else {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
        self.navigationItem.leftBarButtonItem.tintColor = HRGB(0xF8F8F8);
        self.navigationItem.rightBarButtonItem.tintColor = HRGB(0xF8F8F8);
        self.title = nil;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    
}
-(void)createHeadView{
    UIView *headView = [UIView new];
    headView.backgroundColor = [UIColor clearColor];
    headView.frame = CGRectMake(0, 0, UISCREEN_WIDTH, UISCREEN_WIDTH*0.4106);
    self.tableView.tableHeaderView = headView;
    
    UIImageView *img = [UIImageView new];
    img.frame = CGRectMake(0, 0, UISCREEN_WIDTH, UISCREEN_WIDTH*0.4106);
    img.image = [UIImage imageNamed:@"人物"];
    [headView addSubview:img];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(14, UISCREEN_WIDTH*0.192+5, UISCREEN_WIDTH, 20)];
    titleLab.textColor = HRGB(0xffffff);
    titleLab.font = [UIFont systemFontOfSize:20];
    titleLab.text = @"Daily Goal";
    [img addSubview:titleLab];
    
    UILabel *missionLab = [[UILabel alloc] initWithFrame:CGRectMake(12, kMaxY(titleLab.frame) + 5, UISCREEN_WIDTH, 42)];
    missionLab.textColor = HRGB(0xffffff);
    missionLab.font = [UIFont systemFontOfSize:42];
    missionLab.text = @"每日任务";
    [img addSubview:missionLab];

}
#pragma mark tableView数据源方法
//组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;
}
//cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QWMyMissionTableViewCell *cell = [tableView
                               dequeueReusableCellWithIdentifier:@"QWMyMissionTableViewCell"];
    if (cell == nil) {
        UINib *nibCell = [UINib nibWithNibName:NSStringFromClass([QWMyMissionTableViewCell class]) bundle:nil];
        [tableView registerNib:nibCell forCellReuseIdentifier:@"QWMyMissionTableViewCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"QWMyMissionTableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    MyMissionVO *model = self.dataArr[indexPath.row];
    cell.model = model;
    
    return cell;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self configNavigationBar];
}

-(void)rightClick{
    [[QWRouter sharedInstance] routerWithUrl:[NSURL URLWithString:@"https://www.iqing.com/info/#/task"]];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//implementing yumiBanner delegate
#pragma mark - 广告功能
-(void)NOwatchAD{
    
}
-(void)watchAD{
    if ([[QWGlobalValue sharedInstance].checkin_ad isEqualToString:@"1"]) {
        [self createDefaultAdView];
    }
    else{
        [self.rewardedVideoAd showAdFromRootViewController:self];
    }
    
}

- (void)yumiMediationVideoDidOpen:(YumiMediationVideo *)video{
    NSLog(@"Opened reward video ad.");
}
- (void)yumiMediationVideoDidStartPlaying:(YumiMediationVideo *)video{
    NSLog(@"Reward video ad started playing.");
}
- (void)yumiMediationVideoDidClose:(YumiMediationVideo *)video{
    NSLog(@"Reward video ad is closed.");
//    [self.navigationController popViewControllerAnimated:NO];
}
- (void)yumiMediationVideoDidReward:(YumiMediationVideo *)video{
    NSLog(@"is Rewarded");
    //查询广告显示结果
    NSMutableDictionary *params = [NSMutableDictionary new];
//    params[@""]
    [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"CheckinEvent" extra:params];
    NSMutableDictionary *adparam = [NSMutableDictionary new];
    adparam[@"token"] = [QWGlobalValue sharedInstance].token;
    
    QWOperationParam *globalAdpm = [QWInterface postWithUrl:[NSString stringWithFormat:@"%@/ad/task/",[QWOperationParam currentDomain]] params:adparam andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        
        [self showToastWithTitle:aResponseObject[@"msg"] subtitle:nil type:ToastTypeError];
    }];
    globalAdpm.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:globalAdpm];
    
}


#pragma mark - 插屏广告
-(void)watchPhotoAd{
    if ([self.yumiInterstitial isReady]) {
        [self.yumiInterstitial present];
    } else {
        NSLog(@"Ad wasn't ready");
    }
}

//implementing YumiMediationInterstitial Delegate
- (void)yumiMediationInterstitialDidReceiveAd:(YumiMediationInterstitial *)interstitial{
    NSLog(@"interstitialDidReceiveAd");
    
}
- (void)yumiMediationInterstitial:(YumiMediationInterstitial *)interstitial
                 didFailWithError:(YumiMediationError *)error{
    NSLog(@"interstitial:didFailToReceiveAdWithError: %@", error);
}
- (void)yumiMediationInterstitialWillDismissScreen:(YumiMediationInterstitial *)interstitial{
    NSLog(@"interstitialWillDismissScreen");
    NSMutableDictionary *adparam = [NSMutableDictionary new];
    adparam[@"token"] = [QWGlobalValue sharedInstance].token;
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"source"] = @"YUMI";
    [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"CheckinImageEvent" extra:params];
    
    QWOperationParam *globalAdpm = [QWInterface postWithUrl:[NSString stringWithFormat:@"%@/ad/task/",[QWOperationParam currentDomain]] params:adparam andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        
        [self showToastWithTitle:aResponseObject[@"msg"] subtitle:nil type:ToastTypeError];
    }];
    globalAdpm.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:globalAdpm];
}
- (void)yumiMediationInterstitialDidClick:(YumiMediationInterstitial *)interstitial{
    NSLog(@"interstitialDidClick");
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"source"] = @"YUMI";
    [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"CheckinImageClickEvent" extra:params];
}


#pragma mark - 自定义广告图片
-(UIView*)backView{
    if (!_backView) {
        _backView = [UIView new];
    }
    return _backView;
}

-(UIImageView*)adImgView{
    if (!_adImgView) {
        _adImgView = [UIImageView new];
    }
    return _adImgView;
}
-(UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton new];
    }
    return _cancelBtn;
}
-(void)createDefaultAdView{
    self.backView = [UIView new];
    _backView.backgroundColor = HRGB(0x000000);
    _backView.alpha = 0.8;
    _backView.frame = CGRectMake(0, 0, UISCREEN_WIDTH, UISCREEN_HEIGHT);
    [self.view addSubview:_backView];
    
    self.adImgView = [UIImageView new];
    
    [_adImgView qw_setImageUrlString:[QWGlobalValue sharedInstance].checkin_adInc placeholder:nil animation:YES];
    _adImgView.frame = CGRectMake(53, (UISCREEN_HEIGHT-(UISCREEN_WIDTH-106)/0.75)/2, UISCREEN_WIDTH-106, (UISCREEN_WIDTH-106)/0.75);
    _adImgView.userInteractionEnabled = YES;
    [_adImgView bk_tapped:^{
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[@"source"] = @"iQing";
        [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"CheckinClickEvent" extra:params];
        [[QWRouter sharedInstance] routerWithUrl:[NSURL URLWithString:[QWGlobalValue sharedInstance].checkin_adURL]];
         
    }];
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"source"] = @"iQing";
    [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"CheckinEvent" extra:params];
    [self.view addSubview:_adImgView];
    
    self.cancelBtn = [UIButton new];
    [_cancelBtn setBackgroundImage:[UIImage imageNamed:@"叉叉"] forState:0];
    _cancelBtn.frame = CGRectMake((UISCREEN_WIDTH - 20)/2, kMaxY(_adImgView.frame)+40, 20, 20);
    [self.view addSubview:_cancelBtn];
    [_cancelBtn bk_tapped:^{
        [self->_backView removeFromSuperview];
        [self->_adImgView removeFromSuperview];
        [self->_cancelBtn removeFromSuperview];
        NSMutableDictionary *adparam = [NSMutableDictionary new];
        adparam[@"token"] = [QWGlobalValue sharedInstance].token;
        
        QWOperationParam *globalAdpm = [QWInterface postWithUrl:[NSString stringWithFormat:@"%@/ad/task/",[QWOperationParam currentDomain]] params:adparam andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            
            [self showToastWithTitle:aResponseObject[@"msg"] subtitle:nil type:ToastTypeError];
        }];
        globalAdpm.requestType = QWRequestTypePost;
        [self.operationManager requestWithParam:globalAdpm];
    }];
}

#pragma mark BURewardedVideoAdDelegate

- (void)rewardedVideoAdDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"rewardedVideoAd data load success");
    
}

- (void)rewardedVideoAdVideoDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"1rewardedVideoAd video load success");
    
    
}

- (void)rewardedVideoAdWillVisible:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"2rewardedVideoAd video will visible");
}

- (void)rewardedVideoAdDidClose:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"3rewardedVideoAd video did close");
}

- (void)rewardedVideoAdDidClick:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"4rewardedVideoAd video did click");
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"source"] = @"CSJ";
    [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"CheckinClickEvent" extra:params];
}

- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    NSLog(@"5rewardedVideoAd data load fail");
    
}

- (void)rewardedVideoAdDidPlayFinish:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    if (error) {
        NSLog(@"6rewardedVideoAd play error");
    } else {
        NSLog(@"7rewardedVideoAd play finish");
    }
}

- (void)rewardedVideoAdServerRewardDidFail:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"8rewardedVideoAd verify failed");
    
    NSLog(@"9Demo RewardName == %@", rewardedVideoAd.rewardedVideoModel.rewardName);
    NSLog(@"10Demo RewardAmount == %ld", (long)rewardedVideoAd.rewardedVideoModel.rewardAmount);
}

- (void)rewardedVideoAdServerRewardDidSucceed:(BURewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify{
    NSLog(@"11rewardedVideoAd verify succeed");
    NSLog(@"12verify result: %@", verify ? @"success" : @"fail");
    
    NSLog(@"13Demo RewardName == %@", rewardedVideoAd.rewardedVideoModel.rewardName);
    NSLog(@"14Demo RewardAmount == %ld", (long)rewardedVideoAd.rewardedVideoModel.rewardAmount);
    NSMutableDictionary *adparam = [NSMutableDictionary new];
    adparam[@"token"] = [QWGlobalValue sharedInstance].token;
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"source"] = @"CSJ";
    [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"CheckinEvent" extra:params];
    
    QWOperationParam *globalAdpm = [QWInterface postWithUrl:[NSString stringWithFormat:@"%@/ad/task/",[QWOperationParam currentDomain]] params:adparam andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        
        [self showToastWithTitle:aResponseObject[@"msg"] subtitle:nil type:ToastTypeError];
    }];
    globalAdpm.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:globalAdpm];
}

-(BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end
