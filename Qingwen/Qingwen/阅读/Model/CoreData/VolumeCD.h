//
//  VolumeCD.h
//  Qingwen
//
//  Created by Aimy on 9/10/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "VolumeVO.h"

//只用来存储阅读，下载情况
@interface VolumeCD : NSManagedObject

@property (nonatomic, copy) NSNumber *nid;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSNumber *order;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSDate *updated_time;

@property (nonatomic, copy) NSString *chapter_url;
@property (nonatomic, copy) NSNumber *count;
@property (nonatomic, copy) NSString *intro;
@property (nonatomic, copy) NSNumber *status;
@property (nonatomic, copy) NSNumber *type;
@property (nonatomic, copy) NSNumber *views;
@property (nonatomic, copy) NSNumber *end;

@property (nonatomic, copy) NSNumber *bookId;
@property (nonatomic, copy) NSString *bookTitle;

@property (nonatomic) BOOL download;//是否正在下载或者下载完成
@property (nonatomic, copy) NSDate *lastDownloadTime;//下载开始时间
@property (nonatomic, copy) NSNumber *totalUnitCount;//总字节数
@property (nonatomic, copy) NSNumber *completedUnitCount;//已经下载的字节数

@property (nonatomic) BOOL read;//阅读
@property (nonatomic, copy) NSDate *lastReadTime;//最后阅读时间

@property (nonatomic, copy) NSNumber *chapterIndex;//章节index
@property (nonatomic, copy) NSNumber *location;//继续读的章节，需要跳过的字符数

- (void)updateWithVolumeVO:(VolumeVO *)vo bookId:(NSNumber *)bookId;

- (void)setReading;
- (void)setDownloading;
- (void)setDeleted;

- (void)setDownloadTotalUnitCount:(NSNumber *)totalUnitCount andCompletedUnitCount:(NSNumber *)completedUnitCount;

+ (VolumeCD *)findLastReadingVolumeWithBookId:(NSNumber *)bookId;

@end
