//
//  QWCategoryLogic.h
//  Qingwen
//
//  Created by Aimy on 7/4/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBaseLogic.h"

#import "CategoryVO.h"
#import "CategoryDiscussVO.h"

@interface QWCategoryLogic : QWBaseLogic

@property (nonatomic, strong) CategoryVO *categoryVO;
@property (nonatomic, strong) NSArray *discussItems;

- (void)getCategoryWithCompleteBlock:(QWCompletionBlock)aBlock;
- (void)getCategoryDiscussWithCompleteBlock:(QWCompletionBlock)aBlock;

@end
