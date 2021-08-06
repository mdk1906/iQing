//
//  QWVIPSectionTableViewCell.h
//  Qingwen
//
//  Created by qingwen on 2018/10/17.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QWVIPSectionVO.h"
#import "BookVO.h"
@interface QWVIPSectionTableViewCell : UITableViewCell
@property (nonatomic,strong)BookVO *model;
@end
