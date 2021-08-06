//
//  FavoriteBooksVO.h
//  Qingwen
//
//  Created by wei lu on 11/12/17.
//  Copyright © 2017 iQing. All rights reserved.
//

#import "QWValueObject.h"
#import "UserVO.h"
@protocol FavoriteBooksVO <NSObject>

@end

NS_ASSUME_NONNULL_BEGIN

@interface FavoriteBooksVO : QWValueObject


@property (nonatomic, copy, nullable) NSNumber *nid;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *intro;
@property (nonatomic, copy, nullable) NSArray <NSString *> *cover;
@property (nonatomic, copy, nullable) NSNumber *work_count;

@property (nonatomic, copy, nullable) NSString *recommend_words;
@property (nonatomic, copy, nullable) UserVO *user;
@property (nonatomic, copy, nullable) NSNumber *own;//true为本人书单false为他人书单
@property (nonatomic, copy, nullable) NSNumber *can_add;//true为本人书单false为他人书单
@property (nonatomic, copy, nullable) NSNumber *subscribe;//true为本人书单false为他人书单
@property (nonatomic, copy, nullable) NSString *bf_url;
@property (nonatomic, copy, nullable) NSNumber *belief;
@property (nonatomic, copy, nullable) NSNumber *combat;
@property (nonatomic, copy, nullable) NSNumber *views;
@property (nonatomic, copy, nullable) NSNumber *bf_count;
@property (nonatomic, copy, nullable) NSDate *last_post;
@end

NS_ASSUME_NONNULL_END
