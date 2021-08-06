//
//  QWReadingAloudSettingView.m
//  Qingwen
//
//  Created by qingwen on 2018/5/23.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import "QWReadingAloudSettingView.h"
#import "QWReadingConfig.h"
#import "QWReadingVC.h"
#import "QWReadingPVC.h"
#import "TTSConfig.h"
//百度语音
#import "BDSSpeechSynthesizer.h"
#import "BDSSpeechSynthesizerDelegate.h"
#import "BDS_EttsModelManagerInterface.h"
#import "BDSTTSEventManager.h"

#define kHeight 214
#define kblackColor HRGB(0x2F2E2E)
#define kpinkColor HRGB(0xFF8E9B)
@interface QWReadingPVC ()

- (void)exitAloud;
-(void)suspendedAloud;
-(void)countdownWithMins:(int)time;
-(void)initSynthesizer;
-(void)startAloud;
-(void)goOnAloud;
-(void)displayError:(NSError*)error withTitle:(NSString*)title;
@end

@interface QWReadingAloudSettingView ()
{
    int secondsCountDown; //倒计时总时长
    NSTimer *countDownTimer;
    NSArray *btnArr;
    int selectIndex;
}
@property (nonatomic) BOOL config;
@property (nonatomic, strong) NSLayoutConstraint *constraint;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *boyAloud;
@property (weak, nonatomic) IBOutlet UIButton *girlAloud;
@property (weak, nonatomic) IBOutlet UISlider *speedSlider;
@property (weak, nonatomic) IBOutlet UIButton *fiveMinsBtn;
@property (weak, nonatomic) IBOutlet UIButton *sixtyMinsBtn;
@property (weak, nonatomic) IBOutlet UIButton *fifteenMinsBtn;
@property (weak, nonatomic) IBOutlet UIButton *thirtyMinsBtn;
@property (weak, nonatomic) IBOutlet UIButton *exitAloudBtn;
@property (weak, nonatomic) IBOutlet UIButton *suspendedAloudBtn;
@property (weak, nonatomic) IBOutlet UIButton *boy1Btn;
@property (weak, nonatomic) IBOutlet UIButton *boy2Btn;

@end

@implementation QWReadingAloudSettingView



- (void)awakeFromNib
{
    [super awakeFromNib];
    self.hidden = YES;
    btnArr = @[_fiveMinsBtn,_fifteenMinsBtn,_thirtyMinsBtn,_sixtyMinsBtn];
    
    TTSConfig *instance = [TTSConfig sharedInstance];
    if (instance == nil) {
        return;
    }
    if ([instance.vcnName isEqualToString:@"xiaoyu"]) {
        self.boyAloud.backgroundColor = kpinkColor;
    }
    else{
        self.girlAloud.backgroundColor = kpinkColor;
    }
    
    _speedSlider.minimumValue = 0.0;
    _speedSlider.maximumValue = 100.0;
    _speedSlider.value = instance.speed.floatValue;
    _speedSlider.continuous = NO;
}

- (void)didMoveToSuperview
{
    if (!self.config) {
        self.config = YES;
        self.constraint = [self autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.superview];
        [self autoConstrainAttribute:ALAttributeVertical toAttribute:ALAttributeVertical ofView:self.superview];
        [self autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.superview];
        self.heightConstraint = [self autoSetDimension:ALDimensionHeight toSize:kHeight];
    }
}

- (void)showWithAnimated
{
//    [self configBtns];
    self.hidden = NO;
    [self.superview bringSubviewToFront:self];
    
    if (@available(iOS 11.0, *)) {
        self.constraint.constant = -kHeight - self.superview.safeAreaInsets.bottom;
        if(ISIPHONEX){
            self.heightConstraint.constant = kHeight + self.superview.safeAreaInsets.bottom;
        }
    }else{
        self.constraint.constant = -kHeight;
    }
    
    
    WEAK_SELF;
    [UIView animateWithDuration:.3f animations:^{
        STRONG_SELF;
        [self layoutIfNeeded];
    }];
}

- (void)hideWithAnimated
{
    self.constraint.constant = 0;
    
    WEAK_SELF;
    [UIView animateWithDuration:.3f animations:^{
        STRONG_SELF;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        STRONG_SELF;
        self.hidden = YES;
    }];
}
- (IBAction)speedChange:(id)sender {
    [self.ownerVC exitAloud];
    NSError* err = [[BDSSpeechSynthesizer sharedInstance] setSynthParam:[NSNumber numberWithInteger:self.speedSlider.value/10] forKey:BDS_SYNTHESIZER_PARAM_SPEED];
    if(err){
//        [self.ownerVC displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Failed set synth speed" value:@"" table:@"Localizable"]];
        self.ownerVC.isAloud = YES;
        [self.ownerVC startAloud];
    }
    else{
        self.ownerVC.isAloud = YES;
       [self.ownerVC startAloud];
    }
    
}
- (IBAction)boyAloudClick:(id)sender {
    
    self.boyAloud.backgroundColor = kpinkColor;
    self.girlAloud.backgroundColor = kblackColor;
    self.boy1Btn.backgroundColor = kblackColor;
    self.boy2Btn.backgroundColor = kblackColor;
    [self.ownerVC exitAloud];
    NSError *err = [[BDSSpeechSynthesizer sharedInstance] setSynthParam:@(BDS_SYNTHESIZER_SPEAKER_FEMALE) forKey:BDS_SYNTHESIZER_PARAM_SPEAKER];
    if(err){
        [self.ownerVC displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Failed set online TTS speaker" value:@"" table:@"Localizable"]];
    }
    else{
        self.ownerVC.isAloud = YES;
        
        NSError *offerr = nil;
        // 在这里选择不同的离线音库（请在XCode中Add相应的资源文件），同一时间只能load一个离线音库。根据网络状况和配置，SDK可能会自动切换到离线合成。
        NSString* offlineEngineSpeechData = [[NSBundle mainBundle] pathForResource:@"Chinese_And_English_Speech_Female" ofType:@"dat"];
        
        NSString* offlineChineseAndEnglishTextData = [[NSBundle mainBundle] pathForResource:@"Chinese_And_English_Text" ofType:@"dat"];
        
        offerr = [[BDSSpeechSynthesizer sharedInstance] loadOfflineEngine:offlineChineseAndEnglishTextData speechDataPath:offlineEngineSpeechData licenseFilePath:nil withAppCode:@"11380459"];
        if(offerr){
            [self.ownerVC displayError:err withTitle:@"Offline TTS init failed"];
            return;
        }
        [self.ownerVC startAloud];
    }
    
    
}
- (IBAction)girlAloudClick:(id)sender {
    self.girlAloud.backgroundColor = kpinkColor;
    self.boyAloud.backgroundColor = kblackColor;
    self.boy1Btn.backgroundColor = kblackColor;
    self.boy2Btn.backgroundColor = kblackColor;
    [self.ownerVC exitAloud];
    NSError *err = [[BDSSpeechSynthesizer sharedInstance] setSynthParam:@(BDS_SYNTHESIZER_SPEAKER_DYY) forKey:BDS_SYNTHESIZER_PARAM_SPEAKER];
    if(err){
        [self.ownerVC displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Failed set online TTS speaker" value:@"" table:@"Localizable"]];
    }
    else{
        self.ownerVC.isAloud = YES;
        NSError *offerr = nil;
        // 在这里选择不同的离线音库（请在XCode中Add相应的资源文件），同一时间只能load一个离线音库。根据网络状况和配置，SDK可能会自动切换到离线合成。
        NSString* offlineEngineSpeechData = [[NSBundle mainBundle] pathForResource:@"Chinese_And_English_Speech_DYY" ofType:@"dat"];
        
        NSString* offlineChineseAndEnglishTextData = [[NSBundle mainBundle] pathForResource:@"Chinese_And_English_Text" ofType:@"dat"];
        
        offerr = [[BDSSpeechSynthesizer sharedInstance] loadOfflineEngine:offlineChineseAndEnglishTextData speechDataPath:offlineEngineSpeechData licenseFilePath:nil withAppCode:@"11380459"];
        if(offerr){
            [self.ownerVC displayError:err withTitle:@"Offline TTS init failed"];
            return;
        }
        [self.ownerVC startAloud];
        
    }
    
    
}
- (IBAction)boy1AloudClick:(id)sender {
    self.girlAloud.backgroundColor = kblackColor;
    self.boyAloud.backgroundColor = kblackColor;
    self.boy1Btn.backgroundColor = kpinkColor;
    self.boy2Btn.backgroundColor = kblackColor;
    [self.ownerVC exitAloud];
    NSError *err = [[BDSSpeechSynthesizer sharedInstance] setSynthParam:@(BDS_SYNTHESIZER_SPEAKER_MALE) forKey:BDS_SYNTHESIZER_PARAM_SPEAKER];
    if(err){
        [self.ownerVC displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Failed set online TTS speaker" value:@"" table:@"Localizable"]];
    }
    else{
        self.ownerVC.isAloud = YES;
       
        NSError *offerr = nil;
        // 在这里选择不同的离线音库（请在XCode中Add相应的资源文件），同一时间只能load一个离线音库。根据网络状况和配置，SDK可能会自动切换到离线合成。
        NSString* offlineEngineSpeechData = [[NSBundle mainBundle] pathForResource:@"Chinese_And_English_Speech_Male" ofType:@"dat"];
        
        NSString* offlineChineseAndEnglishTextData = [[NSBundle mainBundle] pathForResource:@"Chinese_And_English_Text" ofType:@"dat"];
        
        offerr = [[BDSSpeechSynthesizer sharedInstance] loadOfflineEngine:offlineChineseAndEnglishTextData speechDataPath:offlineEngineSpeechData licenseFilePath:nil withAppCode:@"11380459"];
        if(offerr){
            [self.ownerVC displayError:err withTitle:@"Offline TTS init failed"];
            return;
        }
        [self.ownerVC startAloud];
    }
    
}
- (IBAction)boy2AloudClick:(id)sender {
    self.girlAloud.backgroundColor = kblackColor;
    self.boyAloud.backgroundColor = kblackColor;
    self.boy1Btn.backgroundColor = kblackColor;
    self.boy2Btn.backgroundColor = kpinkColor;
    [self.ownerVC exitAloud];
    NSError *err = [[BDSSpeechSynthesizer sharedInstance] setSynthParam:@(BDS_SYNTHESIZER_SPEAKER_MALE_3) forKey:BDS_SYNTHESIZER_PARAM_SPEAKER];
    if(err){
        [self.ownerVC displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Failed set online TTS speaker" value:@"" table:@"Localizable"]];
    }
    else{
        self.ownerVC.isAloud = YES;
      
        NSError *offerr = nil;
        // 在这里选择不同的离线音库（请在XCode中Add相应的资源文件），同一时间只能load一个离线音库。根据网络状况和配置，SDK可能会自动切换到离线合成。
        NSString* offlineEngineSpeechData = [[NSBundle mainBundle] pathForResource:@"Chinese_And_English_Speech_Male-yyjw" ofType:@"dat"];
        
        NSString* offlineChineseAndEnglishTextData = [[NSBundle mainBundle] pathForResource:@"Chinese_And_English_Text" ofType:@"dat"];
        
        offerr = [[BDSSpeechSynthesizer sharedInstance] loadOfflineEngine:offlineChineseAndEnglishTextData speechDataPath:offlineEngineSpeechData licenseFilePath:nil withAppCode:@"11380459"];
        if(offerr){
            [self.ownerVC displayError:err withTitle:@"Offline TTS init failed"];
            return;
        }
        [self.ownerVC startAloud];
    }
    
}
- (IBAction)fiveMinsClick:(id)sender {
    self.fiveMinsBtn.backgroundColor = kpinkColor;
    self.sixtyMinsBtn.backgroundColor = kblackColor;
    self.thirtyMinsBtn.backgroundColor = kblackColor;
    self.fifteenMinsBtn.backgroundColor = kblackColor;
    [self createTime:0];
    
}
- (IBAction)sixtyMinsClick:(id)sender {
    self.fiveMinsBtn.backgroundColor = kblackColor;
    self.sixtyMinsBtn.backgroundColor = kpinkColor;
    self.thirtyMinsBtn.backgroundColor = kblackColor;
    self.fifteenMinsBtn.backgroundColor = kblackColor;
    [self createTime:3];
}
- (IBAction)fifteenMinsClick:(id)sender {
    self.fiveMinsBtn.backgroundColor = kblackColor;
    self.sixtyMinsBtn.backgroundColor = kblackColor;
    self.thirtyMinsBtn.backgroundColor = kblackColor;
    self.fifteenMinsBtn.backgroundColor = kpinkColor;
    [self createTime:1];
}
- (IBAction)thirtyMinsClick:(id)sender {
    self.fiveMinsBtn.backgroundColor = kblackColor;
    self.sixtyMinsBtn.backgroundColor = kblackColor;
    self.thirtyMinsBtn.backgroundColor = kpinkColor;
    self.fifteenMinsBtn.backgroundColor = kblackColor;
    [self createTime:2];
}

-(void)createTime:(int)index{
    //设置倒计时总时长
    selectIndex = index;
    [countDownTimer invalidate];
    countDownTimer = [NSTimer new];
    if (index == 0) {
       secondsCountDown = 300;
    }
    else if (index == 1){
        secondsCountDown = 900;
    }
    else if (index == 2){
        secondsCountDown = 1800;
    }
    else{
        secondsCountDown = 3600;
    }
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethodWithIndex) userInfo:nil repeats:YES];
    //开始倒计时
     //启动倒计时后会每秒钟调用一次方法 timeFireMethod
    NSArray *titleArr = @[@"5分钟",@"15分钟",@"30分钟",@"60分钟"];
    int mins = secondsCountDown/60;
    int second = secondsCountDown - mins*60;
    for (int i =0 ; i<4 ; i ++ ) {
        UIButton *btn = btnArr[i];
        if (i == index) {
            
            [btn setTitle:[NSString stringWithFormat:@"%d:%d0",mins,second] forState:0];
        }
        else{
            [btn setTitle:titleArr[i] forState:0];
        }
    }

}

-(void)timeFireMethodWithIndex{
    //倒计时-1
    secondsCountDown--;
    //修改倒计时标签现实内容
//    NSArray *titleArr = @[@"5分钟",@"15分钟",@"30分钟",@"60分钟"];
    int mins = secondsCountDown/60;
    int second = secondsCountDown - mins*60;
    for (int i =0 ; i<4 ; i ++ ) {
        UIButton *btn = btnArr[i];
        if (i == selectIndex) {
            if (second<10) {
                [btn setTitle:[NSString stringWithFormat:@"%d:0%d",mins,second] forState:0];
            }else{
                [btn setTitle:[NSString stringWithFormat:@"%d:%d",mins,second] forState:0];
            }
            
        }
    }
    if(secondsCountDown==0){
        [countDownTimer invalidate];
        [self.ownerVC exitAloud];
    }
}
- (IBAction)exitClick:(id)sender {
    [countDownTimer invalidate];
    NSArray *titleArr = @[@"5分钟",@"15分钟",@"30分钟",@"60分钟"];
    for (int i =0 ; i<4 ; i ++ ) {
        UIButton *btn = btnArr[i];
        [btn setTitle:titleArr[i] forState:0];
        btn.backgroundColor = kblackColor;
    }
    [self.ownerVC exitAloud];
    
}
- (IBAction)suspendedClick:(id)sender {
    
    if ([self.suspendedAloudBtn.titleLabel.text isEqualToString:@"暂停朗读"]) {
        [self.suspendedAloudBtn setTitle:@"继续朗读" forState:0];
        [self.ownerVC suspendedAloud];
    }
    else{
        [self.suspendedAloudBtn setTitle:@"暂停朗读" forState:0];
        [self.ownerVC goOnAloud];
    }
    
}

@end
