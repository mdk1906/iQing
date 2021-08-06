//
//  BestItemVO.h
//  Qingwen
//
//  Created by Aimy on 7/4/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWValueObject.h"
#import "QWBaseLogic.h"

#import "ListVO.h"
#import "BookVO.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BestItemVO <NSObject>

@end

@interface BestItemVO : QWValueObject

@property (nonatomic, copy, nullable) NSNumber *nid;
@property (nonatomic, copy, nullable) NSString *url;
@property (nonatomic, copy, nullable) NSNumber *type;
@property (nonatomic, copy, nullable) NSNumber *status;
@property (nonatomic, copy, nullable) NSString *cover;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *href;

@property (nonatomic, copy, nullable) BookVO *work;
@property (nonatomic, copy, nullable) NSString *recommend_words;
@property (nonatomic, assign) QWReadingType work_type;

- (ListVO *)toListVO;

@end

NS_ASSUME_NONNULL_END
