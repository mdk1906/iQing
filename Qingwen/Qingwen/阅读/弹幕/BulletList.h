//
//  BulletList.h
//  Qingwen
//
//  Created by mumu on 16/12/9.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import "PageVO.h"
#import "BulletVO.h"

@interface BulletList : PageVO

@property (nonatomic, copy) NSArray <BulletVO> *results;

@end
