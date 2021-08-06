//
//  StoneRankVO.h
//  Qingwen
//
//  Created by qingwen on 2018/4/20.
//  Copyright © 2018年 iQing. All rights reserved.
//


#import "QWValueObject.h"

@protocol StoneRankVO <NSObject>

@end

@interface StoneRankVO : QWValueObject

@property (nonatomic, nullable, copy) NSArray *imagesURLStrings;
@property (nonatomic, nullable, copy) NSArray *userNameArr;
@property (nonatomic, nullable, copy) NSArray *contentArr;
@property (nonatomic, nullable, copy) NSArray *bookIdArr;
@property (nonatomic, nullable, copy) NSArray *stoneArr;

@end
