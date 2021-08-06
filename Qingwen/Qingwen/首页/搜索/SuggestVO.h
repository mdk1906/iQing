//
//  SuggestVO.h
//  Qingwen
//
//  Created by mumu on 2017/7/27.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWValueObject.h"

@protocol SuggestVO <NSObject>


@end

NS_ASSUME_NONNULL_BEGIN

@interface SuggestVO: QWValueObject

@property (nonatomic, copy, nullable) NSString *suggestion;

@end

NS_ASSUME_NONNULL_END
