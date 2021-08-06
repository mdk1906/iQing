//
//  QWVoteActivityVO.h
//  Qingwen
//
//  Created by qingwen on 2018/3/14.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QWVoteActivityVO : NSObject
@property (nonatomic,strong)NSString *content;
@property (nonatomic,strong)NSString *img;
- (id)initWithDictionary:(NSDictionary *)dict;
@end
