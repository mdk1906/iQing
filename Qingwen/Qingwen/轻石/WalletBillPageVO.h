//
//  WalletBillPageVO.h
//  Qingwen
//
//  Created by Aimy on 2/28/16.
//  Copyright © 2016 iQing. All rights reserved.
//

#import "PageVO.h"

#import "WalletBillVO.h"

@interface WalletBillPageVO : PageVO

@property (nonatomic, copy) NSArray<WalletBillVO> *results;

@end
