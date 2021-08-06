//
//  QWContributionSubmitView.m
//  Qingwen
//
//  Created by mumu on 2017/9/9.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWContributionSubmitView.h"
#import "QWContributionLogic.h"
#import "QWPopoverView.h"

@interface QWContributionSubmitView()

@property (nonatomic, strong) QWContributionLogic *logic;

@property (nonatomic, strong) VolumeVO *volume;

@property (nonatomic, strong) ChapterVO *chapter;

@property (strong, nonatomic) IBOutlet UIButton *volumBtn;

@property (strong, nonatomic) IBOutlet UIButton *chapterBtn;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, strong) BookVO *book;

@end

@implementation QWContributionSubmitView

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (QWContributionLogic *)logic {
    if (!_logic) {
        _logic = [QWContributionLogic logicWithOperationManager:self.operationManager];
        _logic.book = self.book;
    }
    return _logic;
}

- (void)updateWithBook:(BookVO *)book {
    self.book = book;
    [self getVolumeList];
}

- (void)getVolumeList {
    if (self.logic.loading) {
        return;
    }
    
    WEAK_SELF;
    self.logic.loading = true;
    [self.logic getVolumesWithBookId:self.book.nid.stringValue andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (aResponseObject && !anError) {
            
        }
        else {
            [self showToastWithTitle:anError.localizedDescription subtitle:nil type:ToastTypeError];
        }
        self.logic.loading = false;
    }];
}

- (void)getChapterList {

    if (self.volume.chapter && self.volume.chapter.count > 0) {
        return;
    }
    
    WEAK_SELF;
    [self showLoading];
    [self.logic getChaptersWithVolume:self.volume andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (aResponseObject && !anError) {
            
        }
        else {
            [self showToastWithTitle:anError.localizedDescription subtitle:nil type:ToastTypeError];
        }
        [self hideLoading];
    }];
}

- (IBAction)onPressedChoiceVolumBtn:(UIButton *)sender {
    if (!self.logic.draftVolumeList || self.logic.draftVolumeList.results.count == 0) {
        [self showToastWithTitle:@"并没有通过的卷" subtitle:nil type:ToastTypeError];
        [self dismiss:nil];
        return;
    }
    
    CGFloat x = self.volumBtn.center.x + self.contentView.mj_x;
    CGFloat y = self.volumBtn.mj_y + self.volumBtn.mj_h + self.contentView.mj_y;
    
    NSLog(@"self.logic.draftVolumeList.results = %@",self.logic.draftVolumeList.results);
    NSMutableArray *titleArr = [NSMutableArray new];
    for (VolumeVO *dic in self.logic.draftVolumeList.results) {
        NSMutableDictionary *data = [NSMutableDictionary new];
        data[@"name"] = dic.title;
        data[@"code"] = dic.nid;
        [titleArr addObject:data];
    }
    QWPopoverView *poperView = [[QWPopoverView alloc] initWithPoint:CGPointMake(x, y) titles:titleArr size:CGSizeMake(self.volumBtn.mj_w, self.contentView.mj_h - self.volumBtn.mj_y - self.volumBtn.mj_h) stype:UITableViewCellStyleDefault];
    WEAK_SELF;
    poperView.selectRowAtIndex = ^(NSInteger index) {
        STRONG_SELF;
        self.volume = self.logic.draftVolumeList.results[index];
        [self.volumBtn setTitle:self.volume.title forState:UIControlStateNormal];
        [self.chapterBtn setTitle:@"请选择章节" forState:UIControlStateNormal];
        [self getChapterList];
    };
    [poperView show];
}

- (IBAction)onPressedChoiceChapterBtn:(UIButton *)sender {
    
    if (!self.volume.chapter || self.volume.chapter.count == 0) {
        [self showToastWithTitle:@"当前卷没有通过的章节" subtitle:nil type:ToastTypeError];
    }
    CGFloat x = self.chapterBtn.center.x + self.contentView.mj_x;
    CGFloat y = self.chapterBtn.mj_y + self.volumBtn.mj_h + self.contentView.mj_y;
    NSMutableArray *titleArr = [NSMutableArray new];
    for (ChapterVO *dic in self.volume.chapter) {
        NSMutableDictionary *data = [NSMutableDictionary new];
        data[@"name"] = dic.title;
        data[@"code"] = dic.nid;
        [titleArr addObject:data];
    }
    QWPopoverView *poperView = [[QWPopoverView alloc] initWithPoint:CGPointMake(x, y) titles:titleArr size:CGSizeMake(self.chapterBtn.mj_w, self.contentView.mj_h - self.chapterBtn.mj_y - self.chapterBtn.mj_h) stype:UITableViewCellStyleDefault];
    WEAK_SELF;
    poperView.selectRowAtIndex = ^(NSInteger index) {
        STRONG_SELF;
        self.chapter = self.volume.chapter[index];
        [self.chapterBtn setTitle:self.chapter.title forState:UIControlStateNormal];
        [self getChapterList];
    };
    [poperView show];
}

- (IBAction)onPressedConfirmBtn:(id)sender {
    [self.delegate submitView:self selesectVolume:self.volume.nid.stringValue chapter:self.chapter.nid.stringValue];
    [self dismiss:nil];
}

@end
