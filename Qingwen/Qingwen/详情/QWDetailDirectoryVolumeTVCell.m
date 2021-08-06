//
//  QWDetailDirectoryVolumeTVCell.m
//  Qingwen
//
//  Created by Aimy on 9/29/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWDetailDirectoryVolumeTVCell.h"

#import "QWFileManager.h"
#import "QWDownloadManager.h"
#import "BookCD.h"
#import "VolumeCD.h"
#import <FFCircularProgressView.h>

@interface QWDetailDirectoryVolumeTVCell ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet FFCircularProgressView *progressView;
@property (strong, nonatomic) IBOutlet UIImageView *updateImageVIew;

@property (strong, nonatomic) BookVO *book;
@property (strong, nonatomic) VolumeVO *volume;

@end

@implementation QWDetailDirectoryVolumeTVCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.progressView.tintColor = QWPINK;
    self.progressView.tickColor = [UIColor whiteColor];
    self.progressView.enlargeEdge = 20;
    self.progressView.hidden = YES;
//    WEAK_SELF;
//    [self.progressView bk_whenTapped:^{
//        STRONG_SELF;
//        if ([[QWDownloadManager sharedInstance]isDownloadingWithBookId:self.book.nid.stringValue volumeId:self.volume.nid.stringValue]) {
//            [[QWDownloadManager sharedInstance] stopDownloadWithBookId:self.book.nid.stringValue volumeId:self.volume.nid.stringValue];
//        }
//    }];
}

- (IBAction)onPressedFoldBtn:(UIButton *)sender {
    
    self.foldBtn.selected = !self.volume.isFlod;
    [self.delegate volumeCell:self didClickedFoldBtn:sender];
}

- (BOOL)isDownloadedVolumeWithVolume {
    __block NSInteger downloadCount = self.volume.chapter.count;
    [self.volume.chapter enumerateObjectsUsingBlock:^(ChapterVO*  _Nonnull chapter, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([QWFileManager isChapterExitWithBookId:self.book.nid.stringValue volumeId:self.volume.nid.stringValue chapterId:chapter.nid.stringValue]) {
            downloadCount --;
        }
    }];
    if (downloadCount == 0) {
        return true;
    }
    return false;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (!self.book || !self.volume) {
        return;
    }
    
//    self.foldBtn.hidden = editing;
    
    if ([[QWDownloadManager sharedInstance] isDownloadingWithBookId:self.book.nid.stringValue]) {
        self.foldBtn.hidden = true;
    }
    if (editing && [[QWDownloadManager sharedInstance] isDownloadingWithBookId:self.book.nid.stringValue volumeId:self.volume.nid.stringValue]) {
        return;
    }
    else if ([self isDownloadedVolumeWithVolume]){
        self.progressView.hidden = true;
        return;
    }

    [super setEditing:editing animated:animated];
}

- (void)updateWithBookVO:(BookVO *)book volume:(VolumeVO *)volume
{

    self.foldBtn.selected = volume.isFlod;
    
    QWDownloadItem *item = [[QWDownloadManager sharedInstance] getDownloadingItemWithBookId:self.book.nid.stringValue volumeId:self.volume.nid.stringValue];
    [self removeAllObservationsOfObject:item];
    

    self.book = book;
    self.volume = volume;
    self.volume.collection = book.collection;
    self.titleLabel.text = self.volume.title;

//    self.progressView.hidden = ! [self.volume.status isEqualToNumber:@2];

//    [self.progressView stopSpinProgressBackgroundLayer];
//    self.progressView.progress = 0.f;

    self.updateImageVIew.hidden = YES;

    if ([[QWDownloadManager sharedInstance] isDownloadingWithBookId:book.nid.stringValue volumeId:volume.nid.stringValue]) {
        [self.progressView startSpinProgressBackgroundLayer];
        self.progressView.progress = 0.f;
        if (self.isEditing) {
            [super setEditing:NO animated:NO];
        }
    }
    else if ([QWFileManager isVolumeDownloadedWithBookId:book.nid.stringValue volumeId:volume.nid.stringValue update_time:volume.updated_time]) {
        [self.progressView stopSpinProgressBackgroundLayer];
        self.progressView.progress = 1.f;

        if (self.isEditing) {
            [super setEditing:NO animated:NO];
        }
    }
    else {
        if ([QWFileManager isVolumeDownloadedAnyVersionWithBookId:book.nid.stringValue volumeId:volume.nid.stringValue] &&
            ! [QWFileManager isVolumeDownloadedWithBookId:book.nid.stringValue volumeId:volume.nid.stringValue update_time:volume.updated_time]) {
            self.updateImageVIew.hidden = NO;
        }
        else {
            self.updateImageVIew.hidden = YES;
        }

        [self.progressView stopSpinProgressBackgroundLayer];
        self.progressView.progress = 0.f;

        if (self.isEditing) {
            [super setEditing:YES animated:NO];
        }
    }
//    self.progressView.hidden = ![[QWDownloadManager sharedInstance]isDownloadingWithBookId:self.book.nid.stringValue];
    [self updateProgress];
}

- (void)updateProgress
{
    QWDownloadItem *item = [[QWDownloadManager sharedInstance] getDownloadingItemWithBookId:self.book.nid.stringValue volumeId:self.volume.nid.stringValue];
    [self removeAllObservationsOfObject:item];
    if(item) {
        WEAK_SELF;
//        self.progressView.hidden = false;
        if (item.totalCount && item.downloadCount) {
//            [self.progressView stopSpinProgressBackgroundLayer];
//            self.progressView.progress = (CGFloat)item.downloadCount / item.totalCount;
        }

        [self observeObject:item property:@"downloadCount" withBlock:^(__weak id self, __weak id object, id old, id newVal) {
            KVO_STRONG_SELF;
            QWDownloadItem *item = object;
            if (item.downloadCount > 0 && item.totalCount > 0) {
                CGFloat progress = (CGFloat)item.downloadCount / item.totalCount;
                [kvoSelf performInMainThreadBlock:^{
                    STRONG_SELF;
//                    [self.progressView stopSpinProgressBackgroundLayer];
//                    self.progressView.progress = progress;
                }];
            }
        }];

        [self observeObject:item property:@"completed" withBlock:^(__weak id self, __weak id object, id old, id newVal) {
            KVO_STRONG_SELF;
            QWDownloadItem *item = object;
            if (item.isCompleted) {
                [kvoSelf performInMainThreadBlock:^{
                    STRONG_SELF;
//                    [self.progressView stopSpinProgressBackgroundLayer];
//                    self.progressView.progress = 1.f;
                }];
                [kvoSelf removeAllObservationsOfObject:item];
            }
        }];

//        [self observeObject:item property:@"errorCompleted" withBlock:^(__weak id self, __weak id object, id old, id newVal) {
//            KVO_STRONG_SELF;
//            QWDownloadItem *item = object;
//            NSLog(@"%@------errorcompleted",kvoSelf.volume.title);
//            if (item.isErrorCompleted) {
//                [kvoSelf performInMainThreadBlock:^{
//                    STRONG_SELF;
//                    [self.progressView stopSpinProgressBackgroundLayer];
//                    self.progressView.progress = 1.f;
//
//                }];
//                [kvoSelf removeAllObservationsOfObject:item];
//            }
//        }];
    }
}

- (void)dealloc
{
    QWDownloadItem *item = [[QWDownloadManager sharedInstance] getDownloadingItemWithBookId:_book.nid.stringValue volumeId:_volume.nid.stringValue];
    [self removeAllObservationsOfObject:item];
}

@end
