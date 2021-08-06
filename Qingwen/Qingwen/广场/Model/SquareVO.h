//
//  SquareVO.h
//  Qingwen
//
//  Created by mumu on 17/3/24.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWValueObject.h"
#import "QWGeneralCellConfigure.h"
#import "StoneRankVO.h"
NS_ASSUME_NONNULL_BEGIN

@protocol SquareVO <NSObject>

@end

@interface SquareVO : QWValueObject<QWGeneralCellConfigure>

@property (nonatomic, copy, nullable) NSNumber *reply;
@property (nonatomic, copy, nullable) NSNumber *rank;
@property (nonatomic, copy, nullable) BookVO * detail;

@end
NS_ASSUME_NONNULL_END
