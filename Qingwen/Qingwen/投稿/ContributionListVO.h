//
//  ContributionListVO.h
//  Qingwen
//
//  Created by Aimy on 10/29/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "ContributionVO.h"

@interface ContributionListVO : PageVO

@property (nonatomic, copy) NSArray<ContributionVO> *results;

@end
 
