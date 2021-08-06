//
//  QWVoteInfo.h
//  Qingwen
//
//  Created by qingwen on 2018/3/14.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QWVoteInfo : NSObject
@property (nonatomic,strong)NSString *author;
@property (nonatomic,strong)NSString *content;
@property (nonatomic,strong)NSNumber *gold;
@property (nonatomic,strong)NSNumber *id;
@property (nonatomic,strong)NSNumber *can_poll_score;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSNumber *rank;
@property (nonatomic,strong)NSNumber *score;
@property (nonatomic,strong)NSString *poll_url;
@property (nonatomic,strong)NSString *balance_info;
- (id)initWithDictionary:(NSDictionary *)dict;
@end
