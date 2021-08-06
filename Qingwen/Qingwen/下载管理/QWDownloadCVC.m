//
//  QWDownloadCVC.m
//  Qingwen
//
//  Created by Aimy on 9/29/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "BookCD.h"
#import "VolumeCD.h"
#import "QWCollectionView.h"
#import "QWDownloadDirectoryVC.h"
#import "QWFileManager.h"
#import "QWReadingManager.h"

@implementation QWDownloadCVC (qw)

- (void)getData
{
    if (self.loading) {
        return ;
    }

    self.loading = YES;

    WEAK_SELF;
    [self performInThreadBlock:^{
        STRONG_SELF;

        NSMutableArray *volumes = [NSMutableArray array];
        NSArray *tempBooks = [BookCD MR_findByAttribute:@"download" withValue:@YES andOrderBy:@"lastDownloadTime" ascending:NO inContext:[QWFileManager qwContext]];
         tempBooks = [tempBooks sortedArrayUsingComparator:^NSComparisonResult(BookCD  * _Nonnull obj1, BookCD  * _Nonnull obj2) {
            if (obj2.lastReadTime && obj1.lastReadTime) {
                return [obj2.lastReadTime compare:obj1.lastReadTime];
            }
            else {
                return NSOrderedSame;
            }
        }];

        NSMutableArray *books = tempBooks.mutableCopy;
        [tempBooks enumerateObjectsUsingBlock:^(BookCD * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            @autoreleasepool {
                BookCD *bookCD = obj;
                NSArray *tempVolumes = [VolumeCD MR_findAllSortedBy:@"order" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"bookId == %@", bookCD.nid] inContext:[QWFileManager qwContext]];

                NSMutableArray *volumesMin = [NSMutableArray array];//没有下载好的不算
                [tempVolumes enumerateObjectsUsingBlock:^(VolumeCD *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    @autoreleasepool {
                        VolumeVO *volume = [VolumeVO voWithJson:[QWFileManager loadVolumeWithBookId:bookCD.nid.stringValue volumeId:obj.nid.stringValue]];
                        if (volume) {
                            [volumesMin addObject:obj];
                        }
                    }
                }];

                if (tempVolumes.count) {
                    if (volumesMin.count) {
                        [volumes addObject:volumesMin];
                    }
                    else {
                        [books removeObject:bookCD];
                    }
                }
            }
        }];

        PageVO *page = [PageVO new];
        page.results = books;
        page.count = @(books.count);
        self.bookCDs = page;
        self.volumeCDs = volumes;
        
        [self performInMainThreadBlock:^{
            STRONG_SELF;
            [self.collectionView reloadData];
            self.collectionView.emptyView.showError = YES;
            self.loading = NO;
        }];
    }];
}

- (void)didSelectedCellAtIndexPath:(NSIndexPath *)indexPath
{
    BookCD *bookCD = self.bookCDs.results[indexPath.row];

    //开始阅读
    NSArray *volumeCDs = self.volumeCDs[indexPath.row];
    VolumeList *volumeList = [VolumeList new];
    NSMutableArray<VolumeVO *> *volumes = [NSMutableArray array];
    WEAK_SELF;
    [volumeCDs enumerateObjectsUsingBlock:^(VolumeCD *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        STRONG_SELF;
        VolumeVO *volume = [VolumeVO voWithJson:[QWFileManager loadVolumeWithBookId:obj.bookId.stringValue volumeId:obj.nid.stringValue]];
        NSString *json = [QWFileManager loadChapterWithBookId:obj.bookId.stringValue volumeId:obj.nid.stringValue];
        NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding] ?: [NSData data];
        NSArray *chapter = [ChapterVO arrayOfModelsFromData:data error:NULL];
        volume.chapter = (id)chapter;
        if (volume.chapter.count) {
            [volumes addObject:volume];
        }
    }];

    volumeList.results = (id)volumes;

    if (volumeList.results .count == 0) {
        [self showToastWithTitle:@"目录为空" subtitle:nil type:ToastTypeAlert];
        return;
    }

    //设置阅读进度
    {
        VolumeCD *volumeCD = [VolumeCD findLastReadingVolumeWithBookId:bookCD.nid];
        if (!volumeCD) {
            volumeCD = [VolumeCD MR_createEntityInContext:[QWFileManager qwContext]];
            [volumeCD updateWithVolumeVO:volumeList.results.firstObject bookId:bookCD.nid];
            volumeCD.chapterIndex = @0;
            volumeCD.location = @0;
        }

        if ( ! [volumeList.results filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"nid == %@", volumeCD.nid]].firstObject) {
            //未找到阅读记录
            UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"提示" message:@"未找到阅读记录是否从第一卷开始阅读"];

            [alertView bk_addButtonWithTitle:@"否" handler:^{

            }];

            WEAK_SELF;
            [alertView bk_addButtonWithTitle:@"是" handler:^{
                STRONG_SELF;
                VolumeCD *volumeCD = [VolumeCD MR_findFirstOrCreateByAttribute:@"nid" withValue:[volumeList.results.firstObject nid] inContext:[QWFileManager qwContext]];
                [volumeCD updateWithVolumeVO:volumeList.results.firstObject bookId:bookCD.nid];
                volumeCD.chapterIndex = @0;
                volumeCD.location = @0;
                [volumeCD setReading];
                [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];

                [[QWReadingManager sharedInstance] startOfflineReadingWithBookId:bookCD.nid volumes:volumeList];

                QWDownloadDirectoryVC *directoryVC = [self.storyboard instantiateViewControllerWithIdentifier:@"directory"];
                directoryVC.bookId = bookCD.nid;
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"QWReading" bundle:nil];
                UIViewController *vc = [sb instantiateInitialViewController];
                NSMutableArray *vcs = self.navigationController.viewControllers.mutableCopy;
                [vcs addObjectsFromArray:@[directoryVC, vc]];
                [self.navigationController setViewControllers:vcs animated:YES];

            }];
            
            [alertView show];
            
            return ;
        }

        [volumeCD setReading];

        [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];
    }

    [[QWReadingManager sharedInstance] startOfflineReadingWithBookId:bookCD.nid volumes:volumeList];

    QWDownloadDirectoryVC *directoryVC = [self.storyboard instantiateViewControllerWithIdentifier:@"directory"];
    directoryVC.bookId = bookCD.nid;
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"QWReading" bundle:nil];
    UIViewController *vc = [sb instantiateInitialViewController];
    NSMutableArray *vcs = self.navigationController.viewControllers.mutableCopy;
    [vcs addObjectsFromArray:@[directoryVC, vc]];
    [self.navigationController setViewControllers:vcs animated:YES];
    
}

@end
