//
//  QWReadingVC.m
//  Qingwen
//
//  Created by Aimy on 7/2/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWReadingVC.h"

#import "NSObject+QW.h"

#import "QWReadingBottomStatusView.h"

#import <PureLayout/PureLayout.h>

#import "QWCoreTextHelper.h"

#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>

#import "VolumeVO.h"
#import "BookCD.h"
#import "QWReadingConfig.h"
#import "QWFileManager.h"
#import "QWEmptyView.h"
#import "QWInterface.h"
#import "QWReadingManager.h"
#import "QWSubscriberAlertTypeTwo.h"
#import "QWSubscriberLogic.h"
#import "SubscriberList.h"

#import <YumiMediationSDK/YumiMediationVideo.h>

#import "QWGDTReadNativeAdView.h"
@interface QWReadingVC () <QWChapterViewDelegate,YumiMediationVideoDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *backgroundView;
@property (strong, nonatomic) IBOutlet UIImageView *contentImage;
@property (strong, nonatomic) QWReadingBottomStatusView *bottomStatusView;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (strong, nonatomic) IBOutlet QWEmptyView *emptyView;
@property (strong, nonatomic) QWChapterView *chapterView;

@property (nonatomic, strong) QWSubscriberLogic *subscriberLogic;
@property (nonatomic, strong) QWMyCenterLogic *userLogic;
@property int autodingyue ;//1打开0关闭

@property (nonatomic, strong) NSMutableDictionary *QWAdDict;//广告配置

@property (nonatomic ,strong)QWGDTReadNativeAdView *GDTAdView;

@end

@implementation QWReadingVC

- (QWSubscriberLogic *)subscriberLogic {
    if (!_subscriberLogic) {
        _subscriberLogic = [QWSubscriberLogic logicWithOperationManager:self.operationManager];
    }
    
    return _subscriberLogic;
}

- (QWMyCenterLogic *)userLogic
{
    if (!_userLogic) {
        _userLogic = [QWMyCenterLogic logicWithOperationManager:self.operationManager];
    }
    
    return _userLogic;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    
    self.emptyView.configFrameManual = YES;
    self.fd_prefersNavigationBarHidden = YES;
    
    UINib *nib = [UINib nibWithNibName:@"QWReadingBottomStatusView" bundle:nil];
    self.bottomStatusView = [[nib instantiateWithOwner:nil options:nil] firstObject];
    [self.view addSubview:self.bottomStatusView];
    
    [self.bottomStatusView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
    [self.bottomStatusView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view];
    [self.bottomStatusView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view];
    [self.bottomStatusView autoSetDimension:ALDimensionHeight toSize:43];
    
    UINib *nib1 = [UINib nibWithNibName:@"QWReadingTopNameView" bundle:nil];
    self.topNameView = [[nib1 instantiateWithOwner:nil options:nil] firstObject];
    [self.view addSubview:self.topNameView];
    [self.topNameView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
    [self.topNameView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view];
    if (@available(iOS 9, *)) {
        [self.topNameView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor].active = true;
    }else{
        [self.topNameView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view];
    }
    [self.topNameView autoSetDimension:ALDimensionHeight toSize:50];
    
    
    if ([QWReadingConfig sharedInstance].readingBG == QWReadingBGDefault) {
        self.activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }
    else {
        self.activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    }
    
   
    //刷新
    self.isSubscribe = YES;
    [self WhetherWatchAd];
    
    
    //修改了设置
    WEAK_SELF;
    [self observeNotification:QWREADING_CHANGED withBlock:^(__weak id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }
        
        KVO_STRONG_SELF;
        if ([QWReadingConfig sharedInstance].readingBG == QWReadingBGDefault) {
            kvoSelf.activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        }
        else {
            kvoSelf.activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        }
        
        kvoSelf.emptyView.useDark = [QWReadingConfig sharedInstance].readingBG == QWReadingBGBlack;
        
        [kvoSelf WhetherWatchAd];
    }];
    
    NSNumber *bookId = [QWReadingManager sharedInstance].bookCD.nid;
    [self.subscriberLogic getPurchaseListWithBookId:bookId andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (aResponseObject && !anError) {
            SubscriberList *listVO = [SubscriberList voWithDict:aResponseObject];
            SubscriberVO *result = listVO.results.firstObject;
            if ([result.toggle boolValue]) {
                
                self.subscriberLogic.autoPurechase = @1;
                [self freshNextContent];
            }
        }
    }];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dakaiDingyue) name:@"dakaiDingyue" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cancelDingyue) name:@"cancelDingyue" object:nil];
    
    
    
    
}


-(void)WhetherWatchAd{
    [self updateStyle];
    
    if (self.isLoadingBook) {
        return;
    }
    
    self.contentImage.image = nil;
    [self.activity startAnimating];
    _QWAdDict = [NSMutableDictionary new];
    NSLog(@"章节id = %@",[[QWReadingManager sharedInstance] getChapterIdWithReadingVC:self]);
    NSMutableDictionary *adparam = [NSMutableDictionary new];
    adparam[@"token"] = [QWGlobalValue sharedInstance].token;
    adparam[@"device_id"] = [QWGlobalValue sharedInstance].deviceToken;
    adparam[@"chapter_id"] = [[QWReadingManager sharedInstance] getChapterIdWithReadingVC:self];
    QWOperationParam *globalAdpm = [QWInterface postWithUrl:[NSString stringWithFormat:@"%@/ad/chapter/",[QWOperationParam currentDomain]] params:adparam andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (aResponseObject != nil) {
            self->_QWAdDict = aResponseObject;
//            "ad_free" 1=有广告 0是没广告
//            "ad_type" 1是图片广告 0是视频广告
//            "free_chapter" 1是付费章节 0是免费章节
//            "wait_time" 等待时间
//            footing_ad_typead_type : 0 SDK广告
//            1 自定义广告
//            2 关闭广告
            VolumeVO *volume = [[QWReadingManager sharedInstance] currentVolumeVO];
            ChapterVO *chapter = volume.chapter[self.currentPage.chapterIndex];
            if (self.QWAdDict[@"ad_type"] != nil) {
                chapter.ad_type = self.QWAdDict[@"ad_type"];
                chapter.ad_free = self.QWAdDict[@"ad_free"];
                chapter.insert_ad = self.QWAdDict[@"insert_ad"];
                chapter.insert_page = self.QWAdDict[@"insert_page"];
                chapter.free_chapter = self.QWAdDict[@"free_chapter"];
                chapter.book_Id = volume.book.nid;
                chapter.lastPageAd = self.QWAdDict[@"footing_ad_type"];
                NSLog(@"广告类型 = %@ 是否看广告 = %@",chapter.ad_type , chapter.ad_free);
            }
            [self refreshContent];
            
        }
        else{
            self->_QWAdDict = [[NSMutableDictionary alloc] initWithDictionary:@{@"ad_free":@(0),
                                                                                @"ad_type":@(0),
                                                                                @"insert_ad":@(1),
                                                                                @"insert_page":@(3),
                                                                                @"free_chapter":@(0),
                                                                                }];
            VolumeVO *volume = [[QWReadingManager sharedInstance] currentVolumeVO];
            ChapterVO *chapter = volume.chapter[self.currentPage.chapterIndex];
            if (self.QWAdDict[@"ad_type"] != nil) {
                chapter.ad_type = self.QWAdDict[@"ad_type"];
                chapter.ad_free = self.QWAdDict[@"ad_free"];
                chapter.insert_ad = self.QWAdDict[@"insert_ad"];
                chapter.insert_page = self.QWAdDict[@"insert_page"];
                chapter.free_chapter = self.QWAdDict[@"free_chapter"];
                chapter.book_Id = volume.book.nid;
                chapter.lastPageAd = [NSNumber numberWithBool:2];
                NSLog(@"广告类型 = %@ 是否看广告 = %@",chapter.ad_type , chapter.ad_free);
            }
            [self refreshContent];
        }
            }];
    globalAdpm.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:globalAdpm];
}

-(void)dakaiDingyue{
    self.autodingyue = 1;
}
-(void)cancelDingyue{
    self.autodingyue = 0;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}
-(void)freshUI:(NSNotification *)noc{
    
}


//刷新阅读的内容
- (void)refreshContent {
    @synchronized(self) {
        if (self.loading) {
            return ;
        }
        
        self.loading = YES;
    }
    
    //更新背景
    [self updateStyle];
    
    if (self.isLoadingBook) {
        return;
    }
    
    self.contentImage.image = nil;
    [self.activity startAnimating];
    
    
    WEAK_SELF;
    [[QWReadingManager sharedInstance] getReadingContentWithReadingVC:self andCompleteBlock:^(id __nullable content, QWReadingContentType type) {
        STRONG_SELF;
        [self.activity stopAnimating];
        [self.parentViewController hideLoading];
        switch (type) {
            case QWReadingContentTypeContent:
                self.loading = NO;
                self.contentImage.image = content;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ttsNextPage" object:nil];
                break;
            case QWReadingContentTypeImage:
            {
                self.loading = NO;
                self.picture = YES;
                self.pictureName = content;
                BookCD *book = [QWReadingManager sharedInstance].bookCD;
                VolumeVO *volume = [[QWReadingManager sharedInstance] currentVolumeVO];
                if ([content hasPrefix:@"http"]) {
                    content = [content stringByReplacingOccurrencesOfString:@"http://image.iqing.in/" withString:@"/"];
                }
                ChapterVO *chapter = volume.chapter[self.currentPage.chapterIndex];
                chapter.collection = volume.collection;
                NSString *filePathStr = [QWFileManager imagePathWithBookId:book.nid.stringValue volumeId:volume.nid.stringValue chapterId:chapter.nid.stringValue imageName:content];
                if (![QWFileManager isFileExistWithFileUrl:filePathStr]) {
                    self.emptyView.useDark = [QWReadingConfig sharedInstance].readingBG == QWReadingBGBlack;
                    self.emptyView.hidden = NO;
                    self.emptyView.showError = YES;
                }
                else {
                    self.contentImage.image = [[UIImage alloc] initWithContentsOfFile:filePathStr];
                }
            }
                break;
            case QWReadingContentTypeNetImage:
            {
                self.loading = NO;
                self.picture = YES;
                self.pictureName = content;
                self.emptyView.useDark = [QWReadingConfig sharedInstance].readingBG == QWReadingBGBlack;
                self.emptyView.hidden = NO;
                [self.contentImage qw_setImageUrlString:[QWConvertImageString convertPicURL:content imageSizeType:QWImageSizeTypeIllustration] placeholder:nil animation:YES completeBlock:^(UIImage *image, NSError *error, NSURL *imageURL) {
                    STRONG_SELF;
                    NSLog(@"%@",imageURL);
                    if (!error && image) {
                        self.emptyView.hidden = YES;
                        [self.contentImage showChangeImageAnimtion];
                    }
                    else {
                        NSLog(@"图片下载失败");
#ifndef DEBUG
                        if (error.code == 404) {//图片不存在导致
                            VolumeVO *volume = [[QWReadingManager sharedInstance] currentVolumeVO];
                            ChapterVO *chapter = volume.chapter[self.currentPage.chapterIndex];
                            StatisticVO *statistic = [StatisticVO new];
                            statistic.bookId = [QWReadingManager sharedInstance].bookCD.nid.stringValue;
                            statistic.chapterId = chapter.nid.stringValue;
                            statistic.imageUrl = [QWConvertImageString convertPicURL:content imageSizeType:QWImageSizeTypeIllustration];
                            [[BaiduMobStat defaultStat] logEvent:@"image404" eventLabel:statistic.toJSONString];
                        }
#endif
                        self.emptyView.showError = YES;
                    }
                }];
            }
                break;
            case QWReadingContentTypeChapter:
            {
                self.isChapter = YES;
                [self.chapterView updateWithChapterVO:[QWReadingManager sharedInstance].currentVolumeVO.chapter[self.currentPage.chapterIndex]];
                self.chapterView.delegate = self;
                self.chapterView.hidden = NO;
                VolumeVO *volume = [[QWReadingManager sharedInstance] currentVolumeVO];
                ChapterVO *chapter = volume.chapter[self.currentPage.chapterIndex];
                chapter.collection = volume.collection;
                if ([chapter.whisper isEqualToString:@""]) {
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"lineisHiden" object:nil];
                }
            }
                break;
            case QWReadingContentTypeChapterDone:
            {
                self.isChapter = YES;
                self.loading = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ttsNextPage" object:nil];
                [self.chapterView showCompleted];
            }
                break;
            case QWReadingContentTypeError:
            {
                self.loading = NO;
                
                [self.chapterView showError];
            }
                break;
            default:
                break;
        }
        
        
        //更新阅读的进度
        VolumeVO *volume = [[QWReadingManager sharedInstance] currentVolumeVO];
        ChapterVO *chapter = volume.chapter[self.currentPage.chapterIndex];
        chapter.collection = volume.collection;
        
        NSNumber *bookId = [QWReadingManager sharedInstance].bookCD.nid;
        
        NSInteger progress = 0;
        if (chapter.pageCount > 1) {
            progress = self.currentPage.pageIndex * 100 / (chapter.pageCount - 1);
            if (progress >= 80) {
                
            }
        }
        else {
            progress = 100;
        }
        if (chapter.type.integerValue == 2 && self.currentPage.pageIndex == 1 && chapter.amount.floatValue > 0 && [QWReadingManager sharedInstance].offline == false) {
            self.isSubscribe = NO;
            if (![QWGlobalValue sharedInstance].isLogin) {
                QWSubscriberAlertTypeTwo *alert = [QWSubscriberAlertTypeTwo alertViewWithButtonAction:^(QWSubscriberActionType type) {
                    STRONG_SELF;
                    
                }];
                chapter.book = bookId;
                chapter.collection = volume.collection;
                NSLog(@"chaptercolo = %@",chapter.collection);
                [alert updateAlertWithChapter:chapter];
                [alert show];
            } else {
                [self.subscriberLogic getPurchaseListWithBookId:bookId andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
                    STRONG_SELF;
                    if (aResponseObject && !anError) {
                        SubscriberList *listVO = [SubscriberList voWithDict:aResponseObject];
                        SubscriberVO *result = listVO.results.firstObject;
                        if ([result.toggle boolValue]) {
                            self.subscriberLogic.autoPurechase = @1;
                            self.autodingyue = 2;
                            
                            NSNumber *useVoucher = @0;
                            if ([QWGlobalValue sharedInstance].user.coin.integerValue > chapter.amount_coin.integerValue) {
                                useVoucher = @1;
                            }else if([QWGlobalValue sharedInstance].user.gold.integerValue > chapter.amount.integerValue){
                                //                                [self showToastWithTitle:@"轻石余额不足" subtitle:@"您的轻石余额不足，已使用重石自动帮您购买本章" type:ToastTypeAlert];
                            }else{
                                //cancel auto subscribe
                                [self showLoading];
                                [self.userLogic setSubscribedBookCompleteBlock:(NSNumber *)chapter.book isSub:(BOOL)NO CompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
                                    STRONG_SELF;
                                    [self hideLoading];
                                    if (!anError) {
                                        NSNumber *code = aResponseObject[@"code"];
                                        NSLog(@"result :%@",code);
                                        if (code && ! [code isEqualToNumber:@0]) {//有错误
                                            NSString *message = aResponseObject[@"msg"];
                                            if (message.length) {
                                                [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                                            }
                                            else {
                                                [self showToastWithTitle:@"提交失败" subtitle:nil type:ToastTypeError];
                                                self.isSubscribe = NO;
                                            }
                                        }else{
                                            self.isSubscribe = NO;
                                            [self showToastWithTitle:@"您的余额不足" subtitle:@"您的余额不足，自动购买已停止" type:ToastTypeAlert];
                                            QWSubscriberAlertTypeTwo *alert = [QWSubscriberAlertTypeTwo alertViewWithButtonAction:^(QWSubscriberActionType type) {
                                                STRONG_SELF;
                                                
                                            }];
                                            chapter.book = bookId;
                                            chapter.collection = volume.collection;
                                            NSLog(@"chaptercolo = %@",chapter.collection);
                                            [alert updateAlertWithChapter:chapter];
                                            [alert show];

                                        }
                                    }
                                    else {
                                        [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
                                    }
                                    
                                }];
                                
                                return;
                            }
                            
                            [self.subscriberLogic doSubscriberChaperWithChapterId:chapter.nid useVoucher:useVoucher andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
                                STRONG_SELF;
                                if (!anError) {
                                    NSNumber *code = aResponseObject[@"code"];
                                    if (code && ! [code isEqualToNumber:@0]) {//有错误
                                        NSString *message = aResponseObject[@"data"];
                                        if (message.length) {
                                            [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                                        }
                                        else {
                                            self.isSubscribe = NO;
                                            [self showToastWithTitle:aResponseObject[@"msg"] subtitle:nil type:ToastTypeError];
                                        }
                                    }
                                    else {
                                        if([useVoucher isEqual: @1]){
                                            [QWGlobalValue sharedInstance].user.coin = @([QWGlobalValue sharedInstance].user.coin.integerValue - chapter.amount_coin.integerValue);
                                        }else{
                                            [QWGlobalValue sharedInstance].user.gold = @([QWGlobalValue sharedInstance].user.gold.integerValue - chapter.amount.integerValue);
                                        }
                                        
                                        [[QWGlobalValue sharedInstance] save];
                                        chapter.contentVO = nil;
                                        chapter.completed = false;
                                        [self WhetherWatchAd];
                                        
                                    }
                                }
                                else {
                                    [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
                                }
                            }];
                        }else  {
                            self.isSubscribe = NO;
                            QWSubscriberAlertTypeTwo *alert = [QWSubscriberAlertTypeTwo alertViewWithButtonAction:^(QWSubscriberActionType type) {
                                STRONG_SELF;
                                if (type == QWSubscriberActionTypeBuy) {
                                    chapter.contentVO = nil;
                                    chapter.completed = false;
                                    [self WhetherWatchAd];
                                }
                            }];
                            chapter.book = bookId;
                            [alert updateAlertWithChapter:chapter];
                            [alert show];
                        }
                    }
                }];
            }
        }
        [self.bottomStatusView updateWithProgress:progress];
        

        if (type == QWReadingContentTypeChapter || type == QWReadingContentTypeChapterDone ||type == QWReadingContentTypeError) {
            self.topNameView.hidden = true;
        } else {
            self.topNameView.hidden = false;
            [self.topNameView updateWithChapterTitle:chapter.title];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PROGRESS_VIEW_UPDATE_COUNT" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"QWREADING_PICTURE" object:nil];
        
        
    }];
    
 
}

- (void)update
{
    [self WhetherWatchAd];
}

- (void)chapterView:(QWChapterView *)view onPressedRetryBtn:(id)sender
{
    [self WhetherWatchAd];
}

- (QWChapterView *)chapterView
{
    if (!_chapterView) {
        _chapterView = [QWChapterView createWithNib];
        [self.view addSubview:_chapterView];
        [_chapterView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.contentImage];
        [_chapterView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.contentImage];
        [_chapterView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.contentImage];
        [_chapterView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.contentImage];    }
    
    return _chapterView;
}

- (void)updateStyle
{
    switch ([QWReadingConfig sharedInstance].readingBG) {
        case QWReadingBGDefault:
            self.backgroundView.image = [UIImage imageNamed:@"reading_bg_1"];
            self.backgroundView.backgroundColor = nil;
            break;
        case QWReadingBGBlack:
            self.backgroundView.image = nil;
            self.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"reading_bg_2"]];
            break;
        case QWReadingBGGreen:
            self.backgroundView.image = nil;
            self.backgroundView.backgroundColor = HRGB(0xceefce);
            break;
        case QWReadingBGPink:
            self.backgroundView.image = nil;
            self.backgroundView.backgroundColor = HRGB(0xfcdfe7);
            break;
        default:
            self.backgroundView.image = [UIImage imageNamed:@"reading_bg_1"];
            self.backgroundView.backgroundColor = nil;
            break;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

//预加载下一章内容
-(void)freshNextContent{
    
    VolumeVO *volume = [[QWReadingManager sharedInstance] currentVolumeVO];
    
    if (volume.chapter.count >= self.currentPage.chapterIndex + 2 ) {
        ChapterVO *chapter = volume.chapter[self.currentPage.chapterIndex + 1];
        chapter.collection = volume.collection;
        if (chapter.subscriber == YES) {
            
        }
        else{
  
            NSNumber *useVoucher = @0;
            if ([QWGlobalValue sharedInstance].user.coin.integerValue > chapter.amount_coin.integerValue) {
                useVoucher = @1;
            }
            
            [self.subscriberLogic doSubscriberChaperWithChapterId:chapter.nid useVoucher:useVoucher andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
                if (!anError) {
                    NSNumber *code = aResponseObject[@"code"];
                    if (code && ! [code isEqualToNumber:@0]) {//有错误
                        NSString *message = aResponseObject[@"data"];
                        if (message.length) {
                            //                                        [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                        }
                        else {
                            [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                        }
                    }
                    else {
                        if([useVoucher isEqual: @1]){
                            [QWGlobalValue sharedInstance].user.coin = @([QWGlobalValue sharedInstance].user.coin.integerValue - chapter.amount_coin.integerValue);
                        }else{
                            [QWGlobalValue sharedInstance].user.gold = @([QWGlobalValue sharedInstance].user.gold.integerValue - chapter.amount.integerValue);
                        }
                        
                        //                            [[QWGlobalValue sharedInstance] save];
                        chapter.contentVO = nil;
                        chapter.completed = false;
                        //                            [self refreshContent];
                        //                                        [self showToastWithTitle:@"订阅成功,已添加到收藏夹" subtitle:nil type:ToastTypeError];
                    }
                }
                else {
                    //                                [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
                }
            }];
        }
        
    }

}

@end
