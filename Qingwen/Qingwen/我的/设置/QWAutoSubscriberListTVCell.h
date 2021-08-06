//
//  QWAutoSubscriberListTVCell.h
//  Qingwen
//
//  Created by wei lu on 18/11/17.
//  Copyright © 2017 iQing. All rights reserved.
//

#import "QWBaseTVCell.h"
#import "QWSubscriberBookList.h"
@interface QWAutoSubscriberListTVCell : QWBaseTVCell
@property (strong, nonatomic,readonly) IBOutlet UISwitch *switchView;

- (void)updateWithSuscribeList:(SubscriberBookList *)list;

@end
