//
//  VolumeVO.m
//  Qingwen
//
//  Created by Aimy on 7/6/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "VolumeVO.h"

#import "QWFileManager.h"

@implementation VolumeVO

- (void)configOfflineVolumeWithBookId:(NSString *)bookId
{
    NSString *json = [QWFileManager loadChapterWithBookId:bookId volumeId:self.nid.stringValue];
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding] ?: [NSData data];
    NSArray *chapter = [ChapterVO arrayOfModelsFromData:data error:NULL];
    self.chapter = (id)chapter;

    WEAK_SELF;
    [self.chapter enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        STRONG_SELF;
        ChapterVO *chapter = obj;
        chapter.volumeTitle = self.title;
        chapter.volumeId = self.nid;
        chapter.chapterIndex = idx;
    }];
}

@end
