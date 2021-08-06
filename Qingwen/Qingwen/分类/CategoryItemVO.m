//
//  CategoryItemVO.m
//  Qingwen
//
//  Created by Aimy on 7/4/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "CategoryItemVO.h"

@implementation CategoryItemVO

- (void)toList
{
    CategoryItemVO *vo = self;
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"book_url"] = vo.book_url;
    params[@"title"] = vo.name;
    [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"list" andParams:params]];
}

- (BOOL)isEqual:(id)object
{
    CategoryItemVO *item = object;
    return [self.nid isEqualToNumber:item.nid];
}

@end
