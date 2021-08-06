//
//  ChapterVO.h
//  Qingwen
//
//  Created by Aimy on 7/6/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWValueObject.h"

#import "ContentVO.h"
#import "BookPageVO.h"
#import "QWReadingConfig.h"
#import <CoreText/CoreText.h>

typedef NS_ENUM(NSUInteger, QWChapterType) {
    QWChapterTypeDraft = 0,//草稿
    QWChapterTypeApprove = 2,//审核通过
    QWChapterTypeInReview = 3,//审核中
    QWChapterTypeUnReview = 4, //未通过
    QWChapterTypeReject = 7,//退回
    QWChapterTypeAIReview = 8,//AI审核
};

@protocol ChapterVO <NSObject>

@end

@interface ChapterVO : QWValueObject

@property (nonatomic, copy, nullable) NSDate *release_time;

@property (nonatomic, copy, nullable) NSNumber *count;
@property (nonatomic, copy, nullable) NSNumber *content_update_url;
@property (nonatomic, copy, nullable) NSString *volume_url;

@property (nonatomic, copy, nullable) NSNumber *book;
@property (nonatomic, copy, nullable) NSNumber *nid;
@property (nonatomic, copy, nullable) NSNumber *order;
@property (nonatomic, copy, nullable) NSString *url;
@property (nonatomic, copy, nullable) NSString *volume;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSDate *updated_time;
@property (nonatomic, copy, nullable) NSString *content_url;
@property (nonatomic,copy,nullable ) NSString *whisper;
@property (nonatomic, strong, nullable) ContentVO *contentVO;
@property (nonatomic, strong, nullable) ContentVO *originalContentVO;
@property (nonatomic) QWChapterType status;//状态 (0, '草稿')|(3, "审核中")|(4, "未通过")|(6, "已通过")|(7, "被退回")
@property (nonatomic,copy,nullable ) NSString *ai_time;//AI审核时间
@property (nonatomic,copy,nullable ) NSString *human_time;//人工审核时间
//客户端字段方法
@property (nonatomic) QWReadingBG readingBG;
@property (nonatomic) NSInteger fontSize;
@property (nonatomic) BOOL traditional;
@property (nonatomic) BOOL originalFont;
@property (nonatomic) BOOL landscape;
@property (nonatomic) BOOL showDanmu;

@property (nonatomic, copy, nullable) NSString *volumeTitle;
@property (nonatomic, copy, nullable) NSNumber *volumeId;
@property (nonatomic) NSInteger volumeIndex;
@property (nonatomic) NSInteger chapterIndex;

@property (nonatomic, copy, nullable) NSMutableAttributedString *attributedString;//全量字符串
@property (nonatomic, readonly, nullable) CTFramesetterRef framesetter;//排版
@property (nonatomic, strong, nullable) NSMutableDictionary<NSNumber *, BookPageVO *> *bookPages;//按照页来存储的数据

@property (nonatomic) NSInteger pageCount;
@property (nonatomic, getter=isCompleted) BOOL completed;//是否初始化完成

//3.2.0新增
@property (nonatomic, copy, nullable) NSNumber *type; //0:设定章, 1:正文-免费章节, 2:正文-付费章节
@property (nonatomic, copy, nullable) NSNumber *amount; //花费金额
@property (nonatomic, copy, nullable) NSString *points;//信仰
@property (nonatomic, copy, nullable) NSNumber *can_use_voucher;
//取消购书券
@property (nonatomic, copy, nullable) NSNumber *amount_coin; //轻石
@property (nonatomic, copy, nullable) NSString *battle;//战力

@property (nonatomic, copy, nullable) NSNumber *buy_type;//0是按章 1是按卷
@property (nonatomic, copy, nullable) NSNumber *volume_amount_coin;//轻石
@property (nonatomic, copy, nullable) NSNumber *volume_battle;//战力
@property (nonatomic, copy, nullable) NSNumber *volume_chapter_count;
@property (nonatomic, copy, nullable) NSNumber *volume_count;
@property (nonatomic, copy, nullable) NSNumber *volume_id;
@property (nonatomic, copy, nullable) NSNumber *volume_need_amount;//重石
@property (nonatomic, copy, nullable) NSNumber *volume_points;//信仰
@property (nonatomic,copy,nullable) NSNumber *collection;//是否收藏
@property (nonatomic) BOOL subscriber;  //订阅是1, 没有订阅是0
@property (nonatomic) BOOL editWhisper;//是否只修改作者的话
@property (nonatomic, copy, nullable) NSNumber *ad_free; //1=有广告 0是没广告
@property (nonatomic, copy, nullable) NSNumber *ad_type; //1是图片广告 0是视频广告
@property (nonatomic, copy, nullable) NSNumber *insert_ad; //1是有插图广告 0是没插图广告
@property (nonatomic, copy, nullable) NSNumber *insert_page; //第几页显示插图广告
@property (nonatomic, copy, nullable) NSNumber *free_chapter;//0是免费章节 1是付费章节
@property (nonatomic, copy, nullable) NSNumber *book_Id;
@property (nonatomic, copy, nullable) NSNumber *lastPageAd;//最后一页是否有广告 0广点通广告 1自定义广告 2关闭广告
@property (nonatomic) BOOL bookadready;//广告是否准备好
@property (nonatomic) BOOL isloading;//章节是否准备好
- (void)configChapter;
- (void)clearChapter;
-(void)insertAdView;
@end
