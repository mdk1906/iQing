//
//  QWSubscriberBooks.h
//  Qingwen
//
//  Created by wei lu on 20/11/17.
//  Copyright © 2017 iQing. All rights reserved.
//

#import "QWValueObject.h"

NS_ASSUME_NONNULL_BEGIN

@protocol  SubscriberBooks<NSObject>

@end

@interface SubscriberBooks : QWValueObject

@property (nonatomic, copy, nullable) NSNumber *book;
@property (nonatomic, copy, nullable) NSNumber *user;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSDate *created_time;
@property (nonatomic, copy, nullable) NSNumber *toggle;
@end

NS_ASSUME_NONNULL_END
