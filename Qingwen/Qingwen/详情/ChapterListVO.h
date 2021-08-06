//
//  ChapterListVO.h
//  Qingwen
//
//  Created by mumu on 2017/9/7.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "PageVO.h"
#import "ChapterVO.h"

@interface ChapterListVO : PageVO

@property (nonatomic, copy) NSArray <ChapterVO> *results;

@end
