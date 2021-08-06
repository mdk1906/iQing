//
//  QWDownloadDirectoryVolumeTVCell.m
//  Qingwen
//
//  Created by Aimy on 9/29/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWDownloadDirectoryVolumeTVCell.h"

#import "QWFileManager.h"
#import "QWDownloadManager.h"
#import "BookCD.h"
#import "VolumeCD.h"
#import <FFCircularProgressView.h>

@interface QWDownloadDirectoryVolumeTVCell ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet FFCircularProgressView *progressView;
@property (strong, nonatomic) IBOutlet UIImageView *updateImageVIew;

@property (strong, nonatomic) BookVO *book;
@property (strong, nonatomic) VolumeVO *volume;
@property (strong, nonatomic) VolumeVO *originVolume;

@end

@implementation QWDownloadDirectoryVolumeTVCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.progressView.tintColor = QWPINK;
    self.progressView.tickColor = [UIColor whiteColor];
    self.progressView.enlargeEdge = 20;
//    WEAK_SELF;
//    [self.progressView bk_whenTapped:^{
//        STRONG_SELF;
//        [self onPressedDownloadBtn:self.progressView];
//    }];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    self.progressView.hidden = editing;

    if (!self.book || !self.volume) {
        return;
    }

//    if (editing && [[QWDownloadManager sharedInstance] isDownloadingWithBookId:self.book.nid.stringValue volumeId:self.volume.nid.stringValue]) {
//        return;
//    }

    [super setEditing:editing animated:animated];
}

- (void)updateWithBookVO:(BookVO *)book volume:(VolumeVO *)volume originVolume:(VolumeVO *)originVolume
{
    self.progressView.hidden = self.isEditing;

    QWDownloadItem *item = [[QWDownloadManager sharedInstance] getDownloadingItemWithBookId:self.book.nid.stringValue volumeId:self.volume.nid.stringValue];
    [self removeAllObservationsOfObject:item];

    self.book = book;
    self.volume = volume;
    self.originVolume = originVolume;

    self.titleLabel.text = self.volume.title;

    self.progressView.hidden = ! [self.volume.status isEqualToNumber:@2];

    [self.progressView stopSpinProgressBackgroundLayer];
    self.progressView.progress = 0.f;

    self.updateImageVIew.hidden = YES;

    if ([[QWDownloadManager sharedInstance] isDownloadingWithBookId:book.nid.stringValue volumeId:volume.nid.stringValue]) {
        [self.progressView startSpinProgressBackgroundLayer];
        self.progressView.progress = 0.f;

        if (self.isEditing) {
            [super setEditing:NO animated:NO];
        }
    }
    else if ([QWFileManager isVolumeDownloadedWithBookId:book.nid.stringValue volumeId:volume.nid.stringValue update_time:originVolume.updated_time]) {
        [self.progressView stopSpinProgressBackgroundLayer];
        self.progressView.progress = 1.f;

        if (self.isEditing) {
            [super setEditing:YES animated:NO];
        }
    }
    else {
        if ([QWFileManager isVolumeDownloadedAnyVersionWithBookId:book.nid.stringValue volumeId:volume.nid.stringValue] &&
            ! [QWFileManager isVolumeDownloadedWithBookId:book.nid.stringValue volumeId:volume.nid.stringValue update_time:originVolume.updated_time]) {
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

    [self updateProgress];
}


- (void)updateProgress
{
    QWDownloadItem *item = [[QWDownloadManager sharedInstance] getDownloadingItemWithBookId:self.book.nid.stringValue volumeId:self.volume.nid.stringValue];
    [self removeAllObservationsOfObject:item];

    if(item) {
        WEAK_SELF;
        if (item.totalCount && item.downloadCount) {
            [self.progressView stopSpinProgressBackgroundLayer];
            self.progressView.progress = (CGFloat)item.downloadCount / item.totalCount;
        }

        [self observeObject:item property:@"downloadCount" withBlock:^(__weak id self, __weak id object, id old, id newVal) {
            KVO_STRONG_SELF;
            QWDownloadItem *item = object;
            if (item.totalCount && item.downloadCount) {
                CGFloat progress = (CGFloat)item.downloadCount / item.totalCount;
                [kvoSelf performInMainThreadBlock:^{
                    STRONG_SELF;
                    [self.progressView stopSpinProgressBackgroundLayer];
                    self.progressView.progress = progress;
                }];
            }
        }];

        [self observeObject:item property:@"completed" withBlock:^(__weak id self, __weak id object, id old, id newVal) {
            KVO_STRONG_SELF;
            QWDownloadItem *item = object;
            if (item.isCompleted) {
                [kvoSelf performInMainThreadBlock:^{
                    STRONG_SELF;
                    [self.progressView stopSpinProgressBackgroundLayer];
                    self.progressView.progress = 1.f;
                }];
                [kvoSelf removeAllObservationsOfObject:item];
            }
        }];

        [self observeObject:item property:@"errorCompleted" withBlock:^(__weak id self, __weak id object, id old, id newVal) {
            KVO_STRONG_SELF;
            QWDownloadItem *item = object;
            if (item.isErrorCompleted) {
                [kvoSelf performInMainThreadBlock:^{
                    STRONG_SELF;
                    [self.progressView stopSpinProgressBackgroundLayer];
                    self.progressView.progress = 1.f;
                }];
                
                [kvoSelf removeAllObservationsOfObject:item];
            }
        }];
    }
}

- (void)dealloc
{
    QWDownloadItem *item = [[QWDownloadManager sharedInstance] getDownloadingItemWithBookId:_book.nid.stringValue volumeId:_volume.nid.stringValue];
    [self removeAllObservationsOfObject:item];
}

@end
