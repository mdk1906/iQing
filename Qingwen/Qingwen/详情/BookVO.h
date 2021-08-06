//
//  BookVO.h
//  Qingwen
//
//  Created by Aimy on 7/6/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWValueObject.h"

#import "CategoryItemVO.h"
#import "UserVO.h"
#import "QWGeneralCellConfigure.h"
#import "ActivityVO.h"
#import "FavoriteBooksList.h"

typedef NS_ENUM(NSUInteger, QWBookType) {
    QWBookTypeDraft = 0,//草稿
    QWBookTypeApprove = 6,//审核通过
    QWBookTypeInReview = 3,//审核中
    QWBookTypeUnReview = 4,//未通过
    QWBookTypePartReview = 2, //部分通过
    QWBookTypeReject = 7,//退回
    //    QWBookTypeUpdate = 4,//有更新(后台),对客户端 则为 审核通过
};

@protocol BookVO <NSObject>

@end

@interface BookVO : QWValueObject <QWBookTVCellCogig>

@property (nonatomic, copy, nullable) NSArray<UserVO> *author;
@property (nonatomic, copy, nullable) NSNumber *nid;
@property (nonatomic, copy, nullable) NSString *url;
@property (nonatomic, copy, nullable) NSString *intro;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *cover;
@property (nonatomic, copy, nullable) NSNumber *views;
@property (nonatomic, copy, nullable) NSNumber *count;
@property (nonatomic, copy, nullable) NSNumber *follow_count;
@property (nonatomic, copy, nullable) NSDate *updated_time;
@property (nonatomic, copy, nullable) NSDate *created_time;
@property (nonatomic, copy, nullable) NSString *author_name;
//@property (nonatomic, copy, nullable) NSNumber *status;
@property (nonatomic, assign) QWBookType status;
@property (nonatomic, copy, nullable) NSString *press;
@property (nonatomic, copy, nullable) NSArray *uploaders;
@property (nonatomic, copy, nullable) NSArray<CategoryItemVO> *categories;
@property (nonatomic, copy, nullable) NSNumber *end;
@property (nonatomic, copy, nullable) NSNumber *channel;//10少女，11少男
@property (nonatomic, copy, nullable) NSNumber *coin;
@property (nonatomic, copy, nullable) NSNumber *gold;

@property (nonatomic, copy, nullable) NSString *like_url;
@property (nonatomic, copy, nullable) NSString *bf_url;
@property (nonatomic, copy, nullable) NSString *share_url;
@property (nonatomic, copy, nullable) NSString *state_url;
@property (nonatomic, copy, nullable) NSString *subscribe_url;
@property (nonatomic, copy, nullable) NSString *unsubscribe_url;

@property (nonatomic, copy, nullable) NSNumber *last_volume_id;
@property (nonatomic, copy, nullable) NSNumber *last_chapter_id;
@property (nonatomic, copy, nullable) NSString *last_chapter_title;
@property (nonatomic, copy, nullable) NSString *last_volume_title;
@property (nonatomic, copy, nullable) NSNumber *chapter_count;//章节总数
@property (nonatomic, copy, nullable) NSNumber *volume_count;//卷总数

@property (nonatomic, copy, nullable) NSString *volume_url;
@property (nonatomic, copy, nullable) NSString *chapter_url;//可以获取所有卷章节的url
@property (nonatomic, copy, nullable) NSString *author_url;
@property (nonatomic, copy, nullable) NSString *press_url;
@property (nonatomic, copy, nullable) NSString *last_volume_url;
@property (nonatomic, copy, nullable) NSString *last_chapter_url;

@property (nonatomic, copy, nullable) NSNumber *rank;//3-翠星（B签）  4-绯月（A前）

//game
@property (nonatomic) BOOL game;//是否是演绘
@property (nonatomic, copy, nullable) NSNumber *scene_count;

@property (nonatomic, copy, nullable) NSString *content_url;//游戏url
@property (nonatomic, copy, nullable) NSString *check_url;//是否买了
@property (nonatomic, copy, nullable) NSString *buy_url;//购买url

@property (nonatomic, copy, nullable) NSNumber *cost_price;//原价
@property (nonatomic, copy, nullable) NSNumber *current_price;//折扣价


//3.2.0
@property (nonatomic, copy, nullable) NSNumber *need_pay; //3.2.0 是否付费书籍
@property (nonatomic, copy, nullable) NSNumber *discount; //3.2.0 折扣百分比例

//3.6.0
@property (nonatomic, copy, nullable) NSNumber *belief; //信仰值
@property (nonatomic, copy, nullable) NSNumber *combat; //战力值

//3.9.0
@property (nonatomic, copy, nullable) NSArray <ActivityVO> *activity;

@property (nonatomic, copy, nullable) NSString *cornerImage; //客户端返回书的一个属性

@property (nonatomic,copy,nullable) NSDictionary *extra;//是否参与投票

@property (nonatomic,copy,nullable) NSString *vote;//投票id

@property (nonatomic,copy,nullable) NSNumber *collection;//收藏
@property (nonatomic,copy,nullable) NSString *vip_mark;//书籍增加VIP标签URL不是VIP返回一个空白图片
@property (nonatomic,copy,nullable) NSString *is_vip;//TRUE FALSE
- (UIImage * _Nullable)topRightCornerImage;
- (NSString * _Nullable)topRightCornerTitle;
-(UIImage *)vipImg;
@end
