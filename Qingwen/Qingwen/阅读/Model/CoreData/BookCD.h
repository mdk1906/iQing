//
//  BookCD.h
//  Qingwen
//
//  Created by Aimy on 7/11/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class BookVO;

@interface BookCD : NSManagedObject

@property (nonatomic, copy, nullable) NSNumber *nid;//id
@property (nonatomic, copy, nullable) NSString *url;//url
@property (nonatomic, copy, nullable) NSString *intro;//简介
@property (nonatomic, copy, nullable) NSString *title;//标题
@property (nonatomic, copy, nullable) NSString *cover;//封面
@property (nonatomic, copy, nullable) NSNumber *views;//访问数
@property (nonatomic, copy, nullable) NSNumber *count;//字数
@property (nonatomic, copy, nullable) NSNumber *follow_count;//关注数
@property (nonatomic, copy, nullable) NSDate *updated_time;//更新时间
@property (nonatomic, copy, nullable) NSDate *created_time;//创建时间
@property (nonatomic, copy, nullable) NSString *author_name;//作者
@property (nonatomic, copy, nullable) NSNumber *status;
@property (nonatomic, copy, nullable) NSString *press;//出版
@property (nonatomic, copy, nullable) NSNumber *end;//是否完结
@property (nonatomic, copy, nullable) NSNumber *channel;//10少男，11少女
@property (nonatomic, copy, nullable) NSNumber *coin;
@property (nonatomic, copy, nullable) NSNumber *gold;

@property (nonatomic, copy, nullable) NSString *like_url;//相关url
@property (nonatomic, copy, nullable) NSString *bf_url;
@property (nonatomic, copy, nullable) NSString *share_url;
@property (nonatomic, copy, nullable) NSString *state_url;
@property (nonatomic, copy, nullable) NSString *subscribe_url;
@property (nonatomic, copy, nullable) NSString *unsubscribe_url;

@property (nonatomic, copy, nullable) NSNumber *last_volume_id;//最新卷id
@property (nonatomic, copy, nullable) NSNumber *last_chapter_id;//最新章id
@property (nonatomic, copy, nullable) NSString *last_volume_title;//最新卷名
@property (nonatomic, copy, nullable) NSString *last_chapter_title;//最新章节名
@property (nonatomic, copy, nullable) NSNumber *chapter_count;//章节总数
@property (nonatomic, copy, nullable) NSNumber *volume_count;//卷总数

@property (nonatomic, copy, nullable) NSString *volume_url;//卷url
@property (nonatomic, copy, nullable) NSString *chapter_url;//可以获取所有卷章节的url
@property (nonatomic, copy, nullable) NSString *author_url;//作者url
@property (nonatomic, copy, nullable) NSString *press_url;//出版url
@property (nonatomic, copy, nullable) NSString *last_volume_url;//最新卷url
@property (nonatomic, copy, nullable) NSString *last_chapter_url;//最新章url

@property (nonatomic, copy, nullable) NSNumber *rank;//3-翠星（B签）  4-绯月（A前）


#pragma mark - 客户端字段

@property (nonatomic, copy, nullable) NSNumber *need_pay; //是否付费书籍(1:是, 0:不是, default=0)
@property (nonatomic, copy, nullable) NSNumber *discount; //折扣百分比例(default=100)

@property (nonatomic, copy, nullable) NSDate *lastViewDiscuss;//上次查看讨论时间
@property (nonatomic, copy, nullable) NSDate *lastViewDirectory;//上次查看目录时间
@property (nonatomic, copy, nullable) NSDate *lastViewBookComments;//上次查看目录时间

@property (nonatomic) BOOL attention;//关注
@property (nonatomic, copy, nullable) NSDate *attentionTime;//关注时间

@property (nonatomic) BOOL download;//是否正在下载或者下载完成
@property (nonatomic, copy, nullable) NSDate *lastDownloadTime;//下载开始时间

@property (nonatomic) BOOL read;//阅读
@property (nonatomic, copy, nullable) NSDate *lastReadTime;//最后阅读时间

@property (nonatomic, copy, nullable) NSNumber *volumeIndex NS_DEPRECATED_IOS(6_0, 6_0);//卷index
@property (nonatomic, copy, nullable) NSNumber *chapterIndex NS_DEPRECATED_IOS(6_0, 6_0);//章节index
@property (nonatomic, copy, nullable) NSNumber *location NS_DEPRECATED_IOS(6_0, 6_0);//继续读的章节，需要跳过的字符数
@property (nonatomic, copy, nullable) NSNumber *readingProgress NS_DEPRECATED_IOS(6_0, 6_0);

//game
@property (nonatomic, copy, nullable) NSString *progress;//进度

@property (nonatomic) BOOL game;//是否是演绘
@property (nonatomic, copy, nullable) NSNumber *scene_count;

@property (nonatomic, copy, nullable) NSString *content_url;//游戏url
@property (nonatomic, copy, nullable) NSString *check_url;//是否买了
@property (nonatomic, copy, nullable) NSString *buy_url;//购买url

@property (nonatomic, copy, nullable) NSNumber *cost_price;//原价
@property (nonatomic, copy, nullable) NSNumber *current_price;//折扣价

- (void)updateWithBookVO:(BookVO * _Nonnull)vo;

- (BookVO * _Nonnull)toBookVO;

- (void)setReading;
- (void)setDownloading;
- (void)setDeleted;

@end

NS_ASSUME_NONNULL_END
