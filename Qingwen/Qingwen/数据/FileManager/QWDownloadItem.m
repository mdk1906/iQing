//
//  QWDownloadItem.m
//  Qingwen
//
//  Created by Aimy on 7/16/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWDownloadItem.h"

#import "QWNetworkManager.h"
#import "QWFileManager.h"
#import "BookCD.h"
#import "VolumeCD.h"
#import "QWNetworkManager.h"
#import "QWInterface.h"
#import "QWOperationManager.h"
#import <ZipArchive.h>
#import "QWFileManager.h"

@interface QWDownloadItem ()

@property (nonatomic, copy) NSString *bookId;
@property (nonatomic, copy) NSString *volumeId;
@property (nonatomic, strong) BookVO *book;
@property (nonatomic, strong) VolumeVO *volume;
@property (nonatomic, strong) VolumeCD *volumeCD;
@property (nonatomic, strong) QWOperationManager *operationManager;

@property (nonatomic) int64_t totalCount;//总章节数
@property (nonatomic) int64_t downloadCount;//下载了的章节数
//@property (nonatomic) NSInteger actualTotalCount;//目录中的总章节数

@property (nonatomic) NSInteger errorCount;//错误image的内容

@property (nonatomic, getter=isCompleted) BOOL completed;//完成
@property (nonatomic, getter=isErrorCompleted) BOOL errorCompleted;//完成,但是有内容没有下载下来
@property (nonatomic) BOOL start;//是否开始了

@property (nonatomic, strong, nullable) QWOperationParam *param;//下载参数
@property (nonatomic, strong, nullable) NSURLSessionDownloadTask *task;


@property (nonatomic, strong) NSMutableDictionary *images;//下载了的image数量
@property (nonatomic, strong) NSMutableDictionary *imagesErrorCount;//下载了的错误的image数量
@property (nonatomic, strong) NSMutableDictionary *imagesCount;//需要下载的image总数


@end

@implementation QWDownloadItem

- (QWOperationManager *)operationManager
{
    if (!_operationManager) {
        _operationManager = [[QWNetworkManager sharedInstance] generateoperationManagerWithOwner:self];
        _operationManager.operationQueue.maxConcurrentOperationCount = 1;
    }

    return _operationManager;
}

- (void)configWithBook:(BookVO * __nonnull)book volume:(VolumeVO * __nonnull)volume;
{
    NSAssert(book, @"book 不能为空");
    NSAssert(book.nid, @"bookId 不能为空");
    NSAssert(volume, @"volume 不能为空");
    NSAssert(volume.nid, @"volumeId 不能为空");

    self.start = YES;

    self.bookId = book.nid.stringValue;
    self.volumeId = volume.nid.stringValue;
    self.book = book;
    self.volume = volume;
    
    self.totalCount = volume.chapter.count;
    self.downloadCount = 0;
    self.errorCount = 0;
    
    self.images = @{}.mutableCopy;
    self.imagesErrorCount = @{}.mutableCopy;
    self.imagesCount = @{}.mutableCopy;
    
}

- (void)clearItem
{

    self.start = NO;
    [self.operationManager cancelAllOperations];
    [self removeAllObservationsOfObject:self];

    self.images = nil;
    self.imagesErrorCount = nil;
    self.imagesCount = nil;
    self.totalCount = 0;
    self.downloadCount = 0;
    self.errorCount = 0;
    self.completed = NO;
    self.errorCompleted = NO;
    
}


- (void)dealloc
{
    [self removeAllObservationsOfObject:self.param.progress];

    NSLog(@"[%@ call %@ --> %@]", [self class], NSStringFromSelector(_cmd), self.volume.title);
}

- (void)configComplete
{
    if (self.totalCount <= 0) {
        return ;
    }
    
//    self.downloadCount = self.downloadArray.count;
    NSLog(@"chapter--errorCount--%ld--downloadcount--%lld--totalcount%lld", (long)self.errorCount,self.downloadCount,self.totalCount);
    [[NSNotificationCenter defaultCenter]postNotificationName:@"downloadOver" object:nil];
    if (self.downloadCount+ self.errorCount == self.totalCount) {//能下载的都下载完成了
        if (self.errorCount > 0) {
            self.errorCompleted = true;
        }else {
            self.completed = true;
        }
    }
}

- (void)updateWithChapterId:(NSString * __nonnull)chapterId andImageCount:(NSInteger)imageCount
{
    if (!self.start) {
        return ;
    }
    
    NSAssert(chapterId, @"chapterId 不能为空");
    
    
    if (imageCount == 0) {//如果本章没有图片
        @synchronized (self) {
            self.downloadCount ++;
        }
        [self configComplete];
    }
    else {
        self.imagesCount[chapterId.copy] = @(imageCount);
    }
}

- (void)updateWithErrorWithChapterId:(NSString * __nonnull)chapterId
{
    if (!self.start) {
        return ;
    }
    
    NSAssert(chapterId, @"chapterId 不能为空");
    
    NSLog(@"updateWithError%@--有正文没有下载下来",chapterId);
    @synchronized (self) {
        self.errorCount ++;
    }
    [self configComplete];
}

- (void)updateSubCountWithChapterId:(NSString * __nonnull)chapterId
{
    if (!self.start) {
        return ;
    }
    
    NSAssert(chapterId, @"chapterId 不能为空");
    
    NSNumber *imagesCount = self.imagesCount[chapterId.copy];
    if (!imagesCount) {
        return ;
    }
    
    NSNumber *count = self.images[chapterId.copy];
    
    count = @(count.integerValue + 1);
    self.images[chapterId.copy] = count;
    
    [self updateDownloadCount:chapterId];
}

- (void)updateSubCountErrorWithChapterId:(NSString * __nonnull)chapterId
{
    if (!self.start) {
        return ;
    }
    
    NSAssert(chapterId, @"chapterId 不能为空");
    
    NSNumber *imagesCount = self.imagesCount[chapterId.copy];
    if (!imagesCount) {
        return ;
    }
    
    NSLog(@"%@--有图片没有下载下来",chapterId);
    
    NSNumber *count = self.imagesErrorCount[chapterId.copy];
    
    count = @(count.integerValue + 1);
    self.imagesErrorCount[chapterId.copy] = count;
    
    [self updateDownloadCount:chapterId.copy];

}

- (void)updateDownloadCount:(NSString * __nonnull)chapterId
{
    if (!self.start) {
        return ;
    }
    NSAssert(chapterId, @"chapterId 不能为空");
    
    NSNumber *imagesCount = self.imagesCount[chapterId.copy];
    NSNumber *count = self.images[chapterId.copy];
    NSNumber *imageErrorCount = self.imagesErrorCount[chapterId.copy];
    
    if (count.integerValue + imageErrorCount.integerValue == imagesCount.integerValue) {
        if (!imageErrorCount.integerValue) {
            @synchronized (self) {
                self.downloadCount ++;
            }
        }
        else {
            @synchronized (self) {
                self.errorCount ++;
            }
        }
        
        [self configComplete];
    }
}

@end
