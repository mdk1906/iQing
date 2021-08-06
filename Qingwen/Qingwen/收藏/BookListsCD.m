//
//  BookListsCD.m
//  Qingwen
//
//  Created by wei lu on 1/03/18.
//  Copyright © 2018 iQing. All rights reserved.
//

#import "BookListsCD.h"
@implementation BookListsCD
@dynamic nid,lastViewDate;

- (void)updateWithBookVO:(BookListsCD *)vo
{
    self.nid = vo.nid;
    self.lastViewDate = vo.lastViewDate;
    
}
@end

