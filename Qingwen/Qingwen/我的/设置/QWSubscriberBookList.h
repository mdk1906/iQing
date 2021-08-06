//
//  QWSubscriberBookList.h
//  Qingwen
//
//  Created by wei lu on 20/11/17.
//  Copyright © 2017 iQing. All rights reserved.
//

#import "PageVO.h"
#import "QWSubscriberBooks.h"
@interface SubscriberBookList : PageVO

@property (nonatomic, copy) NSArray<SubscriberBooks> *results;

@end

