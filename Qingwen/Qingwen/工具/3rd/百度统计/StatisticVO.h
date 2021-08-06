//
//  StatisticVO.h
//  Qingwen
//
//  Created by Aimy on 8/15/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWValueObject.h"

@interface StatisticVO : QWValueObject

@property (nonatomic, copy) NSString *bookId;

@property (nonatomic, copy) NSString *volumeId;

@property (nonatomic, copy) NSString *chapterId;

@property (nonatomic, copy) NSString *contentUrl;

@property (nonatomic, copy) NSString *contentItemId;

@property (nonatomic, copy) NSString *type;

@property (nonatomic, copy) NSString *imageUrl;

@end
