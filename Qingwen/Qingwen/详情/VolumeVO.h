//
//  VolumeVO.h
//  Qingwen
//
//  Created by Aimy on 7/6/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWValueObject.h"

#import "BookVO.h"
#import "ChapterVO.h"
#import "UserVO.h"

NS_ASSUME_NONNULL_BEGIN

@protocol VolumeVO <NSObject>

@end

@interface VolumeVO : QWValueObject

@property (nonatomic, copy, nullable) NSArray<UserVO> *author;

@property (nonatomic, copy, nullable) NSNumber *nid;
@property (nonatomic, copy, nullable) NSString *url;
@property (nonatomic, copy, nullable) NSNumber *order;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSDate *updated_time;
@property (nonatomic, copy, nullable) NSArray<ChapterVO> *chapter;

@property (nonatomic, copy, nullable) NSString *bookTitle;
@property (nonatomic, strong, nullable) BookVO *book;

@property (nonatomic, copy, nullable) NSString *chapter_url;
@property (nonatomic, copy, nullable) NSNumber *count;
@property (nonatomic, copy, nullable) NSString *intro;
@property (nonatomic, copy, nullable) NSNumber *status;
@property (nonatomic, copy, nullable) NSNumber *type;
@property (nonatomic, copy, nullable) NSNumber *views;
@property (nonatomic, copy, nullable) NSNumber *end;

@property (nonatomic, copy, nullable) NSString *download_url;
@property (nonatomic, copy, nullable) NSNumber *chapter_count;

//客户端字段
@property (assign) BOOL isFlod; //是否折叠Chapter
@property (assign) BOOL isSelect;//是否选中volume
@property (assign) BOOL isFirst; //是否第一次点击eidt按钮
@property (nonatomic, copy, nullable) NSNumber *collection;
@end

NS_ASSUME_NONNULL_END
