//
//  BooksListVO.h
//  Qingwen
//
//  Created by wei lu on 30/12/17.
//  Copyright © 2017 iQing. All rights reserved.
//

#import "QWValueObject.h"
#import "BookVO.h"
@protocol BooksListVO <NSObject>

@end

NS_ASSUME_NONNULL_BEGIN

@interface BooksListVO : QWValueObject
@property (nonatomic, copy, nullable) NSNumber *nid;
@property (nonatomic, copy, nullable) NSString *url;
@property (nonatomic, assign) QWReadingType work_type;
@property (nonatomic, copy, nullable) NSNumber *work_id;
@property (nonatomic, copy, nullable) NSString *recommend;
@property (nonatomic, copy, nullable) BookVO *work;
@end
NS_ASSUME_NONNULL_END
