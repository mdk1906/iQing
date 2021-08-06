//
//  ActivityVO.h
//  Qingwen
//
//  Created by mumu on 2017/4/24.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWValueObject.h"

@protocol ActivityVO <NSObject>

@end

NS_ASSUME_NONNULL_BEGIN
@interface ActivityVO : QWValueObject

@property (nonatomic, copy, nullable) NSNumber *nid;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *cover;
@property (nonatomic, copy, nullable) NSNumber *order;
@property (nonatomic, copy, nullable) NSDate * started_time;
@property (nonatomic, copy, nullable) NSDate * ended_time;
@property (nonatomic, copy, nullable) NSString *bf_url; //讨论区URL
@property (nonatomic, copy, nullable) NSString *eve_url; //网址URL
@property (nonatomic, copy, nullable) NSString *url;    //作品url
@property (nonatomic, copy, nullable) NSNumber *work_count;
@property (nonatomic, copy, nullable) NSNumber *bf_count;

@property (nonatomic, copy, nullable) NSNumber *bf_enable; // 1:显示 0:隐藏
@property (nonatomic, copy, nullable) NSNumber *works_display; // 1:显示 0:隐藏
@property (nonatomic, copy, nullable) NSNumber *submit_enable; // 1:显示 0:隐藏
@property (nonatomic, copy, nullable) NSNumber *status; //0:已结束 1:正在进行中 2:正在准备中
@end
NS_ASSUME_NONNULL_END
