//
//  QWReadingPVC.m
//  Qingwen
//
//  Created by Aimy on 7/6/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWReadingPVC.h"

#import "QWPictureVC.h"
#import "QWReadingVC.h"
#import "QWReadingManager.h"
#import "QWReadingLogic.h"
#import "QWReadingTopView.h"
#import "QWReadingBottomView.h"
#import "QWReadingProgressView.h"
#import "QWReadingProgressMessageView.h"
#import "QWReadingSettingView.h"
#import "QWReadingBrightnessView.h"
#import "QWSendDanmuView.h"
#import "BookPageVO.h"
#import "QWDetailDirectoryVC.h"
#import "VolumeVO.h"
#import "ChapterVO.h"
#import "BookCD.h"
#import "VolumeCD.h"
#import "QWReadingDirectoryVC.h"
#import "QWDiscussTVC.h"
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#import "QWReadingEndView.h"
#import "QWTBC.h"

#import "QWBulletManager.h"
#import "QWBulletView.h"
#import "QWSendDanmuButton.h"
#import "QWReadingAloudSettingView.h"

//朗读相关
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioSession.h>
#import "TTSConfig.h"
//百度语音
#import "BDSSpeechSynthesizer.h"
#import "BDSSpeechSynthesizerDelegate.h"
#import "BDS_EttsModelManagerInterface.h"
#import "BDSTTSEventManager.h"

#import <YumiMediationSDK/YumiMediationVideo.h>
#import <YumiMediationSDK/YumiMediationInterstitial.h>

//穿山甲广告

#import <BUAdSDK/BURewardedVideoAd.h>
#import <BUAdSDK/BURewardedVideoModel.h>

static BOOL isSpeak = YES;
NSString* BAIDUAPP_ID = @"11380459";
NSString* API_KEY = @"usxx82pUd8qaMRko0ezp7a54";
NSString* SECRET_KEY = @"8sGjll5BaEPBGGSwyWNRmffDpbGSBGE0";

@interface QWReadingPVC () <QWReadingTopViewDelegate,
QWReadingBottomViewDelegate,
QWReadingDirectoryVCDelegate,
QWReadingEndViewDelegate,
QWSendDanmuViewDelegate,
UIPageViewControllerDelegate,
UIPageViewControllerDataSource,
BDSSpeechSynthesizerDelegate,
YumiMediationVideoDelegate,
YumiMediationInterstitialDelegate,
BURewardedVideoAdDelegate
>

@property (nonatomic, strong) QWReadingLogic *logic;

@property (nonatomic, strong) QWReadingTopView *topView;
@property (nonatomic, strong) QWReadingBottomView *bottomView;
@property (nonatomic, strong) QWReadingProgressView *progressView;
@property (nonatomic, strong) QWReadingProgressMessageView *progressMessageView;
@property (nonatomic, strong) QWReadingSettingView *settingView;
@property (nonatomic, strong) QWReadingEndView *endView;
@property (nonatomic, strong) QWReadingBrightnessView *brightnessView;
@property (nonatomic, strong) QWReadingAloudSettingView *aloudSettingView;

@property (strong, nonatomic) QWReadingDirectoryVC *directoryVC;
@property (strong, nonatomic) IBOutlet UIView *directoryView;
@property (strong, nonatomic) NSLayoutConstraint *rightConstraints;

@property (strong, nonatomic) QWSendDanmuView *sendDanmuView;
@property (strong, nonatomic) QWSendDanmuButton *sendDanmuBtn;

@property (strong, nonatomic) IBOutlet UIView *danmuView;
@property (strong, nonatomic) IBOutlet UIImageView *danmuBgImageView;
@property (strong, nonatomic) IBOutlet UIButton *cancelDanmuViewBtn;
@property (strong, nonatomic) IBOutlet UILabel *danmuCountLabel;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *containerViewTopConstraint;

@property (nonatomic) BOOL showSetting;

@property (nonatomic, strong) QWBulletManager *bulletManager;

@property (nonatomic) NSInteger currentPageDanmuCount; //当前页弹幕数

@property (nonatomic, copy) NSString *chapter_id; //从Chapter获取到内容

@property (nonatomic,copy)NSString *aloudStr;
@property (nonatomic,strong) NSArray *contentArr;
@property int aloudParagraph;
@property (nonatomic ,strong) NSTimer *timer;
//玉米
@property (nonatomic) YumiMediationInterstitial *yumiInterstitial;
//穿山甲
@property (nonatomic, strong) BURewardedVideoAd *rewardedVideoAd;
@end

@implementation QWReadingPVC



+ (void)load
{
    QWMappingVO *vo = [QWMappingVO new];
    vo.className = [NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject;
    vo.storyboardName = @"QWReading";
    vo.storyboardID = @"readingpvc";
    
    [[QWRouter sharedInstance] registerRouterVO:vo withKey:@"reading"];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[QWReadingManager sharedInstance] isOpenDanmu]) {
        [QWReadingConfig sharedInstance].showDanmu = true; //保证每一次进来的时候都会有弹幕
        [[QWReadingConfig sharedInstance] saveData];
    }
    else {
        [QWReadingConfig sharedInstance].showDanmu = false; //保证每一次进来的时候都会有弹幕
        [[QWReadingConfig sharedInstance] saveData];
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initSynthesizer];
    
}
-(void)viewDidDisappear:(BOOL)animated{
    //    [super viewDidDisappear:animated];
    if ([_timer isValid]) {
        
        [_timer invalidate];
        
    }
    
    _timer =nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = YES;
    self.fd_prefersNavigationBarHidden = YES;
    self.fd_interactivePopDisabled = YES;
    
    
    
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
    
    //加载穿山甲广告
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    model.userId = QWCSJAdKey;
    model.isShowDownloadBar = YES;
    self.rewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID:QWCSJReadRewardedAdKey rewardedVideoModel:model];
    self.rewardedVideoAd.delegate = self;
    [self.rewardedVideoAd loadAdData];
    
    NSString *prePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    _uriPath = [NSString stringWithFormat:@"%@/%@",prePath,@"uri.pcm"];
    _audioPlayer = [[PcmPlayer alloc] init];
    
    self.topView = [QWReadingTopView createWithNib];
    self.topView.ownerVC = self;
    self.topView.delegate = self;
    
    [self.view addSubview:self.topView];
    
    self.bottomView = [QWReadingBottomView createWithNib];
    self.bottomView.delegate = self;
    [self.view addSubview:self.bottomView];
    
    self.progressView = [QWReadingProgressView createWithNib];
    //    self.progressView.delegate = self;
    self.progressView.ownerVC = self;
    [self.view addSubview:self.progressView];
    
    self.progressMessageView = [QWReadingProgressMessageView createWithNib];
    [self.view addSubview:self.progressMessageView];
    
    self.brightnessView = [QWReadingBrightnessView createWithNib];
    [self.view addSubview:self.brightnessView];
    
    self.settingView = [QWReadingSettingView createWithNib];
    self.settingView.ownerVC = self;
    [self.view addSubview:self.settingView];
    
    self.aloudSettingView = [QWReadingAloudSettingView createWithNib];
    self.aloudSettingView.ownerVC = self;
    [self.view addSubview:self.aloudSettingView];
    
    self.endView = [QWReadingEndView createWithNib];
    self.endView.delegate = self;
    [self.view addSubview:self.endView];
    
    self.sendDanmuBtn = [QWSendDanmuButton createWithNib];
    [self.view addSubview:self.sendDanmuBtn];
    [self.sendDanmuBtn autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view withOffset:-13];
    [self.sendDanmuBtn autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view withOffset:-23];
    [self.sendDanmuBtn autoSetDimension:ALDimensionHeight toSize:20];
    [self.sendDanmuBtn autoSetDimension:ALDimensionWidth toSize:80];
    
    self.sendDanmuView = [QWSendDanmuView createWithNib];
    self.sendDanmuView.delegate = self;
    [self.view addSubview:self.sendDanmuView];
    
    [QWReadingConfig sharedInstance].landscape = UISCREEN_WIDTH > UISCREEN_HEIGHT;
    
    WEAK_SELF;
    [self.sendDanmuBtn bk_whenTapped:^{
        STRONG_SELF;
        [self onPressedDanmuBtn];
    }];
    //设置pagevc
    [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIPageViewController class]]) {
            STRONG_SELF;
            self.pageViewController = obj;
            self.pageViewController.delegate = self;
            self.pageViewController.dataSource = self;
            
            [self.pageViewController.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[UITapGestureRecognizer class]]) {
                    UITapGestureRecognizer *tap = obj;
                    tap.enabled = NO;
                }
            }];
        }
        
        if ([obj isKindOfClass:[QWReadingDirectoryVC class]]) {
            self.directoryVC = obj;
            self.directoryVC.delegate = self;
            self.rightConstraints = [self.directoryView autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.view];
        }
    }];
    
    QWReadingVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"readingvc"];
    self.currentVC = vc;
    if (self.extraData) {
        self.chapter_id = [self.extraData objectForKeyedSubscript:@"chapter_id"];
        self.currentVC.loadingBook = YES;
        [self getDirectory];
    }
    
    [self.pageViewController setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self observeNotification:@"PROGRESS_VIEW_UPDATE_COUNT" withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }
        
        KVO_STRONG_SELF;
        QWReadingVC *currentVC = kvoSelf.currentVC;
        VolumeVO *volume = [[QWReadingManager sharedInstance] currentVolumeVO];
        ChapterVO *chapter = volume.chapter[currentVC.currentPage.chapterIndex];
        [kvoSelf.bottomView updateWithCurrentPageIndex:currentVC.currentPage.pageIndex andPageCount:chapter.pageCount];
        if(chapter.pageCount > 1){
            [kvoSelf.progressMessageView updateWithProgress:currentVC.currentPage.pageIndex * 100 / (chapter.pageCount - 1) andMessage:[NSString stringWithFormat:@"%@ %@", volume.title, chapter.title]];
        }
        if (currentVC.currentPage.pageIndex == 0) {
            [kvoSelf closeDanmuView];
            kvoSelf.sendDanmuBtn.hidden = true;
            return;
        } else {
            if ([QWReadingConfig sharedInstance].showDanmu && [[QWReadingManager sharedInstance] isOpenDanmu]) {
                [kvoSelf showDanmuView];
            } else {
                [kvoSelf closeDanmuView];
            }
            kvoSelf.sendDanmuBtn.hidden = false;
        }
        
        if ((currentVC.currentPage.pageIndex == 1 || currentVC.currentPage.pageIndex + 1 == chapter.pageCount || kvoSelf.logic.currentChapterId == nil) && [QWReadingConfig sharedInstance].showDanmu && [[QWReadingManager sharedInstance] isOpenDanmu]) {
            [kvoSelf requestBullets];
        }
        
        [kvoSelf updateDanmuStyle];
        
    }];
    
    [QWReadingIntroView showOnView:self.view];
    
    [self getDiscuss];
    
    [self initBulletManager];
    if ([QWReadingConfig sharedInstance].showDanmu && [[QWReadingManager sharedInstance] isOpenDanmu]) {
        [self showDanmuView];
        [self updateDanmuStyle];
    } else {
        [self closeDanmuView];
    }
    //获取朗读内容
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(createAloudStr:) name:@"aloudStrPost" object:nil];
    self.aloudParagraph = 0;
    //设置百度sdk
    [self configureSDK];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startAloud) name:@"ttsNextPage" object:nil];
    //断网没有加载出来数据停止朗读
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(exitAloud) name:@"stopAloud" object:nil];
    //处理中断事件的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterreption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    self.contentArr = [NSArray new];
    
    
    //任务完成5分钟
    int k = [[QWGlobalValue sharedInstance].readTaskTime intValue];
    if (k >= 299) {
        
    }
    else{
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(readTask) userInfo:nil repeats:YES];
    }
    
    
    
    //看视频广告通知
    [self observeNotification:@"readWatchVedioAd" withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }
        
        KVO_STRONG_SELF;
        [kvoSelf watchAD];
    }];
    
    //看yomob视频广告通知
    
    //看插屏广告通知
    [self observeNotification:@"readWatchPhotoAd" withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }
        
        KVO_STRONG_SELF;
        [kvoSelf watchPhotoAd];
    }];
    
    //充值vip成功通知
    
    [self observeNotification:@"VIPisAccount" withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }
        
        KVO_STRONG_SELF;
        [kvoSelf nextPage];
    }];
    self.GDTAdView= [[QWGDTReadNativeAdView alloc] initWithFrame:CGRectMake(15, 0, UISCREEN_WIDTH-30, (UISCREEN_WIDTH-30)*0.6)];
    self.GDTAdView.hidden = YES;
    [self.view addSubview:self.GDTAdView];
    
    self.VipLine.frame = CGRectMake(0, 0, 0, 0);
    self.VipLine.hidden = YES;
    [self.view addSubview:self.VipLine];
    
    self.VipLab.frame = CGRectMake(0, 0, 0, 0);
    self.VipLab.hidden = YES;
    [self.view addSubview:self.VipLab];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showAdView:) name:@"showchapterAd" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showlastPageAd) name:@"showlastPageAd" object:nil];
    
    
}
-(void)showAdView:(NSNotification *)noc{
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger numberOfRuns = [noc.object integerValue];
        //内插广告view
        
        if ([QWReadingConfig sharedInstance].showDanmu == YES) {
            
            self.GDTAdView.frame = CGRectMake(15, self.currentVC.contentImg.frame.origin.y + numberOfRuns + 74 , UISCREEN_WIDTH-30, [QWReadingConfig sharedInstance].adBounds.size.height);
            QWReadingVC *vc = self.currentVC;
            VolumeVO *volume = [[QWReadingManager sharedInstance] currentVolumeVO];
            ChapterVO *chapter = volume.chapter[vc.currentPage.chapterIndex];
            [self.GDTAdView getBookId:[QWReadingManager sharedInstance].bookCD.nid getChapterId:chapter.nid getFree:chapter.ad_free getLastAd:chapter.lastPageAd];
            self.GDTAdView.hidden = NO;
            NSMutableDictionary *params = [NSMutableDictionary new];
            params[@"book"] = [QWReadingManager sharedInstance].bookCD.nid.stringValue;
            params[@"chapter"] = [chapter.nid stringValue];
            params[@"source"] = @"GDT";
            if ([chapter.free_chapter isEqualToNumber: [NSNumber numberWithInteger:1]]) {
                [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"InsertPayEvent" extra:params];
            }else{
                [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"InsertFreeEvent" extra:params];
            }
        }
        else{
            self.GDTAdView.frame = CGRectMake(15,self.currentVC.contentImg.frame.origin.y + numberOfRuns, UISCREEN_WIDTH-30, [QWReadingConfig sharedInstance].adBounds.size.height);
            QWReadingVC *vc = self.currentVC;
            VolumeVO *volume = [[QWReadingManager sharedInstance] currentVolumeVO];
            ChapterVO *chapter = volume.chapter[vc.currentPage.chapterIndex];
            [self.GDTAdView getBookId:[QWReadingManager sharedInstance].bookCD.nid getChapterId:chapter.nid getFree:chapter.ad_free getLastAd:chapter.lastPageAd];
            self.GDTAdView.hidden = NO;
            NSMutableDictionary *params = [NSMutableDictionary new];
            params[@"book"] = [QWReadingManager sharedInstance].bookCD.nid.stringValue;
            params[@"chapter"] = [chapter.nid stringValue];
            params[@"source"] = @"GDT";
            if ([chapter.free_chapter isEqualToNumber: [NSNumber numberWithInteger:1]]) {
                [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"InsertPayEvent" extra:params];
                
            }else{
                [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"InsertFreeEvent" extra:params];
                
            }
        }
        
    });
    
}
-(void)showlastPageAd{
    QWReadingVC *currentVC = self.currentVC;
    VolumeVO *volume = [[QWReadingManager sharedInstance] currentVolumeVO];
    ChapterVO *chapter = volume.chapter[currentVC.currentPage.chapterIndex];
    if (currentVC.currentPage.pageIndex * 100 / (chapter.pageCount - 1) != 100) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_VipLab.hidden = YES;
            self->_VipLine.hidden = YES;
        });
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.GDTAdView.frame = CGRectMake(15,self.containerViewTopConstraint.constant+self.currentVC.contentImg.frame.origin.y, UISCREEN_WIDTH-30, [QWReadingConfig sharedInstance].adBounds.size.height);
        QWReadingVC *vc = self.currentVC;
        VolumeVO *volume = [[QWReadingManager sharedInstance] currentVolumeVO];
        ChapterVO *chapter = volume.chapter[vc.currentPage.chapterIndex];
        [self.GDTAdView getBookId:[QWReadingManager sharedInstance].bookCD.nid getChapterId:chapter.nid getFree:chapter.ad_free getLastAd:chapter.lastPageAd];
        self.GDTAdView.hidden = NO;
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[@"book"] = [QWReadingManager sharedInstance].bookCD.nid.stringValue;
        params[@"chapter"] = [chapter.nid stringValue];
        params[@"source"] = @"GDT";
        if ([chapter.free_chapter isEqualToNumber: [NSNumber numberWithInteger:1]]) {
            [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"FootingPayEvent" extra:params];
            
        }else{
            [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"FootingFreeEvent" extra:params];
            
        }
        
            
            self->_VipLab.text = @"成为vip，免去正文广告>";
            self->_VipLab.textAlignment = 1;
            self->_VipLab.userInteractionEnabled = YES;
            [self->_VipLab bk_tapped:^{
                QWMyVIPVC *vc = [[QWMyVIPVC alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }];
            self->_VipLab.font = FONT(14);
            self->_VipLab.textColor = HRGB(0xD32323);
            self->_VipLab.frame = CGRectMake(0, kMaxY(self.GDTAdView.frame) + 100, UISCREEN_WIDTH, 14);
            self->_VipLab.hidden = NO;
            self->_VipLine.frame = CGRectMake((UISCREEN_WIDTH-[QWSize autoWidth:@"成为vip，免去正文广告>" width:500 height:14 num:14])/2, kMaxY(self->_VipLab.frame) + 3, [QWSize autoWidth:@"成为vip，免去正文广告>" width:500 height:14 num:14], 1);
            self->_VipLine.backgroundColor = HRGB(0xD32323);
            self->_VipLine.hidden = NO;
        
        
    });
}
-(void)readTask{
    int k = [[QWGlobalValue sharedInstance].readTaskTime intValue];
    
    k ++;
    [QWGlobalValue sharedInstance].readTaskTime = [NSNumber numberWithInt:k];
    if (k == 300) {
        [self finishReadTask];
    }
}
-(void)finishReadTask{
    if ([_timer isValid]) {
        
        [_timer invalidate];
        
    }
    _timer =nil;
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"task_type"] = @"2";
    NSString *url = [NSString stringWithFormat:@"%@/task/task_finished/",[QWOperationParam currentDomain]];
    QWOperationParam *pm = [QWInterface postWithUrl:url params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        NSDictionary *dict = aResponseObject;
        if ([dict[@"code"] intValue] == 0) {
            [self showToastWithTitle:dict[@"msg"] subtitle:nil type:ToastTypeError];
        }
        else{
            
        }
    }];
    pm.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:pm];
    
}
-(void)hideTop{
    self.topView.ishidden = @"1";
}

- (void)dealloc
{
    NSLog(@"%@ -> dealloc",[QWReadingPVC class]);
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (QWReadingLogic *)logic
{
    if (!_logic) {
        _logic = [QWReadingLogic logicWithOperationManager:self.operationManager];
    }
    
    return _logic;
}

-(UILabel *)VipLab{
    if (!_VipLab) {
        _VipLab = [UILabel new];
    }
    return _VipLab;
}

-(UIView *)VipLine{
    if (!_VipLine) {
        _VipLine = [UIView new];
    }
    return _VipLine;
}

- (void)getDiscuss
{
    NSString *bf_url = [QWReadingManager sharedInstance].bookCD.bf_url;
    if (bf_url.length) {
        self.topView.discussBtn.hidden = YES;
        
        WEAK_SELF;
        [self.logic getDiscussCountWithUrl:bf_url andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            STRONG_SELF;
            if (aResponseObject && !anError) {
                //                [self.topView.discussBtn setTitle:[NSString stringWithFormat:@"  讨论:%@  ", self.logic.count] forState:UIControlStateNormal];
                
                if ([self.logic.count compare:[NSNumber numberWithInt:99]] == NSOrderedDescending) {
                    self.topView.discussCountLab.text = @"99+";
                }
                else{
                    self.topView.discussCountLab.text = [NSString stringWithFormat:@"%@",self.logic.count];
                }
                
                [self.endView.discussBtn setTitle:[NSString stringWithFormat:@"  作品讨论（%@）  ", self.logic.count] forState:UIControlStateNormal];
            }
        }];
    }
}

- (void)getDirectory {
    [self.logic initReadingManagerWithChapterId:self.chapter_id completeBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (aResponseObject && !anError) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"QWDetail" bundle:nil];
            QWDetailDirectoryVC *vc = [sb instantiateViewControllerWithIdentifier:@"directory"];
            vc.volumeList = aResponseObject;
            BookVO *vo = [BookVO new];
            vo.nid = [self.logic.book_id toNumberIfNeeded];
            vc.bookVO = vo;
            vc.InId = @"2";
            NSMutableArray *vcs = self.navigationController.viewControllers.mutableCopy;
            QWDetailTVC *detailvc = [QWDetailTVC createFromStoryboardWithStoryboardID:@"detail" storyboardName:@"QWDetail"];
            detailvc.bookId = self.logic.book_id;
            [vcs insertObject:detailvc atIndex:vcs.count -1];
            [vcs insertObject:vc atIndex:vcs.count -1];
            [self.navigationController setViewControllers:vcs animated:NO];
            
            self.currentVC.loading = false;
            self.currentVC.loadingBook = false;
            [[NSNotificationCenter defaultCenter] postNotificationName:QWREADING_CHANGED object:nil];
        }
    }];
}
#pragma mark - 弹幕相关

- (void)clearDanmuPool {
    self.logic.bulletList = nil;
    self.logic.currentChapterId = nil;
}

- (void)updateDanmuStyle {
    self.sendDanmuBtn.count = @(self.currentPageDanmuCount);
    [self.sendDanmuBtn update];
    if (self.currentPageDanmuCount && [QWReadingConfig sharedInstance].showDanmu) {
        self.danmuCountLabel.hidden = false;
        self.danmuCountLabel.text = [NSString stringWithFormat:@" %ld ",(long)self.currentPageDanmuCount];
        self.danmuCountLabel.textColor = [QWReadingConfig sharedInstance].readingColor;
    } else {
        self.danmuCountLabel.hidden = true;
    }
    
    switch ([QWReadingConfig sharedInstance].readingBG) {
        case QWReadingBGDefault:
            self.danmuBgImageView.image = [UIImage imageNamed:@"reading_bg_1"];
            self.danmuBgImageView.backgroundColor = nil;
            [self.cancelDanmuViewBtn setBackgroundImage:[UIImage imageNamed:@"reading_danmu_cancel_lighted"] forState:UIControlStateNormal];
            [self.danmuCountLabel setBackgroundColor:HRGB(0x99825a)];
            break;
        case QWReadingBGBlack:
            self.danmuBgImageView.image = nil;
            self.danmuBgImageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"reading_bg_2"]];
            [self.cancelDanmuViewBtn setBackgroundImage:[UIImage imageNamed:@"reading_danmu_cancel_black"] forState:UIControlStateNormal];
            [self.danmuCountLabel setBackgroundColor:HRGB(0x202125)];
            
            break;
        case QWReadingBGGreen:
            self.danmuBgImageView.image = nil;
            self.danmuBgImageView.backgroundColor = HRGB(0xceefce);
            [self.cancelDanmuViewBtn setBackgroundImage:[UIImage imageNamed:@"reading_danmu_cancel_lighted"] forState:UIControlStateNormal];
            [self.danmuCountLabel setBackgroundColor:HRGB(0xceefce)];
            break;
        case QWReadingBGPink:
            self.danmuBgImageView.image = nil;
            self.danmuBgImageView.backgroundColor = HRGB(0xfcdfe7);
            [self.cancelDanmuViewBtn setBackgroundImage:[UIImage imageNamed:@"reading_danmu_cancel_lighted"] forState:UIControlStateNormal];
            [self.danmuCountLabel setBackgroundColor:HRGB(0xfcdfe7)];
            break;
        default:
            self.danmuBgImageView.image = [UIImage imageNamed:@"reading_bg_1"];
            self.danmuBgImageView.backgroundColor = nil;
            [self.cancelDanmuViewBtn setBackgroundImage:[UIImage imageNamed:@"reading_danmu_cancel_lighted"] forState:UIControlStateNormal];
            [self.danmuCountLabel setBackgroundColor:HRGB(0x99825a)];
            break;
    }
}

- (void)showDanmuView {
    self.containerViewTopConstraint.constant = [QWReadingConfig sharedInstance].danmuHeight - 10;
    self.danmuView.hidden = false;
    self.cancelDanmuViewBtn.hidden = false;
    self.danmuCountLabel.hidden = false;
    
}

- (void)closeDanmuView {
    
    self.danmuView.hidden = true;
    self.cancelDanmuViewBtn.hidden = true;
    self.danmuCountLabel.hidden = true;
    self.containerViewTopConstraint.constant = 0;
    
    [self.sendDanmuView hideWithAnimated]; //若在发送弹幕的时候也需要关闭发送弹框
    [self clearDanmuPool];
    [self.bulletManager stop];
    
}


- (void)getCurrentChapterDanmuPool {
    NSArray *bulletArray = self.logic.bulletList.results;
    self.currentPageDanmuCount = bulletArray.count;
    if ([QWReadingConfig sharedInstance].showDanmu) { //需要弹幕的时候才加载进弹幕池
        [self.bulletManager loadBulletArray:bulletArray];
    }
}

- (void)initBulletManager {
    self.bulletManager = [[QWBulletManager alloc]init];
    WEAK_SELF;
    self.bulletManager.generateBulletBlock = ^(QWBulletView *bulletView) {
        STRONG_SELF;
        [self addBulletView: bulletView];
    };
}

- (void)requestBullets {
    VolumeVO *volume = [[QWReadingManager sharedInstance] currentVolumeVO];
    ChapterVO *chapter = volume.chapter[_currentVC.currentPage.chapterIndex];
    if ([chapter.nid.stringValue isEqualToString:self.logic.currentChapterId] && self.logic.bulletList.results.count > 0) {
        return;
    }
    
    WEAK_SELF;
    [self.logic getBulletListWithChapterId:chapter.nid.stringValue andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (!anError && aResponseObject) {
            [self getCurrentChapterDanmuPool];
            [self updateDanmuStyle];
        }
    }];
    
}

- (void)addBulletView:(QWBulletView *)bulletView {
    bulletView.frame = CGRectMake(CGRectGetWidth(self.view.frame), 24 * bulletView.trajectory + 3, CGRectGetWidth(bulletView.bounds), CGRectGetHeight(bulletView.bounds));
    [self.danmuView addSubview:bulletView];
    [bulletView startAnimation];
}


- (void)onPressedDanmuBtn{
    if ([QWReadingConfig sharedInstance].showDanmu) {
        [self.sendDanmuView showWithAnimated];
    }
    else {
        self.GDTAdView.hidden = YES;
        _VipLine.hidden = YES;
        _VipLab.hidden = YES;
        [self showDanmuView];
        [QWReadingConfig sharedInstance].showDanmu = true;
        [[QWReadingConfig sharedInstance] saveData];
        [self getCurrentChapterDanmuPool];
        
        [[QWReadingManager sharedInstance] recordBookDanmuStatus:false];
    }
}
- (IBAction)onPressedCancelDanmu:(UIButton *)sender {
    [self closeDanmuView];
    self.GDTAdView.hidden = YES;
    _VipLine.hidden = YES;
    _VipLab.hidden = YES;
    [QWReadingConfig sharedInstance].showDanmu = false;
    [[QWReadingConfig sharedInstance] saveData];
    
    [[QWReadingManager sharedInstance] recordBookDanmuStatus:true];
}

#pragma mark - delegate

- (void)hideDirectoryVC:(QWReadingDirectoryVC *)directoryVC
{
    [self.rightConstraints autoRemove];
    self.rightConstraints = [self.directoryView autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.view];
    WEAK_SELF;
    [UIView animateWithDuration:.3f animations:^{
        STRONG_SELF;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        STRONG_SELF;
        self.directoryView.hidden = YES;
    }];
}

- (void)directoryVC:(QWReadingDirectoryVC *)directoryVC didClickChapterAtIndex:(NSIndexPath*)index volumes:(VolumeList *)volumes Book:(BookVO *)book{
    
    QWReadingVC *currentVC = self.currentVC;
    VolumeVO *volume = volumes.results[index.section];
    volume.collection = book.collection;
    if (!currentVC || currentVC.loading) {
        return;
    }
    
    QWReadingVC *vc = [[QWReadingManager sharedInstance] getChapterReadingVCWithBook:book volumes:volumes indexPath:index currentVC:currentVC];
    //    QWReadingVC *vc = [[QWReadingManager sharedInstance] getChapterReadingVCWithChapterIndex:index.row currentVC:currentVC];
    
    if (!vc) {
        return ;
    }
    
    [self.rightConstraints autoRemove];
    self.rightConstraints = [self.directoryView autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.view];
    WEAK_SELF;
    [UIView animateWithDuration:.3f animations:^{
        STRONG_SELF;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        STRONG_SELF;
        self.directoryView.hidden = YES;
        self.currentVC = vc;
        [self.pageViewController setViewControllers:@[vc, [vc.storyboard instantiateViewControllerWithIdentifier:@"placeholder"]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }];
}

- (void)directoryVC:(QWReadingDirectoryVC *)directoryVC didClickChapterAtIndex:(NSInteger)index
{
    QWReadingVC *currentVC = self.currentVC;
    if (!currentVC || currentVC.loading) {
        return;
    }
    
    QWReadingVC *vc = [[QWReadingManager sharedInstance] getChapterReadingVCWithChapterIndex:index currentVC:currentVC];
    
    if (!vc) {
        return ;
    }
    
    [self.rightConstraints autoRemove];
    self.rightConstraints = [self.directoryView autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.view];
    WEAK_SELF;
    [UIView animateWithDuration:.3f animations:^{
        STRONG_SELF;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        STRONG_SELF;
        self.directoryView.hidden = YES;
        self.currentVC = vc;
        [self.pageViewController setViewControllers:@[vc, [vc.storyboard instantiateViewControllerWithIdentifier:@"placeholder"]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }];
}

- (void)topView:(QWReadingTopView *)view didClickedBackBtn:(id)sender
{
    [[QWReadingManager sharedInstance] stopReading];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)topView:(QWReadingTopView *)view didClickedDownload:(id)sender{
    [[QWReadingManager sharedInstance] stopReading];
    if (self.navigationController.viewControllers.count>=2) {
        QWDetailDirectoryVC *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count -1-1];
        vc.InId = @"1";
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
}
- (void)topView:(QWReadingTopView *)view didClickedPictureBtn:(id)sender
{
    [self toPictureVC];
}

- (void)topView:(QWReadingTopView *)view didClickedDiscussBtn:(id)sender
{
    [self toDiscussVC];
}

- (void)topView:(QWReadingTopView *)view didClickedAloudBtn:(id)sender
{
    
    self.isAloud = YES;
    [self.aloudSettingView showWithAnimated];
    [self startAloud];
}

- (void)bottomView:(QWReadingBottomView *)view didClickedDirectoryBtn:(id)sender
{
    self.directoryView.hidden = NO;
    [self.directoryVC updateWithBook:[QWReadingManager sharedInstance].bookCD volume:[[QWReadingManager sharedInstance] currentVolumeVO] volumeList:[QWReadingManager sharedInstance].volumes];
    [self.rightConstraints autoRemove];
    self.rightConstraints = [self.directoryView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view];
    WEAK_SELF;
    [UIView animateWithDuration:.3f animations:^{
        STRONG_SELF;
        [self.view layoutIfNeeded];
    }];
    
    [self hideAllSettingViews];
}

- (void)bottomView:(QWReadingBottomView *)view didClickedLightBtn:(id)sender {
    [self.bottomView hideWithAnimated];
    [self.progressMessageView hideWithAnimated];
    [self.brightnessView showWithAnimated];
}

- (void)bottomView:(QWReadingBottomView *)view didClickedProgressBtn:(id)sender
{
    QWReadingVC *vc = self.currentVC;
    VolumeVO *volume = [[QWReadingManager sharedInstance] currentVolumeVO];
    ChapterVO *chapter = volume.chapter[vc.currentPage.chapterIndex];
    
    [self.bottomView updateWithCurrentPageIndex:vc.currentPage.pageIndex andPageCount:chapter.pageCount];
    [self.progressMessageView updateWithProgress:vc.currentPage.pageIndex * 100 / (chapter.pageCount - 1) andMessage:[NSString stringWithFormat:@"%@ %@", volume.title, chapter.title]];
    
    [self.bottomView hideWithAnimated];
    [self.progressView showWithAnimated];
    [self.progressMessageView showWithAnimated];
}

- (void)bottomView:(QWReadingBottomView *)view didClickedChargeBtn:(id)sender
{
    [self doCharge:NO];
}

- (void)bottomView:(QWReadingBottomView *)view didClickedSettingBtn:(id)sender
{
    [self.bottomView hideWithAnimated];
    [self.progressMessageView hideWithAnimated];
    [self.settingView showWithAnimated];
}

- (void)gotoNextChapterClickInProgressView:(QWReadingBottomView *)view
{
    self.GDTAdView.hidden = YES;
    _VipLine.hidden = YES;
    _VipLab.hidden = YES;
    QWReadingVC *currentVC = self.currentVC;
    if (!currentVC || currentVC.loading) {
        [self showLoadingWithMessage:@"章节正文正在加载，请稍等" hideAfter:1.0];
        return;
    }
    
    QWReadingVC *vc = [[QWReadingManager sharedInstance] getNextChapterReadingVCWithCurrentReadingVC:currentVC];
    
    if (!vc) {
        [self showLoadingWithMessage:@"没有下一章了" hideAfter:1.0];
        return ;
    }
    
    self.currentVC = vc;
    [self.pageViewController setViewControllers:@[vc, [vc.storyboard instantiateViewControllerWithIdentifier:@"placeholder"]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    VolumeVO *volume = [[QWReadingManager sharedInstance] currentVolumeVO];
    ChapterVO *chapter = volume.chapter[currentVC.currentPage.chapterIndex];
    [self.progressView updateWithCurrentPageIndex:0 andPageCount:chapter.pageCount];
    [self.progressMessageView updateWithProgress:0 andMessage:[NSString stringWithFormat:@"%@ %@", volume.title, chapter.title]];
}

- (void)gotoPreviousChapterClickInProgressView:(QWReadingBottomView *)view
{
    self.GDTAdView.hidden = YES;
    _VipLine.hidden = YES;
    _VipLab.hidden = YES;
    QWReadingVC *currentVC = self.currentVC;
    if (!currentVC || currentVC.loading) {
        [self showLoadingWithMessage:@"章节正文正在加载，请稍等" hideAfter:1.0];
        return;
    }
    
    QWReadingVC *vc = [[QWReadingManager sharedInstance] getPreviousChapterReadingVCWithCurrentReadingVC:currentVC];
    
    if (!vc) {
        [self showLoadingWithMessage:@"没有上一章了" hideAfter:1.0];
        return ;
    }
    
    self.currentVC = vc;
    [self.pageViewController setViewControllers:@[vc, [vc.storyboard instantiateViewControllerWithIdentifier:@"placeholder"]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    
    VolumeVO *volume = [[QWReadingManager sharedInstance] currentVolumeVO];
    ChapterVO *chapter = volume.chapter[currentVC.currentPage.chapterIndex];
    [self.progressView updateWithCurrentPageIndex:0 andPageCount:chapter.pageCount];
    [self.progressMessageView updateWithProgress:0 andMessage:[NSString stringWithFormat:@"%@ %@", volume.title, chapter.title]];
}

- (void)progressView:(QWReadingBottomView *)view changeToPageIndex:(NSInteger)pageIndex
{
    self.GDTAdView.hidden = YES;
    _VipLine.hidden = YES;
    _VipLab.hidden = YES;
    QWReadingVC *currentVC = self.currentVC;
    if (currentVC.isLoading) {
        return ;
    }
    
    QWReadingVC *vc = [[QWReadingManager sharedInstance] getPageAtIndex:pageIndex readingVC:currentVC];
    
    if (!vc) {
        return ;
    }
    
    UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionForward;
    if (currentVC.currentPage.pageIndex > pageIndex) {
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    
    self.currentVC = vc;
    [self.pageViewController setViewControllers:@[vc, [vc.storyboard instantiateViewControllerWithIdentifier:@"placeholder"]] direction:direction animated:YES completion:nil];
    
    VolumeVO *volume = [[QWReadingManager sharedInstance] currentVolumeVO];
    ChapterVO *chapter = volume.chapter[currentVC.currentPage.chapterIndex];
    [self.progressMessageView updateWithProgress:pageIndex * 100 / (chapter.pageCount - 1) andMessage:[NSString stringWithFormat:@"%@ %@", volume.title, chapter.title]];
}

- (void)endView:(QWReadingEndView *)view onPressedChargeBtn:(id)sender
{
    [self hideAllSettingViews];
    [self doCharge:NO];
}

- (void)endView:(QWReadingEndView *)view onPressedDiscussBtn:(id)sender
{
    [self hideAllSettingViews];
    [self toDiscussVC];
}

- (void)endView:(QWReadingEndView *)view onPressedHideBtn:(id)sender
{
    [[QWReadingManager sharedInstance] stopReading];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)sendDanmuWithString:(NSString *)string {
    
    VolumeVO *volume = [[QWReadingManager sharedInstance] currentVolumeVO];
    ChapterVO *chapter = volume.chapter[_currentVC.currentPage.chapterIndex];
    
    BulletVO *bullet = [BulletVO new];
    bullet.value = string;
    NSRange range = self.currentVC.currentPage.range;
    NSInteger index = ( 2 * range.location + range.length) / 2;
    bullet.key = index;
    bullet.avatar = [QWGlobalValue sharedInstance].user.avatar;
    bullet.isMine = true;
    
    WEAK_SELF;
    [self.logic submitDanmuWithChaperId:chapter.nid.stringValue key:@(index) content:string completeBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && [code isKindOfClass:[NSNumber class]] && ! [code isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"data"];
                if ([message isKindOfClass:[NSString class]] && message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:@"发送弹幕失败" subtitle:nil type:ToastTypeAlert];
                }
            }
            else {
                [self.bulletManager addBullet:bullet];
                
                NSMutableArray *results = self.logic.bulletList.results.mutableCopy;
                [results addObject:bullet];
                self.logic.bulletList.results = results.copy;
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }
        
        [self hideLoading];
    }];
}
#pragma mark - actions

- (void)doCharge:(BOOL)heavy
{
    [(QWTBC *)self.tabBarController doChargeWithBook:[QWReadingManager sharedInstance].bookCD.toBookVO heavy:heavy];
}

- (void)showEndView
{
    self.showSetting = YES;
    [self.endView showWithAnimated];
    [self.pageViewController.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIPanGestureRecognizer class]]) {
            UIPanGestureRecognizer *tap = obj;
            tap.enabled = NO;
        }
    }];
}

- (void)toPictureVC
{
    [self hideAllSettingViews];
    QWReadingVC *readingVC = self.currentVC;
    if (readingVC.isPicture && readingVC.pictureName) {
        QWPictureVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"picture"];
        vc.pictures = @[readingVC.pictureName];
        VolumeVO *volume = [[QWReadingManager sharedInstance] currentVolumeVO];
        vc.volumeId = volume.nid.stringValue;
        ChapterVO *chapter = volume.chapter[readingVC.currentPage.chapterIndex];
        vc.chapterId = chapter.nid.stringValue;
        vc.bookId = [QWReadingManager sharedInstance].bookCD.nid.stringValue;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)toDiscussVC
{
    NSString *bf_url = [QWReadingManager sharedInstance].bookCD.bf_url;
    if (bf_url.length) {
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"url"] = bf_url;
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"discuss" andParams:params]];
    }
}

- (void)gotoMoreSetting
{
    [self hideAllSettingViews];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"QWMyCenter" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"setting"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showSettingViews
{
    
    self.showSetting = YES;
    if ([QWReadingConfig sharedInstance].showDanmu) {
        
    }
    if (self.isAloud == YES) {
        [self.aloudSettingView showWithAnimated];
    }
    else{
        [self.topView showWithAnimated];
        [self.bottomView showWithAnimated];
        [self.progressMessageView showWithAnimated];
        
    }
    [self.pageViewController.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIPanGestureRecognizer class]]) {
            UIPanGestureRecognizer *tap = obj;
            tap.enabled = NO;
        }
    }];
    
}

- (void)hideAllSettingViews
{
    self.showSetting = NO;
    if ([QWReadingConfig sharedInstance].showDanmu) {
        
    }
    
    [self.topView hideWithAnimated];
    [self.bottomView hideWithAnimated];
    [self.brightnessView hideWithAnimated];
    [self.progressView hideWithAnimated];
    [self.progressMessageView hideWithAnimated];
    [self.settingView hideWithAnimated];
    [self.endView hideWithAnimated];
    [self.aloudSettingView hideWithAnimated];
    
    
    [self.pageViewController.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIPanGestureRecognizer class]]) {
            UIPanGestureRecognizer *tap = obj;
            tap.enabled = YES;
        }
    }];
    
}
-(void)nextPage{
    QWReadingVC *currentVC = self.currentVC;
    QWReadingVC *vc = ({
        if ([currentVC isLoading]) {//正在加载数据
            [self showLoadingWithMessage:@"章节正文正在加载，请稍等" hideAfter:1.0];
        }
        
        if (![currentVC nextPage]) {//没有下一页
            [self showLoadingWithMessage:@"没有下一页了" hideAfter:1.0];
            [self showEndView];
            [self pauseAloud];
            
            
        }
        self.GDTAdView.hidden = YES;
        _VipLine.hidden = YES;
        _VipLab.hidden = YES;
        [[QWReadingManager sharedInstance] getNextPageReadingVCWithCurrentReadingVC:currentVC];
    });
    if (vc) {
        self.currentVC = vc;
        [self.pageViewController setViewControllers:@[vc, [vc.storyboard instantiateViewControllerWithIdentifier:@"placeholder"]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
}
#pragma mark - pageview delegate
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    self.GDTAdView.hidden = YES;
    _VipLine.hidden = YES;
    _VipLab.hidden = YES;
    if ([viewController isKindOfClass:[QWReadingVC class]]) {
        if ([(QWReadingVC *)viewController isLoading]) {//正在加载数据
            [self showLoadingWithMessage:@"章节正文正在加载，请稍等" hideAfter:1.0];
            return nil;
        }
        
        if (![(QWReadingVC *)viewController previousPage]) {//没有上一页
            [self showLoadingWithMessage:@"没有上一页了" hideAfter:1.0];
            return nil;
        }
        
        self.currentVC = (id)viewController;
        
        return [self.storyboard instantiateViewControllerWithIdentifier:@"placeholder"];
    }
    
    QWReadingVC *vc = [[QWReadingManager sharedInstance] getPreviousPageReadingVCWithCurrentReadingVC:self.currentVC];
    self.currentVC = vc;
    return vc;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    self.GDTAdView.hidden = YES;
    _VipLine.hidden = YES;
    _VipLab.hidden = YES;
    if ([viewController isKindOfClass:[QWReadingVC class]]) {
        
        if ([(QWReadingVC *)viewController isLoading]) {//正在加载数据
            [self showLoadingWithMessage:@"章节正文正在加载，请稍等" hideAfter:1.0];
            return nil;
        }
        
        if (![(QWReadingVC *)viewController nextPage]) {//没有下一页
            [self showLoadingWithMessage:@"没有下一页了" hideAfter:1.0];
            [self showEndView];
            return nil;
        }
        
        self.currentVC = (id)viewController;
        
        return [self.storyboard instantiateViewControllerWithIdentifier:@"placeholder"];
    }
    
    QWReadingVC *vc = [[QWReadingManager sharedInstance] getNextPageReadingVCWithCurrentReadingVC:self.currentVC];
    self.currentVC = vc;
    return vc;
}

#pragma mark - memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[QWReadingManager sharedInstance] didReceiveMemoryWarning];
}

- (void)resize:(CGSize)size
{
    [QWReadingConfig sharedInstance].landscape = size.width > size.height;
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        QWReadingVC *readingVC = (id)self.currentVC;
        [readingVC update];
    }
}

#pragma mark - 朗读相关
-(void)handleInterreption:(NSNotification *)sender
{
    if([[BDSSpeechSynthesizer sharedInstance] synthesizerStatus] == BDS_SYNTHESIZER_STATUS_WORKING)
    {
        //        [_iFlySpeechSynthesizer pauseSpeaking];
        //        _state = Paused;
        [[BDSSpeechSynthesizer sharedInstance] pause];
    }
    else
    {
        [self goOnAloud];
    }
}

-(void)exitAloud{
    self.isAloud = NO;
    isSpeak = NO;
    [self hideAllSettingViews];
    //    [_iFlySpeechSynthesizer stopSpeaking];
    //    _state = NotStart;
    [[BDSSpeechSynthesizer sharedInstance] cancel];
}
-(void)pauseAloud{
    self.isPause = YES;
    self.isAloud = YES;
    [[BDSSpeechSynthesizer sharedInstance] cancel];
}
-(void)startAloud{
    //    [_iFlySpeechSynthesizer stopSpeaking];
    QWReadingVC *readingVC = self.currentVC;
    isSpeak = YES;
    NSLog(@"下一页朗读");
    if (self.isAloud == YES){
        
        if (readingVC.isPicture || readingVC.isChapter ) {
            [self nextPageAloud];
        }
        else{
            NSInteger location = self.currentVC.currentPage.range.location;
            NSInteger lenth = self.currentVC.currentPage.range.length;
            NSString* str= self.aloudStr;
            NSString *strJieQu1 = [str substringFromIndex:location];
            NSString *strJieQu2 = [strJieQu1 substringToIndex:lenth];
            self.contentArr = [strJieQu2 componentsSeparatedByString:@"\n"];
//            NSLog(@"self.contentArr = %@",self.contentArr);
            if (self.aloudParagraph == 0) {
                NSInteger sentenceID;
                NSError* err = nil;
                if(isSpeak)
                    sentenceID = [[BDSSpeechSynthesizer sharedInstance] speakSentence:self.contentArr[0] withError:&err];
                else
                    sentenceID = [[BDSSpeechSynthesizer sharedInstance] synthesizeSentence:self.contentArr[0] withError:&err];
                if(err == nil){
                    
                }
                else{
                    [self displayError:err withTitle:@"Add sentence Error"];
                }
            }
            else{
                NSInteger sentenceID;
                NSError* err = nil;
                if(isSpeak)
                    sentenceID = [[BDSSpeechSynthesizer sharedInstance] speakSentence:self.contentArr[self.aloudParagraph]  withError:&err];
                else
                    sentenceID = [[BDSSpeechSynthesizer sharedInstance] synthesizeSentence:self.contentArr[self.aloudParagraph]  withError:&err];
                if(err == nil){
                    
                }
                else{
                    [self displayError:err withTitle:@"Add sentence Error"];
                }
            }
        }
        
    }
    else{
        
    }
    
}
-(void)createAloudStr:(NSNotification *)noc{
    NSMutableAttributedString * resutlAtt = [[NSMutableAttributedString alloc]initWithAttributedString:noc.object];
    self.aloudStr = resutlAtt.mutableString;
    
}
-(void)suspendedAloud{
    if([[BDSSpeechSynthesizer sharedInstance] synthesizerStatus] == BDS_SYNTHESIZER_STATUS_WORKING){
        [[BDSSpeechSynthesizer sharedInstance] pause];
    }
}
-(void)goOnAloud{
    //    [_iFlySpeechSynthesizer resumeSpeaking];
    //    _state = Playing;
    if([[BDSSpeechSynthesizer sharedInstance] synthesizerStatus] == BDS_SYNTHESIZER_STATUS_PAUSED){
        [[BDSSpeechSynthesizer sharedInstance] resume];
    }
}
- (void)initSynthesizer
{
    
    [self startAloud];
}
#pragma mark - IFlySpeechSynthesizerDelegate

/**
 callback of starting playing
 Notice：
 Only apply to normal TTS
 **/
- (void)onSpeakBegin
{
    self.isCanceled = NO;
    if (_state  != Playing) {
        //        [_popUpView showText: NSLocalizedString(@"T_TTS_Play", nil)];
    }
    _state = Playing;
}



/**
 callback of buffer progress
 Notice：
 Only apply to normal TTS
 **/
- (void)onBufferProgress:(int) progress message:(NSString *)msg
{
    NSLog(@"buffer progress %2d%%. msg: %@.", progress, msg);
}




/**
 callback of playback progress
 Notice：
 Only apply to normal TTS
 **/
- (void) onSpeakProgress:(int) progress beginPos:(int)beginPos endPos:(int)endPos
{
    
}
/**
 callback of pausing player
 Notice：
 Only apply to normal TTS
 **/
- (void)onSpeakPaused
{
    
    _state = Paused;
}


/**
 callback of TTS completion
 **/
- (void)onCompleted:(IFlySpeechError *) error
{
    self.aloudParagraph ++;
    if (self.aloudParagraph < self.contentArr.count) {
        [_iFlySpeechSynthesizer startSpeaking:self.contentArr[self.aloudParagraph]];
        //        [[NSNotificationCenter defaultCenter]postNotificationName:@"ttsFreshUI" object:self.contentArr[self.aloudParagraph]];
    }
    else{
        [self nextPageAloud];
    }
    
    
}

-(void)nextPageAloud{
    self.aloudParagraph = 0;
    if (self.isAloud == YES) {
        //        _state = NotStart;
        QWReadingVC *currentVC = self.currentVC;
        QWReadingVC *vc = ({
            if ([currentVC isLoading]) {//正在加载数据
                [self showLoadingWithMessage:@"章节正文正在加载，请稍等" hideAfter:1.0];
            }
            
            if (![currentVC nextPage]) {//没有下一页
                [self showLoadingWithMessage:@"没有下一页了" hideAfter:1.0];
                [self showEndView];
                [self pauseAloud];
                
                
            }
            self.GDTAdView.hidden = YES;
            _VipLine.hidden = YES;
            _VipLab.hidden = YES;
            [[QWReadingManager sharedInstance] getNextPageReadingVCWithCurrentReadingVC:currentVC];
        });
        if (vc) {
            self.currentVC = vc;
            [self.pageViewController setViewControllers:@[vc, [vc.storyboard instantiateViewControllerWithIdentifier:@"placeholder"]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        }
    }
    else{
        
    }
    
}
#pragma mark - Playing For URI TTS

- (void)playUriAudio
{
    TTSConfig *instance = [TTSConfig sharedInstance];
    //    [_popUpView showText: NSLocalizedString(@"M_TTS_URIPlay", nil)];
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    _audioPlayer = [[PcmPlayer alloc] initWithFilePath:_uriPath sampleRate:[instance.sampleRate integerValue]];
    [_audioPlayer play];
    
}

#pragma mark - 百度TTS
-(void)configureSDK{
    NSLog(@"TTS version info: %@", [BDSSpeechSynthesizer version]);
    [BDSSpeechSynthesizer setLogLevel:BDS_PUBLIC_LOG_VERBOSE];
    [[BDSSpeechSynthesizer sharedInstance] setSynthesizerDelegate:self];
    [self configureOnlineTTS];
    [self configureOfflineTTS];
    
}
-(void)configureOnlineTTS{
    
    [[BDSSpeechSynthesizer sharedInstance] setApiKey:API_KEY withSecretKey:SECRET_KEY];
    
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[BDSSpeechSynthesizer sharedInstance] setSynthParam:@(BDS_SYNTHESIZER_SPEAKER_FEMALE) forKey:BDS_SYNTHESIZER_PARAM_SPEAKER];
    //    [[BDSSpeechSynthesizer sharedInstance] setSynthParam:@(10) forKey:BDS_SYNTHESIZER_PARAM_ONLINE_REQUEST_TIMEOUT];
    
}
-(void)configureOfflineTTS{
    
    NSError *err = nil;
    // 在这里选择不同的离线音库（请在XCode中Add相应的资源文件），同一时间只能load一个离线音库。根据网络状况和配置，SDK可能会自动切换到离线合成。
    NSString* offlineEngineSpeechData = [[NSBundle mainBundle] pathForResource:@"Chinese_And_English_Speech_Female" ofType:@"dat"];
    
    NSString* offlineChineseAndEnglishTextData = [[NSBundle mainBundle] pathForResource:@"Chinese_And_English_Text" ofType:@"dat"];
    
    err = [[BDSSpeechSynthesizer sharedInstance] loadOfflineEngine:offlineChineseAndEnglishTextData speechDataPath:offlineEngineSpeechData licenseFilePath:nil withAppCode:BAIDUAPP_ID];
    if(err){
        [self displayError:err withTitle:@"Offline TTS init failed"];
        return;
    }
    //    [TTSConfigViewController loadedAudioModelWithName:@"Chinese female" forLanguage:@"chn"];
    //    [TTSConfigViewController loadedAudioModelWithName:@"English female" forLanguage:@"eng"];
}
-(void)displayError:(NSError*)error withTitle:(NSString*)title{
    NSString* errMessage = error.localizedDescription;
    if ([errMessage isEqualToString:@""]) {
        
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:errMessage preferredStyle:UIAlertControllerStyleAlert];
    if(alert){
        UIAlertAction* dismiss = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {}];
        [alert addAction:dismiss];
        //        [self exitAloud];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else{
        UIAlertView *alertv = [[UIAlertView alloc] initWithTitle:title message:errMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        if(alertv){
            [alertv show];
        }
    }
}

#pragma mark - implement BDSSpeechSynthesizerDelegate
- (void)synthesizerStartWorkingSentence:(NSInteger)SynthesizeSentence{
    NSLog(@"Did start synth %ld", (long)SynthesizeSentence);
    QWReadingVC *readingVC = self.currentVC;
    if (readingVC.isSubscribe == NO) {
        [self showLoadingWithMessage:@"请订阅后朗读" hideAfter:1.0];
        [self exitAloud];
    }
}
- (void)synthesizerFinishWorkingSentence:(NSInteger)SynthesizeSentence{
    NSLog(@"Did finish synth, %ld", (long)SynthesizeSentence);
}
- (void)synthesizerSpeechStartSentence:(NSInteger)SpeakSentence{
    NSLog(@"Did start speak %ld", (long)SpeakSentence);
}
- (void)synthesizerSpeechEndSentence:(NSInteger)SpeakSentence{
    NSLog(@"Did end speak %ld", (long)SpeakSentence);
    self.aloudParagraph ++;
    if (self.aloudParagraph < self.contentArr.count) {
        //        [_iFlySpeechSynthesizer startSpeaking:self.contentArr[self.aloudParagraph]];
        //        [[NSNotificationCenter defaultCenter]postNotificationName:@"ttsFreshUI" object:self.contentArr[self.aloudParagraph]];
        NSLog(@"[self.contentArr[self.aloudParagraph] = %@",self.contentArr[self.aloudParagraph]);
        
        if ([self.contentArr[self.aloudParagraph] isEqualToString:@""]) {
            [self nextPageAloud];
        }
        else{
            NSInteger sentenceID;
            NSError* err = nil;
            if(isSpeak)
                sentenceID = [[BDSSpeechSynthesizer sharedInstance] speakSentence:self.contentArr[self.aloudParagraph]  withError:&err];
            else
                sentenceID = [[BDSSpeechSynthesizer sharedInstance] synthesizeSentence:self.contentArr[self.aloudParagraph]  withError:&err];
            if(err == nil){
                
            }
            else{
                [self displayError:err withTitle:@"Add sentence Error"];
            }
        }
        
    }
    else{
        [self nextPageAloud];
    }
}
- (void)synthesizerNewDataArrived:(NSData *)newData
                       DataFormat:(BDSAudioFormat)fmt
                   characterCount:(int)newLength
                   sentenceNumber:(NSInteger)SynthesizeSentence{
}
- (void)synthesizerTextSpeakLengthChanged:(int)newLength
                           sentenceNumber:(NSInteger)SpeakSentence{
}
- (void)synthesizerdidPause{
}
- (void)synthesizerResumed{
    
}
- (void)synthesizerCanceled{
    NSLog(@"Did cancel");
}
- (void)synthesizerErrorOccurred:(NSError *)error
                        speaking:(NSInteger)SpeakSentence
                    synthesizing:(NSInteger)SynthesizeSentence{
    [[BDSSpeechSynthesizer sharedInstance] cancel];
    [self displayError:error withTitle:@"Synthesis failed"];
}

#pragma mark - 广告相关
#pragma mark - 视频广告
-(void)watchAD{
//    if ([[YumiMediationVideo sharedInstance] isReady]) {
//        [[YumiMediationVideo sharedInstance] presentFromRootViewController:self];
//    } else {
//        NSLog(@"Ad wasn't ready");
//
//    }
    [self.rewardedVideoAd showAdFromRootViewController:self];
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
    QWReadingVC *vc = self.currentVC;
    VolumeVO *volume = [[QWReadingManager sharedInstance] currentVolumeVO];
    ChapterVO *chapter = volume.chapter[vc.currentPage.chapterIndex];
    
    NSMutableDictionary *adparam = [NSMutableDictionary new];
    adparam[@"token"] = [QWGlobalValue sharedInstance].token;
    adparam[@"device_id"] = [QWGlobalValue sharedInstance].deviceToken;
    adparam[@"chapter_id"] = chapter.nid;
    
    QWOperationParam *globalAdpm = [QWInterface postWithUrl:[NSString stringWithFormat:@"%@/ad/chapter_finish/",[QWOperationParam currentDomain]] params:adparam andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        
        vc.wacthAdData = aResponseObject[@"data"];
        chapter.contentVO = nil;
        chapter.completed = false;
        [vc WhetherWatchAd];
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[@"book"] = [chapter.book stringValue];
        params[@"chapter"] = [chapter.nid stringValue];
        params[@"source"] = @"YUMI";
        [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"TipPayEvent" extra:params];
        [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"TipPayClickEvent" extra:params];
        NSLog(@"广告 = %@",params);
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
    QWReadingVC *vc = self.currentVC;
    VolumeVO *volume = [[QWReadingManager sharedInstance] currentVolumeVO];
    ChapterVO *chapter = volume.chapter[vc.currentPage.chapterIndex];
    
    NSMutableDictionary *adparam = [NSMutableDictionary new];
    adparam[@"token"] = [QWGlobalValue sharedInstance].token;
    adparam[@"device_id"] = [QWGlobalValue sharedInstance].deviceToken;
    adparam[@"chapter_id"] = chapter.nid;
    
    //付费章节插图
    
    QWOperationParam *globalAdpm = [QWInterface postWithUrl:[NSString stringWithFormat:@"%@/ad/chapter_finish/",[QWOperationParam currentDomain]] params:adparam andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        
        vc.wacthAdData = aResponseObject[@"data"];
        chapter.contentVO = nil;
        chapter.completed = false;
        [vc WhetherWatchAd];
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[@"book"] = [volume.book.nid stringValue];
        params[@"chapter"] = [chapter.nid stringValue];
        params[@"source"] = @"YUMI";
        [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"TipPayImageEvent" extra:params];
    }];
    globalAdpm.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:globalAdpm];
}
- (void)yumiMediationInterstitialDidClick:(YumiMediationInterstitial *)interstitial{
    NSLog(@"interstitialDidClick");
    QWReadingVC *vc = self.currentVC;
    VolumeVO *volume = [[QWReadingManager sharedInstance] currentVolumeVO];
    ChapterVO *chapter = volume.chapter[vc.currentPage.chapterIndex];
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"book"] = [volume.book.nid stringValue];
    params[@"chapter"] = [chapter.nid stringValue];
    params[@"source"] = @"YUMI";
    [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"TipPayImageClickEvent" extra:params];
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
    QWReadingVC *vc = self.currentVC;
    VolumeVO *volume = [[QWReadingManager sharedInstance] currentVolumeVO];
    ChapterVO *chapter = volume.chapter[vc.currentPage.chapterIndex];
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"book"] = [volume.book.nid stringValue];
    params[@"chapter"] = [chapter.nid stringValue];
    params[@"source"] = @"CSJ";
    [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"TipPayClickEvent" extra:params];
    
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
    QWReadingVC *vc = self.currentVC;
    VolumeVO *volume = [[QWReadingManager sharedInstance] currentVolumeVO];
    ChapterVO *chapter = volume.chapter[vc.currentPage.chapterIndex];
    
    NSMutableDictionary *adparam = [NSMutableDictionary new];
    adparam[@"token"] = [QWGlobalValue sharedInstance].token;
    adparam[@"device_id"] = [QWGlobalValue sharedInstance].deviceToken;
    adparam[@"chapter_id"] = chapter.nid;
    
    QWOperationParam *globalAdpm = [QWInterface postWithUrl:[NSString stringWithFormat:@"%@/ad/chapter_finish/",[QWOperationParam currentDomain]] params:adparam andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        
        vc.wacthAdData = aResponseObject[@"data"];
        chapter.contentVO = nil;
        chapter.completed = false;
        [vc WhetherWatchAd];
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[@"book"] = [volume.book.nid stringValue];
        params[@"chapter"] = [chapter.nid stringValue];
        params[@"source"] = @"CSJ";
        [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"TipPayEvent" extra:params];
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
