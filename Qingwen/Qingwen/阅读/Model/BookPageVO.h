//
//  BookPageVO.h
//  Qingwen
//
//  Created by Aimy on 7/7/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookPageVO : NSObject <NSCopying>

@property (nonatomic, copy) NSNumber *volumeId;
@property (nonatomic) NSInteger chapterIndex;
@property (nonatomic) NSInteger pageIndex;
@property (nonatomic) NSRange   range;

@end
