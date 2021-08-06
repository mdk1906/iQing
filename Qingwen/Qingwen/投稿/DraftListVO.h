//
//  DraftListVO.h
//  Qingwen
//
//  Created by Aimy on 4/26/16.
//  Copyright © 2016 iQing. All rights reserved.
//

#import "PageVO.h"

#import "ChapterVO.h"

@interface DraftListVO : PageVO

@property (nonatomic, copy) NSArray<ChapterVO> *results;

@end
