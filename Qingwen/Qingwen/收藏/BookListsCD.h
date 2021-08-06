//
//  BookListsCD.h
//  Qingwen
//
//  Created by wei lu on 1/03/18.
//  Copyright © 2018 iQing. All rights reserved.
//
#import <CoreData/CoreData.h>
NS_ASSUME_NONNULL_BEGIN


@interface BookListsCD : NSManagedObject

@property (nonatomic, copy, nullable) NSNumber *nid;//id
@property (nonatomic, copy, nullable) NSDate *lastViewDate;


- (void)updateWithBookVO:(BookListsCD * _Nonnull)vo;

//
//- (void)setReading;
//- (void)setDownloading;
//- (void)setDeleted;

@end

NS_ASSUME_NONNULL_END
