//
//  QWMyMissionTableViewCell.h
//  Qingwen
//
//  Created by qingwen on 2018/9/4.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyMissionVO.h"
@interface QWMyMissionTableViewCell : UITableViewCell
@property (strong , nonatomic) MyMissionVO *model;
-(void)createProgress;
//-(void)setModel:(MyWalletVO *)model;
@end
