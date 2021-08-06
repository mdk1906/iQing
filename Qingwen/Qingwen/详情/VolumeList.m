//
//  VolumeList.m
//  Qingwen
//
//  Created by Aimy on 9/9/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "VolumeList.h"

#import "QWFileManager.h"

@implementation VolumeList

@dynamic results;

- (void)configDirectory
{
    [self.results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        VolumeVO *volume = obj;
        NSInteger volumeIndex = idx;
        [volume.chapter enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ChapterVO *chapter = obj;
            chapter.volumeTitle = volume.title;
            chapter.volumeId = volume.nid;
            chapter.volumeIndex = volumeIndex;
            chapter.chapterIndex = idx;
            chapter.collection = volume.collection;
        }];
    }];
}

- (void)configOfflineDirectoryWithBookId:(NSString *)bookId
{
    NSMutableArray *volumes = self.results.mutableCopy;
    [self.results makeObjectsPerformSelector:NSSelectorFromString(@"configOfflineVolumeWithBookId:") withObject:bookId];

    [self.results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        VolumeVO *volume = obj;
        if (!volume.chapter.count) {
            [volumes removeObject:volume];//删除没有任何章节的卷
        }
    }];

    self.results = volumes.copy;

    [self configDirectory];
}

- (VolumeVO *)getVolumeWithId:(NSNumber *)volumeId
{
    VolumeVO *volume = [self.results filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"nid == %@", volumeId]].firstObject;
    return volume ?: self.results.firstObject;
}

- (BookPageVO *)getNextPageWithPage:(BookPageVO *)page
{
    VolumeVO *volume = [self getVolumeWithId:page.volumeId];
    ChapterVO *chapter = volume.chapter[page.chapterIndex];

    BookPageVO *nextPage = page.copy;
    if (nextPage.pageIndex + 1 < chapter.pageCount) {
//        NSLog(@"下一页");
        nextPage = chapter.bookPages[@(page.pageIndex + 1)];
    }
    else if (nextPage.chapterIndex + 1 < volume.chapter.count) {
//        NSLog(@"下一章");
        nextPage.chapterIndex++;
        nextPage.pageIndex = 0;
        nextPage.range = NSMakeRange(0, 0);
        chapter = volume.chapter[nextPage.chapterIndex];
    }
    else if (volume != self.results.lastObject) {
//        NSLog(@"下一卷");
        VolumeVO *nextVolume = self.results[[self.results indexOfObject:volume] + 1];
        nextPage.volumeId = nextVolume.nid;
        nextPage.chapterIndex = 0;
        nextPage.pageIndex = 0;
        nextPage.range = NSMakeRange(0, 0);
        chapter = nextVolume.chapter[nextPage.chapterIndex];
    }
    else {
        NSLog(@"没有下一页了");
        return nil;
    }

    return nextPage;
}

- (BookPageVO *)getPreviousPageWithPage:(BookPageVO *)page
{
    VolumeVO *volume = [self getVolumeWithId:page.volumeId];
    ChapterVO *chapter = volume.chapter[page.chapterIndex];

    BookPageVO *previousPage = page.copy;

    if (previousPage.pageIndex > 0) {
//        NSLog(@"上一页");
        previousPage = chapter.bookPages[@(page.pageIndex - 1)];
    }
    else if (previousPage.chapterIndex > 0) {
//        NSLog(@"上一章最后一页");
        previousPage.chapterIndex--;//上一章
        chapter = volume.chapter[previousPage.chapterIndex];
        previousPage.pageIndex = chapter.pageCount - 1;//最后一页
        previousPage.range = NSMakeRange(NSNotFound, 0);
    }
    else if (volume != self.results.firstObject) {
//        NSLog(@"上一卷最后一章最后一页");
        VolumeVO *previousVolume = self.results[[self.results indexOfObject:volume] - 1];
        previousPage.volumeId = previousVolume.nid;
        previousPage.chapterIndex = previousVolume.chapter.count - 1;
        chapter = previousVolume.chapter[previousPage.chapterIndex];
        previousPage.pageIndex = chapter.pageCount - 1;//最后一页
        previousPage.range = NSMakeRange(NSNotFound, 0);
    }
    else {
        NSLog(@"没有上一页了");
        return nil;
    }

    return previousPage;
}

@end
