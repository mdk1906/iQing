//
//  VolumeCD.m
//  Qingwen
//
//  Created by Aimy on 9/10/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "VolumeCD.h"

#import "BookCD.h"

@implementation VolumeCD

@dynamic nid, url, order, title, updated_time, bookTitle, chapter_url, count, intro, status, type, views, end, download, lastDownloadTime, read, chapterIndex, location, bookId, lastReadTime, totalUnitCount, completedUnitCount;

- (void)updateWithVolumeVO:(VolumeVO *)vo bookId:(NSNumber *)bookId
{
    self.bookId = bookId;

    self.nid = vo.nid;
    self.url = vo.url;
    self.order = vo.order;
    self.title = vo.title;
    self.updated_time = vo.updated_time;
    self.bookTitle = vo.bookTitle;
    self.chapter_url = vo.chapter_url;
    self.count = vo.count;
    self.intro = vo.intro;
    self.status = vo.status;
    self.type = vo.type;
    self.views = vo.views;
    self.end = vo.end;
}

- (void)setReading
{
    self.read = YES;
    self.lastReadTime = [NSDate date];
    BookCD *bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == NO", self.bookId] inContext:[QWFileManager qwContext]];
    [bookCD setReading];
}

- (void)setDownloading
{
    self.download = YES;
    self.lastDownloadTime = [NSDate date];
    BookCD *bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == NO", self.bookId] inContext:[QWFileManager qwContext]];
    [bookCD setDownloading];
}

- (void)setDeleted
{
    self.download = NO;
    self.lastDownloadTime = nil;
    self.totalUnitCount = nil;
    self.completedUnitCount = nil;
    
    VolumeCD *one = [VolumeCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"download == %@ AND bookId == %@", @YES, self.bookId] inContext:[QWFileManager qwContext]];
    if ( ! one) {
        BookCD *bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == NO", self.bookId] inContext:[QWFileManager qwContext]];
        bookCD.download = NO;
        bookCD.lastDownloadTime = nil;
    }
}

- (void)setDownloadTotalUnitCount:(NSNumber *)totalUnitCount andCompletedUnitCount:(NSNumber *)completedUnitCount
{
    self.totalUnitCount = totalUnitCount;
    self.completedUnitCount = completedUnitCount;
    if (self.totalUnitCount && self.totalUnitCount == self.completedUnitCount) {
        self.totalUnitCount = nil;
        self.completedUnitCount = nil;
    }
}

+ (VolumeCD *)findLastReadingVolumeWithBookId:(NSNumber *)bookId
{
    return [VolumeCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"bookId == %@ AND read == 1", bookId] sortedBy:@"lastReadTime" ascending:NO inContext:[QWFileManager qwContext]];
}

@end
