//
//  QWReadingPVC.h
//  Qingwen
//
//  Created by Aimy on 7/6/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QWReadingVC.h"

#import <AVFoundation/AVFoundation.h>
#import "IFlyMSC/IFlyMSC.h"
#import "PcmPlayer.h"
#import "QWGDTReadNativeAdView.h"
@class IFlySpeechSynthesizer;


typedef NS_OPTIONS(NSInteger, SynthesizeType) {
    NomalType           = 5,    //Normal TTS
    UriType             = 6,    //URI TTS
};

//state of TTS
typedef NS_OPTIONS(NSInteger, Status) {
    NotStart            = 0,
    Playing             = 2,
    Paused              = 4,
};

@interface QWReadingPVC : QWBaseVC<UIPageViewControllerDataSource,IFlySpeechSynthesizerDelegate>
@property  BOOL isAloud;
@property  BOOL isPause;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (nonatomic, strong) QWReadingVC *currentVC;

@property (nonatomic, strong) IFlySpeechSynthesizer * iFlySpeechSynthesizer;
@property (nonatomic, strong) NSString *uriPath;
@property (nonatomic, strong) PcmPlayer *audioPlayer;
@property (nonatomic, assign) BOOL isCanceled;
@property (nonatomic, assign) BOOL hasError;
@property (nonatomic, assign) BOOL isViewDidDisappear;
@property (nonatomic, assign) Status state;
@property (nonatomic, assign) SynthesizeType synType;

//广告相关
@property (nonatomic ,strong)QWGDTReadNativeAdView *GDTAdView;
@property (nonatomic,strong)UILabel *VipLab;
@property (nonatomic,strong)UIView *VipLine;
@end
