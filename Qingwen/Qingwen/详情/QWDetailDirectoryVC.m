//
//  QWDetailDirectoryVC.m
//  Qingwen
//
//  Created by Aimy on 9/29/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWDetailDirectoryVC.h"

#import "QWDetailLogic.h"
#import "QWSubscriberLogic.h"
#import "QWTableView.h"
#import "VolumeList.h"
#import "QWDetailDirectoryVolumeTVCell.h"
#import "QWDetailDirectoryChapterTVCell.h"
#import "VolumeCD.h"
#import "BookCD.h"
#import "QWFileManager.h"
#import "QWReadingManager.h"
#import "QWDownloadManager.h"
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#import "BookContinueReadingCD.h"
#import <SDImageCache.h>
#import "QWSubscriberAlertTypeTwo.h"
#import "QWJsonKit.h"
#import "YZXProgressBarView.h"
@interface QWDetailDirectoryVC () <UITableViewDelegate, UITableViewDataSource, QWDetailDirectoryVolumeTVCellDelegate>

@property (nonatomic, strong) QWDetailLogic *logic;

@property (nonatomic, strong) QWSubscriberLogic *subscriberLogic;
@property (strong, nonatomic) IBOutlet QWTableView *tableView;

@property (strong, nonatomic) UIBarButtonItem *backBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *downloadBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *allSelectedBtn;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *chooseAllBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *choosNoneBtn;

@property (strong, nonatomic) IBOutlet UIView *toolBarView;
@property (strong, nonatomic) IBOutlet UIButton *selectdBtn;
@property (strong, nonatomic) IBOutlet UIButton *subDownloadBtn;
//@property (strong, nonatomic) IBOutlet UILabel *chooseChapterCountLab;
@property (strong, nonatomic) IBOutlet UILabel *goldLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *subDownloadBtnYConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarHeight;


@property (strong, nonatomic) NSArray *indexPathsForSelectedRows;
@property (strong, nonatomic) NSMutableArray *subscriberList;
@property (strong, atomic) NSMutableArray *downloadedList;


@property (nonatomic) float needPayGold;
@property (nonatomic) float points;
@property (nonatomic) float battle;
@property (nonatomic) float needPayCoin;
@property (nonatomic) NSInteger needPayCount;
@property (nonatomic) NSInteger selectChaptersCount;
@property (nonatomic) NSInteger buy_type;
@property (nonatomic) NSInteger chapterdownedLoadCount;

//新下载界面
@property (weak, nonatomic) IBOutlet UILabel *chooseChapterCountLab;
@property (weak, nonatomic) IBOutlet UILabel *choosePriceLab;
@property (weak, nonatomic) IBOutlet UILabel *chooseBlanceLab;
@property (weak, nonatomic) IBOutlet UIButton *chooseDownLoadBtn;
@property (nonatomic, assign) float       progress;
@property int downloadOverCount;
@property int totaldownloadChapter;
@property (nonatomic, strong) YZXProgressBarView *nowProgressBarView;
@property (nonatomic,strong) UILabel *progressLab;
@end

@implementation QWDetailDirectoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.backBtn = self.navigationItem.leftBarButtonItem;
    float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
    _downloadOverCount = 0;
    _totaldownloadChapter = 0;
    if (ver >= 10 && ver < 11) {
        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    }
    //进度条
    [self createProgressBar];
    //iphoneX
    self.chooseDownLoadBtn.layer.cornerRadius = 20;
    self.chooseDownLoadBtn.layer.masksToBounds = YES;
    if(ISIPHONEX){
        if (@available(iOS 11.0, *)) {
//            self.tableView.frame = CGRectMake(0, 64+24, UISCREEN_WIDTH, UISCREEN_HEIGHT-64-24);
//            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 150+self.view.safeAreaInsets.bottom+64, 0);
//            self.tableView.contentInset = UIEdgeInsetsMake(self.view.safeAreaInsets.top, 0, 150, 0);
            [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
            [self.toolBarView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
            self.toolBarHeight.constant = self.toolBarView.height + 24;
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.view.safeAreaInsets.bottom+44, 0);

        }
//        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    WEAK_SELF;
    [self observeProperty:@"indexPathsForSelectedRows" withBlock:^(__weak id self, id old, id newVal) {
        KVO_STRONG_SELF;

        kvoSelf.subDownloadBtn.enabled = (kvoSelf.indexPathsForSelectedRows.count > 0);

        if (kvoSelf.logic.bookVO.need_pay) {
            kvoSelf.needPayCount = 0;
            kvoSelf.selectChaptersCount = 0;
            kvoSelf.needPayGold = 0;
            kvoSelf.needPayCoin = 0;
            kvoSelf.points = 0;
            kvoSelf.battle = 0;
            kvoSelf.buy_type = 0;
            
            [kvoSelf.indexPathsForSelectedRows enumerateObjectsUsingBlock:^(NSIndexPath*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.row > 0) {
                    VolumeVO *volume = kvoSelf.logic.volumeList.results[obj.section];
                    ChapterVO *chapter = volume.chapter[obj.row - 1];
                    volume.collection = kvoSelf.logic.bookVO.collection;
                    kvoSelf.buy_type = chapter.buy_type.integerValue;
                    chapter.subscriber = [kvoSelf.subscriberList containsObject:chapter.nid];
                    if (chapter.subscriber) {
                        kvoSelf.needPayGold = kvoSelf.needPayGold + 0;
                        kvoSelf.needPayCoin = kvoSelf.needPayCoin + 0;
                        kvoSelf.needPayCount = kvoSelf.needPayCount + 0;
                        kvoSelf.points = kvoSelf.points + 0;
                        kvoSelf.battle = kvoSelf.battle + 0;
                    }else {
                        kvoSelf.needPayGold = kvoSelf.needPayGold + chapter.amount.floatValue;
                        kvoSelf.needPayCoin = kvoSelf.needPayCoin + chapter.amount_coin.floatValue;
                        if(chapter.points){
                            kvoSelf.points = kvoSelf.points + chapter.points.floatValue;
                        }else{
                            kvoSelf.points = kvoSelf.points + chapter.amount.floatValue * 5;
                        }
                        if(chapter.battle){
                            kvoSelf.battle = kvoSelf.battle + chapter.battle.floatValue;
                        }else{
                            kvoSelf.battle = kvoSelf.battle + chapter.amount_coin.floatValue * 0.5;
                        }
                        
                        if (chapter.amount.floatValue > 0) {
                            kvoSelf.needPayCount ++;
                        }
                    }
                    kvoSelf.selectChaptersCount ++;
                }
            }];
            UserVO *author = kvoSelf.logic.bookVO.author.firstObject;
            if (author.nid == [QWGlobalValue sharedInstance].user.nid) {
//                kvoSelf.chooseChapterCountLab.text = [NSString stringWithFormat:@"需购章节%ld章, 需付金额0重石",(long)kvoSelf.selectChaptersCount];
                kvoSelf.chooseChapterCountLab.text = [NSString stringWithFormat:@"已选%d章，需付费%ld章",(int)kvoSelf.selectChaptersCount,(long)kvoSelf.needPayCount];
            }else {
                kvoSelf.chooseChapterCountLab.text = [NSString stringWithFormat:@"已选%d章，需付费%ld章",(int)kvoSelf.selectChaptersCount,(long)kvoSelf.needPayCount];
                kvoSelf.choosePriceLab.text = [NSString stringWithFormat:@"价格：%ld重石  %ld轻石",(long)kvoSelf.needPayGold,(long)kvoSelf.needPayCoin];
            }
        }
//        NSLog(@"indexPathsForSelectedRows.count :%ld volumeList.count: %ld;bookVO.chapter_count: %ld;",
//              kvoSelf.indexPathsForSelectedRows.count,
//              kvoSelf.logic.volumeList.count.integerValue,
//              kvoSelf.logic.bookVO.chapter_count.integerValue
//              );
        if (kvoSelf.indexPathsForSelectedRows.count > 0 && (kvoSelf.indexPathsForSelectedRows.count + kvoSelf.downloadedList.count) == (kvoSelf.logic.volumeList.count.integerValue + kvoSelf.logic.bookVO.chapter_count.integerValue)) {
            [kvoSelf.selectdBtn setTitle:@"全不选" forState:UIControlStateNormal];
        }
        else {
            [kvoSelf.selectdBtn setTitle:@"全选" forState:UIControlStateNormal];

        }
    }];
    

    self.logic.bookVO = self.bookVO;
    self.logic.volumeList = self.volumeList;
    
    if (self.logic.bookVO && self.logic.volumeList == nil) {
        [self getData];
    }
    if ([self.InId isEqualToString:@"1"]) {
         [self openDownLoad];
    }
    else{
      
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(downloadProgressChange) name:@"downloadOver" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;

    if (self.logic.volumeList) {
        self.navigationItem.rightBarButtonItem = self.editBtn;
    }
    if (self.logic.bookVO) {
        [self getSubscriberList];
    }
    if (self.logic.canRead == NO) {
        self.tableView.hidden = YES;
        
    }
    else{
        
    }
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    
}

//条形进度条
- (void)createProgressBar
{
    [_nowProgressBarView removeFromSuperview];
    _chooseDownLoadBtn.hidden = NO;
    _progress = 0;
    _nowProgressBarView = [[YZXProgressBarView alloc] initWithFrame:CGRectMake(13, 98, UISCREEN_WIDTH-26, 40) type:progressBar];
    _nowProgressBarView.layer.cornerRadius = 20;
    _nowProgressBarView.layer.masksToBounds = YES;
    _nowProgressBarView.progressBarBGC = HRGB(0xFF9AA7);
    _nowProgressBarView.fillColor = HRGB(0xFF7889);
//    _nowProgressBarView.progressBarBGC = [UIColor redColor];
//    _nowProgressBarView.fillColor = [UIColor blueColor];
    _nowProgressBarView.loadingProgress = _progress;
    _nowProgressBarView.hidden = YES;
    [self.toolBarView addSubview:_nowProgressBarView];
//    _progressLab.text = @"下载中0%...";
    self.progressLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_WIDTH-26, 40)];
    _progressLab.textColor = [UIColor whiteColor];
    _progressLab.textAlignment = 1;
    _progressLab.font = [UIFont systemFontOfSize:16];
//    _progressLab.hidden = YES;
    _progressLab.text = @"下载中0%...";
    [self.nowProgressBarView addSubview:_progressLab];
}

-(void)downloadProgressChange{
    _downloadOverCount ++;
//    int totaldownloadChapter = (int)self.selectChaptersCount;
    NSString * objA = [NSString stringWithFormat:@"%.2f", (double)_downloadOverCount];
    NSString * objB = [NSString stringWithFormat:@"%.2f", (double)self.selectChaptersCount];
    NSString *objC = [NSString stringWithFormat:@"%.2f",[objA floatValue]/[objB floatValue]];
    NSLog(@"objC = %@",objC);
    _progress = [objC floatValue];
    if (_downloadOverCount == self.selectChaptersCount) {
        [self finishDownLoad];
    }
    else{
        [self downloading];
    }
}
-(void)finishDownLoad{
    dispatch_async(dispatch_get_main_queue(), ^{
        //inset code....
        self->_nowProgressBarView.loadingProgress = self->_progress;
        [self showToastWithTitle:@"下载成功" subtitle:nil type:ToastTypeError];
        [self createProgressBar];
        [self onPressedCancelBtn:nil];
    });
    
}
-(void)downloading{
    dispatch_async(dispatch_get_main_queue(), ^{
        //inset code....
        self->_nowProgressBarView.loadingProgress = self->_progress;
        NSString *baifenhao = @"%";
        NSString * objA = [NSString stringWithFormat:@"%.2f", (double)100];
        NSString * objB = [NSString stringWithFormat:@"%.2f", (double)self->_progress];
        NSString *objC = [NSString stringWithFormat:@"%.2f",[objA floatValue]*[objB floatValue]];
        self->_progressLab.text = [NSString stringWithFormat:@"下载中%@%@",objC,baifenhao];
    });
//
}
-(void)openDownLoad{
    self.downloadBtn.enabled = NO;
    self.navigationItem.leftBarButtonItem = self.cancelBtn;
    self.navigationItem.rightBarButtonItem = self.downloadBtn;
    [self.tableView setEditing:YES animated:YES];
    
    //    [self.navigationController setToolbarHidden:NO animated:YES];
    
    if (self.logic.bookVO.need_pay.boolValue) {
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            self.toolBarView.hidden = false;
            if (@available(iOS 10.0, *)) {
                self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 150, 0);
            }
            if(ISIPHONEX){
                if (@available(iOS 11.0, *)) {
                    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 150+self.view.safeAreaInsets.bottom+64, 0);
                } else {
                    // Fallback on earlier versions
                    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 150, 0);
                    
                    self.tableView.frame = CGRectMake(0, 64, UISCREEN_WIDTH, UISCREEN_HEIGHT-64-150);
                }
            }else{
                self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 150, 0);
                self.tableView.frame = CGRectMake(0, 64, UISCREEN_WIDTH, UISCREEN_HEIGHT-64-150);
            }
            
            self.chooseBlanceLab.text = [NSString stringWithFormat:@"重石余额: %@",[QWGlobalValue sharedInstance].user.gold];
        } completion:nil];
    } else {
        [self.subDownloadBtn setTitle:@"下载" forState:UIControlStateNormal];
        [UIView animateWithDuration:0.5 delay:0.0 options:
         UIViewAnimationOptionTransitionFlipFromBottom animations:^{
             self.subDownloadBtnYConstraint.constant = 16;
             self.toolBarView.hidden = false;
             if (@available(iOS 10.0, *)) {
                 self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 150, 0);
             }
             if(ISIPHONEX){
                 if (@available(iOS 11.0, *)) {
                     self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 150+self.view.safeAreaInsets.bottom+64, 0);
                     //                     self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 150, 0);
                 } else {
                     // Fallback on earlier versions
                     self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 150, 0);
                     
                     self.tableView.frame = CGRectMake(0, 64, UISCREEN_WIDTH, UISCREEN_HEIGHT-64-150);
                     
                 }
             }else{
                 self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 150, 0);
                 self.tableView.frame = CGRectMake(0, 64, UISCREEN_WIDTH, UISCREEN_HEIGHT-64-150);
                 
             }
             
//             self.chooseChapterCountLab.hidden = true;
             self.chooseChapterCountLab.text = [NSString stringWithFormat:@"已选%d章，需付费%ld章",(int)self.selectChaptersCount,(long)self.needPayCount];
             self.chooseBlanceLab.text = [NSString stringWithFormat:@"重石余额: %@",([QWGlobalValue sharedInstance].user.gold == nil ? @0:[QWGlobalValue sharedInstance].user.gold)];
         } completion:^(BOOL finished) {
             
         }];
    }
    
    [self.logic.volumeList.results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        VolumeVO *volume = obj;
        volume.isFlod = false;
    }];
    
    [self.tableView reloadData];
    self.fd_interactivePopDisabled = YES;
}
- (QWDetailLogic *)logic
{
    if (!_logic) {
        _logic = [QWDetailLogic logicWithOperationManager:self.operationManager];
    }

    return _logic;
}

- (QWSubscriberLogic *)subscriberLogic {
    if ((!_subscriberLogic)) {
        _subscriberLogic = [QWSubscriberLogic logicWithOperationManager:self.operationManager];
    }
    return _subscriberLogic;
}
- (void)getData
{
    WEAK_SELF;
    NSString *newUrl = [NSString stringWithFormat:@"%@?quick=true",self.logic.bookVO.chapter_url];
    
    [self.logic getDirectoryWithUrl:newUrl andCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        if (!anError) {
            self.tableView.emptyView.showError = YES;
            self.navigationItem.rightBarButtonItem = self.editBtn;
            [self foldVolume];
            [self configReadingHistory];
        }
        [self.tableView reloadData];
    }];
}


- (void)getSubscriberList{
    _subscriberList = [NSMutableArray array];
    WEAK_SELF;
    if ([QWGlobalValue sharedInstance].isLogin) {
        self.subscriberList = @[].mutableCopy;
        [self.subscriberLogic getSubscriberChaptersWithBookId:self.logic.bookVO.nid andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            STRONG_SELF;
            [self.subscriberLogic.subscriberList.results enumerateObjectsUsingBlock:^(SubscriberVO*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.subscriberList addObject:obj.chapter];
            }];
            [self.tableView reloadData];
        }];
    }
}

- (void)foldVolume {
    //1.无阅读记录，第一卷和最后一卷展开。
    //2.有阅读记录，有阅读记录的一卷和最后一卷。
//    VolumeCD *volumeCD = [VolumeCD findLastReadingVolumeWithBookId:self.logic.bookVO.nid];
//    if (volumeCD) {
//        WEAK_SELF;
//        [self.logic.volumeList.results enumerateObjectsUsingBlock:^(VolumeVO * obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            STRONG_SELF;
//            if ([volumeCD.nid isEqualToNumber:obj.nid] || self.logic.volumeList.results.count - 1 == idx) {
//                obj.isFlod = false;
//            }
//            else {
//                obj.isFlod = true;
//
//            }
//        }];
//    }
//    else {
        WEAK_SELF;
        [self.logic.volumeList.results enumerateObjectsUsingBlock:^(VolumeVO * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            STRONG_SELF;
            if (idx == 0) {
                obj.isFlod = false;
            }
            else {
                obj.isFlod = true;
            }
        }];
    //}
}

- (void)configReadingHistory
{
    BookContinueReadingCD *readingCD = [BookContinueReadingCD MR_findFirstByAttribute:@"bookId" withValue:self.bookVO.nid inContext:[QWFileManager qwContext]];
    if (readingCD) {
        VolumeVO *volumeVO = self.logic.volumeList.results[readingCD.volumeIndex.integerValue];
        VolumeCD *volumeCD = [VolumeCD MR_findFirstByAttribute:@"nid" withValue:volumeVO.nid inContext:[QWFileManager qwContext]];
        if (!volumeCD) {
            volumeCD = [VolumeCD MR_createEntityInContext:[QWFileManager qwContext]];
            [volumeCD updateWithVolumeVO:volumeVO bookId:self.bookVO.nid];
        }

        volumeCD.chapterIndex = readingCD.chapterIndex;
        volumeCD.location = readingCD.location;
        [volumeCD setReading];

        [readingCD MR_deleteEntityInContext:[QWFileManager qwContext]];
        [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];
    }
}

- (void)configDownloadedCount {
    [self.logic.volumeList.results enumerateObjectsUsingBlock:^(VolumeVO*  _Nonnull volume, NSUInteger idx, BOOL * _Nonnull stop) {
        [volume.chapter enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [volume.chapter enumerateObjectsUsingBlock:^(ChapterVO*  _Nonnull chapter, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([QWFileManager isChapterExitWithBookId:self.logic.bookVO.nid.stringValue volumeId:volume.nid.stringValue chapterId:chapter.nid.stringValue]) {
                    self.chapterdownedLoadCount ++;
                }
            }];
        }];
    }];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.navigationController setToolbarHidden:YES];
}

- (IBAction)onPressedEditBtn:(id)sender {
    [self editAction:sender];
    [self createProgressBar];
}

-(void)editAction:(id)sender{
    self.downloadBtn.enabled = NO;
    self.navigationItem.leftBarButtonItem = self.cancelBtn;
    self.navigationItem.rightBarButtonItem = self.choosNoneBtn;
//    [self.downloadBtn setTitle:@"全不选"];
    [self.tableView setEditing:YES animated:YES];
    
    //    [self.navigationController setToolbarHidden:NO animated:YES];
    
    if (self.logic.bookVO.need_pay.boolValue) {
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            self.toolBarView.hidden = false;
            if (@available(iOS 10.0, *)) {
                self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 150, 0);
            }
            if(ISIPHONEX){
                if (@available(iOS 11.0, *)) {
                    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 150+self.view.safeAreaInsets.bottom+64, 0);
                } else {
                    // Fallback on earlier versions
                    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 150, 0);
                    
                    self.tableView.frame = CGRectMake(0, 64, UISCREEN_WIDTH, UISCREEN_HEIGHT-64-150);
                }
            }else{
                self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 150, 0);
                self.tableView.frame = CGRectMake(0, 64, UISCREEN_WIDTH, UISCREEN_HEIGHT-64-150);
            }
            
            self.chooseBlanceLab.text = [NSString stringWithFormat:@"重石余额: %@",[QWGlobalValue sharedInstance].user.gold];
        } completion:nil];
    } else {
        [self.subDownloadBtn setTitle:@"下载" forState:UIControlStateNormal];
        [UIView animateWithDuration:0.5 delay:0.0 options:
         UIViewAnimationOptionTransitionFlipFromBottom animations:^{
             self.subDownloadBtnYConstraint.constant = 16;
             self.toolBarView.hidden = false;
             if (@available(iOS 10.0, *)) {
                 self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 150, 0);
             }
             if(ISIPHONEX){
                 if (@available(iOS 11.0, *)) {
                     self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 150+self.view.safeAreaInsets.bottom+64, 0);
                     //                     self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 150, 0);
                 } else {
                     // Fallback on earlier versions
                     self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 150, 0);
                     
                     self.tableView.frame = CGRectMake(0, 64, UISCREEN_WIDTH, UISCREEN_HEIGHT-64-150);
                     
                 }
             }else{
                 self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 150, 0);
                 self.tableView.frame = CGRectMake(0, 64, UISCREEN_WIDTH, UISCREEN_HEIGHT-64-150);
                 
             }
             
//             self.chooseChapterCountLab.hidden = true;
             self.chooseChapterCountLab.text = [NSString stringWithFormat:@"已选%d章，需付费%ld章",(int)self.selectChaptersCount,(long)self.needPayCount];
             self.chooseBlanceLab.text = [NSString stringWithFormat:@"重石余额: %@",([QWGlobalValue sharedInstance].user.gold == nil ? @0:[QWGlobalValue sharedInstance].user.gold)];
         } completion:^(BOOL finished) {
             
         }];
    }
    
    [self.logic.volumeList.results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        VolumeVO *volume = obj;
        volume.isFlod = true;
    }];
    
    [self.tableView reloadData];
    self.fd_interactivePopDisabled = YES;
    
    [self onPressedSelectedAllBtn:sender];
}
- (IBAction)onPressedCancelBtn:(id)sender {
    self.navigationItem.leftBarButtonItem = self.backBtn;
    self.navigationItem.rightBarButtonItem = self.editBtn;
    [self.tableView setEditing:NO animated:YES];

//    [self.navigationController setToolbarHidden:YES animated:YES];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        self.toolBarView.hidden = true;
        if (@available(iOS 10.0, *)) {
            self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 150, 0);
        }
        if (@available(iOS 11.0, *)){
            if(ISIPHONEX){
                
                self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.view.safeAreaInsets.bottom+44, 0);
            }
            else{
                self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 150, 0);
                self.tableView.frame = CGRectMake(0, 64, UISCREEN_WIDTH, UISCREEN_HEIGHT-64);

            }
        }
        else{
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 150, 0);
            self.tableView.frame = CGRectMake(0, 64, UISCREEN_WIDTH, UISCREEN_HEIGHT-64);

        }
        
    } completion:nil];
    
    self.fd_interactivePopDisabled = NO;
    self.indexPathsForSelectedRows = nil;
    if (![self.progressLab.text isEqualToString:@"下载中0%..."]) {
        [self showToastWithTitle:@"点击取消将后台下载" subtitle:nil type:ToastTypeError];
    }
    
}

- (IBAction)onPressedChooseAllBtn:(id)sender {
    self.navigationItem.rightBarButtonItem = self.choosNoneBtn;
    self.downloadedList = [QWFileManager GetAllBookFilesPath:self.logic.bookVO.nid.stringValue];
    if ((self.indexPathsForSelectedRows.count > 0 && self.indexPathsForSelectedRows.count == self.logic.volumeList.count.integerValue )|| ([self.selectdBtn.titleLabel.text isEqualToString:@"全选"])) {
        for (int i = 0 ; i < self.logic.volumeList.count.integerValue; i++) {
            [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i] animated:false];
            self.indexPathsForSelectedRows = nil;
            
            [self onPressedSelectedCurrentSection:[NSIndexPath indexPathForRow:0 inSection:i]];
            
        }
    }
    else {
        for (int i = 0 ; i < self.logic.volumeList.count.integerValue; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
            [self onPressedSelectedCurrentSection:indexPath];
        }
    }
    
}
- (IBAction)onPressedChooseNoneBtn:(id)sender {
    self.navigationItem.rightBarButtonItem = self.chooseAllBtn;
    self.downloadedList = [QWFileManager GetAllBookFilesPath:self.logic.bookVO.nid.stringValue];
    if ((self.indexPathsForSelectedRows.count > 0 && self.indexPathsForSelectedRows.count == self.logic.volumeList.count.integerValue )|| ([self.selectdBtn.titleLabel.text isEqualToString:@"全选"])) {
        for (int i = 0 ; i < self.logic.volumeList.count.integerValue; i++) {
            [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i] animated:false];
            self.indexPathsForSelectedRows = nil;
            
            [self onPressedSelectedCurrentSection:[NSIndexPath indexPathForRow:0 inSection:i]];
            
        }
    }
    else {
        for (int i = 0 ; i < self.logic.volumeList.count.integerValue; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
            [self onPressedSelectedCurrentSection:indexPath];
        }
    }
    
}

- (IBAction)onPressedChargeBtn:(id)sender {
    QWCharge *charge = [[QWCharge alloc]init];
    [charge doCharge];
}

- (IBAction)onPressedDownloadBtn:(id)sender
{
    
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self onPressedCancelBtn:sender];
        self.indexPathsForSelectedRows = nil;
        return;
    }
    UserVO *author = self.logic.bookVO.author.firstObject;
    BOOL isMine = (author.nid == [QWGlobalValue sharedInstance].nid ? YES : false);
    WEAK_SELF;
    if (self.logic.bookVO.need_pay.integerValue == 1 && !isMine && (self.needPayGold > 0 || self.needPayCoin > 0)) {// 下载前判断是否需要订阅
        NSMutableArray *chapterIdArray = @[].mutableCopy;
        [self.indexPathsForSelectedRows enumerateObjectsUsingBlock:^(NSIndexPath*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            STRONG_SELF;
            if (obj.row > 0) {
                VolumeVO *volume = self.logic.volumeList.results[obj.section];
                ChapterVO *chapter = volume.chapter[obj.row - 1];
                [chapterIdArray addObject:chapter.nid];
            }
        }];
        
        if (self.buy_type == 1) {
            NSLog(@"buytype1234 = %ld",(long)self.buy_type);
            NSMutableDictionary *params = @{}.mutableCopy;
            params[@"token"] = [QWGlobalValue sharedInstance].token;
            params[@"chapter_id_list"] = chapterIdArray;
            NSMutableDictionary *content = @{}.mutableCopy;
            content[@"data"] = [QWJsonKit stringFromDict:params];
            QWOperationParam *param = [QWInterface getWithDomainUrl:[NSString stringWithFormat:@"subscriber/chapter_multi_amount/"] params:content andCompleteBlock:^(id aResponseObject, NSError *anError) {
                if (aResponseObject && !anError) {
                    NSDictionary *dict = aResponseObject;
                    SubscriberVO *vo = [SubscriberVO new];
                    vo.chapter_count = @(self.needPayCount);
                    vo.amount = dict[@"volume_need_amount"];
                    vo.amount_coin = dict[@"volume_amount_coin"];
                    vo.book_id = self.logic.bookVO.nid;
                    vo.points = dict[@"volume_points"];
                    vo.battle = dict[@"volume_battle"];
                    vo.buy_type = @"1";
                    vo.volume_num = dict[@"volume_num"];
                    QWSubscriberAlertTypeOne *alert = [QWSubscriberAlertTypeOne alertViewWithButtonAction:^(QWSubscriberActionType type) {
                        STRONG_SELF;
                        if (type == QWSubscriberActionTypeBuy) {
                            [self getSubscriberList];
                            [self doDownload];
                        }
                    }];
                    [alert updateAlertWithChapterIdList:chapterIdArray subscriberVO:vo];
                    [alert show];
                    
                }
                else {
                    
                }
            }];
            param.requestType = QWRequestTypePost;
            param.paramsUseData = YES;
            [self.operationManager requestWithParam:param];
        }
        else{
        SubscriberVO *vo = [SubscriberVO new];
        vo.chapter_count = @(self.needPayCount);
        vo.amount = @(self.needPayGold);
        vo.amount_coin = @(self.needPayCoin);
        vo.book_id = self.logic.bookVO.nid;
        vo.points = @(self.points);
        vo.battle = @(self.battle);
        QWSubscriberAlertTypeOne *alert = [QWSubscriberAlertTypeOne alertViewWithButtonAction:^(QWSubscriberActionType type) {
            STRONG_SELF;
            if (type == QWSubscriberActionTypeBuy) {
                [self getSubscriberList];
                [self doDownload];
            }
        }];
        [alert updateAlertWithChapterIdList:chapterIdArray subscriberVO:vo];
        [alert show];
        }
    }else {
        [self doDownload];
    }
}

- (void)doDownload {
    WEAK_SELF;
//    self.progressLab.hidden = NO;
    self.nowProgressBarView.hidden = NO;
    self.chooseDownLoadBtn.hidden = YES;
    _downloadOverCount = 0;
    
    _progress = 0;
    for (int i = 0; i < self.logic.volumeList.results.count; i++) {
        
        VolumeVO *volume = [VolumeVO new];
        VolumeVO *currentVolume = self.logic.volumeList.results[i];
        NSMutableArray *chapterArray = [NSMutableArray array];
        [self.indexPathsForSelectedRows.copy enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            STRONG_SELF;
            NSIndexPath *indexpath = obj;
            if (indexpath.section == i && indexpath.row > 0) {
                [chapterArray addObject:currentVolume.chapter[indexpath.row - 1]];
            }
        }];
        
        {
            volume.nid = currentVolume.nid;
            volume.title = currentVolume.title;
            volume.book = currentVolume.book;
            volume.updated_time = currentVolume.updated_time;
            volume.download_url = currentVolume.download_url;
            volume.url = currentVolume.url;
            volume.order = currentVolume.order;
            volume.chapter_url = currentVolume.chapter_url;
            volume.count = currentVolume.count;
            volume.intro = currentVolume.intro;
            volume.status = currentVolume.status;
            volume.type = currentVolume.type;
            volume.views = currentVolume.views;
            volume.end = currentVolume.end;
        }
        if (chapterArray.count > 0) {
            volume.chapter = chapterArray.copy;
            [self downloadWithChapters:chapterArray book:self.logic.bookVO volume:volume];
        }
    }
    
//    [self onPressedCancelBtn:nil];
    [self.tableView reloadData];

}

- (void)downloadWithChapters:(NSArray *)chapters book:(BookVO *)book volume:(VolumeVO *)volume {
   
    BookCD *bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == NO", book.nid] inContext:[QWFileManager qwContext]];
    if (!bookCD) {
        bookCD = [BookCD MR_createEntityInContext:[QWFileManager qwContext]];
    }
    
    [bookCD updateWithBookVO:book];
    
    VolumeCD *volumeCD = [VolumeCD MR_findFirstByAttribute:@"nid" withValue:volume.nid inContext:[QWFileManager qwContext]];
    if (!volumeCD) {
        volumeCD = [VolumeCD MR_createEntityInContext:[QWFileManager qwContext]];
        [volumeCD updateWithVolumeVO:volume bookId:bookCD.nid];
    }
    
    [volumeCD setDownloading];
    [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];//写入

    [[QWDownloadManager sharedInstance] downloadWithChapters:chapters volume:volume book:book];
    
}

- (IBAction)onPressedSelectedAllBtn:(id)sender {

        self.downloadedList = [QWFileManager GetAllBookFilesPath:self.logic.bookVO.nid.stringValue];
        if ((self.indexPathsForSelectedRows.count > 0 && self.indexPathsForSelectedRows.count == self.logic.volumeList.count.integerValue )|| ([self.selectdBtn.titleLabel.text isEqualToString:@"全选"])) {
            for (int i = 0 ; i < self.logic.volumeList.count.integerValue; i++) {
                [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i] animated:false];
                self.indexPathsForSelectedRows = nil;
                
                [self onPressedSelectedCurrentSection:[NSIndexPath indexPathForRow:0 inSection:i]];
                
            }
        }
        else {
            for (int i = 0 ; i < self.logic.volumeList.count.integerValue; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
                [self onPressedSelectedCurrentSection:indexPath];
            }
        }
}

- (void)onPressedSelectedCurrentSection:(NSIndexPath *)indexPath {//选择整个section
    
    NSMutableArray *currentSectionSelectdArray = [NSMutableArray array];
    [self.tableView.indexPathsForSelectedRows enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath *index = obj;
        if (index.section == indexPath.section) {
            [currentSectionSelectdArray addObject:index];
        }
    }];
    
    VolumeVO *volume = self.logic.volumeList.results[indexPath.section];
    if ([self.indexPathsForSelectedRows containsObject:indexPath] && currentSectionSelectdArray.count == volume.chapter.count + 1) {
        for (int i = 0; i < volume.chapter.count + 1; i++) {
            [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section] animated:false];
        }
    } else {
        //选择第一个
         [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section] animated:false scrollPosition:UITableViewScrollPositionNone];
        
        for (int i = 1; i < volume.chapter.count + 1 ; i++) {
            NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
            ChapterVO *chapter = volume.chapter[index.row - 1];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@", chapter.nid.stringValue];
            NSArray *results = [self.downloadedList filteredArrayUsingPredicate:predicate];
            if ([[QWDownloadManager sharedInstance] isDownloadingWithBookId:self.logic.bookVO.nid.stringValue volumeId:volume.nid.stringValue]) {
                continue;
            }
            else if (results.count > 0) {
                continue;
            }else {
                //判断这个section有下载的章节
                if ([self isDownloadedSomeChaptersWithVolume:volume]) {
                    if ([self.indexPathsForSelectedRows containsObject:index]) {
                        [self.tableView deselectRowAtIndexPath:index animated:false];
                    }else {
                        [self.tableView selectRowAtIndexPath:index animated:false scrollPosition:UITableViewScrollPositionNone];
                    }
                }else {
                    [self.tableView selectRowAtIndexPath:index animated:false scrollPosition:UITableViewScrollPositionNone];
                }

            }
        }
    }
    self.indexPathsForSelectedRows = self.tableView.indexPathsForSelectedRows;
}

- (BOOL)isDownloadedSomeChaptersWithVolume:(VolumeVO *)volume {
    
    __block BOOL exit = false;

    [volume.chapter enumerateObjectsUsingBlock:^(ChapterVO*  _Nonnull chapter, NSUInteger idx, BOOL * _Nonnull stop) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@", chapter.nid.stringValue];
        NSArray *results = [self.downloadedList filteredArrayUsingPredicate:predicate];
        if(results.count != 0){
            exit = true;
            *stop = YES;
        }
    }];
    return  exit;
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.logic.volumeList.count.integerValue;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    VolumeVO *volume = self.logic.volumeList.results[section];
    if (volume.isFlod && self.tableView.isEditing == false) {
        return 1;
    }
    else if(volume.isFlod && self.tableView.isEditing == true){
        return 1;
    }
    else{
        
        return volume.chapter.count + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        QWDetailDirectoryVolumeTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"volume" forIndexPath:indexPath];
        cell.delegate = self;
        VolumeVO *volume = self.logic.volumeList.results[indexPath.section];
        [cell updateWithBookVO:self.logic.bookVO volume:volume];
        return cell;
    }
    else {
        
        QWDetailDirectoryChapterTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        VolumeVO *volume = self.logic.volumeList.results[indexPath.section];
        ChapterVO *chapter = volume.chapter[indexPath.row - 1];
        chapter.collection = self.logic.bookVO.collection;
        chapter.subscriber = [_subscriberList containsObject:chapter.nid];
        
        VolumeCD *volumeCD = [VolumeCD findLastReadingVolumeWithBookId:self.logic.bookVO.nid];
        [cell updateBookVO:self.logic.bookVO volumeId:volume.nid.stringValue];
        if ([volumeCD.nid isEqualToNumber:volume.nid] && volumeCD.chapterIndex.integerValue == indexPath.row - 1) {
            [cell updateChapterVO:chapter isContinueReading:true];
        }
        else {
            [cell updateChapterVO:chapter isContinueReading:false];
        }

        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.isEditing) {
        
        if (indexPath.row == 0) {
            [self onPressedSelectedCurrentSection:indexPath];
        }
        else {
            VolumeVO *volume = self.logic.volumeList.results[indexPath.section];
            ChapterVO *chapter = volume.chapter[indexPath.row - 1];
            chapter.collection = self.logic.bookVO.collection;
            if ([QWFileManager isChapterExitWithBookId:self.logic.bookVO.nid.stringValue volumeId:volume.nid.stringValue chapterId:chapter.nid.stringValue]) {
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
            }
            
            else if ([self.indexPathsForSelectedRows containsObject:indexPath] && [self.tableView.indexPathsForSelectedRows containsObject:indexPath]){
                [tableView deselectRowAtIndexPath:indexPath animated:false];
                self.indexPathsForSelectedRows = self.tableView.indexPathsForSelectedRows;
            } else  {
                self.indexPathsForSelectedRows = self.tableView.indexPathsForSelectedRows;
            }
        }
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        if (indexPath.row == 0) {
            //没有卷界面
            VolumeVO *volume = self.logic.volumeList.results[indexPath.section];
            volume.isFlod = !volume.isFlod;
            volume.collection = self.logic.bookVO.collection;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
            return ;
        }
        else {
            [self gotoReadingWithBook:self.logic.bookVO volumes:self.logic.volumeList indexPath:indexPath];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.isEditing) {
        
        [self.tableView selectRowAtIndexPath:indexPath animated:false scrollPosition:UITableViewScrollPositionNone];
        [self onPressedSelectedCurrentSection:indexPath];

    }
}

- (void)gotoReadingWithBook:(BookVO *)book volumes:(VolumeList *)volumes indexPath:(NSIndexPath *)indexPath
{
    VolumeVO *volume = volumes.results[indexPath.section];
    volume.collection = book.collection;
    //设置阅读进度
    {
        BookCD *bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == NO", book.nid] inContext:[QWFileManager qwContext]];
        if (!bookCD) {//如果没有阅读过，则创建一个
            bookCD = [BookCD MR_createEntityInContext:[QWFileManager qwContext]];
            [bookCD updateWithBookVO:book];
        }

        VolumeCD *volumeCD = [VolumeCD MR_findFirstByAttribute:@"nid" withValue:volume.nid inContext:[QWFileManager qwContext]];
        if (!volumeCD) {
            volumeCD = [VolumeCD MR_createEntityInContext:[QWFileManager qwContext]];
            [volumeCD updateWithVolumeVO:volume bookId:book.nid];
            volumeCD.chapterIndex = @0;
            volumeCD.location = @0;
        }

        if (indexPath && volumeCD.chapterIndex && volumeCD.chapterIndex.integerValue != indexPath.row - 1) {//如果读的不是这个章节，则写成这个章节
            volumeCD.chapterIndex = @(indexPath.row - 1);
            volumeCD.location = @0;
        }

        [volumeCD setReading];

        [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];
    }

    //开始阅读
    [[QWReadingManager sharedInstance] startOnlineReadingWithBookId:book.nid volumes:volumes];

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"QWReading" bundle:nil];
    UIViewController *vc = [sb instantiateInitialViewController];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark QWDetailDirectoryVolumeTVCellDelegate 

- (void)volumeCell:(QWDetailDirectoryVolumeTVCell *)cell didClickedFoldBtn:(UIButton *)sender{
    if (self.tableView.isEditing == YES) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        VolumeVO *volume = self.logic.volumeList.results[indexPath.section];
        volume.isFlod = !volume.isFlod;
//        [self.tableView reloadData];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
        [self onPressedChooseAllBtn:sender];
    }
    else{
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        VolumeVO *volume = self.logic.volumeList.results[indexPath.section];
        volume.isFlod = sender.isSelected;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    }
    
}

@end
