//
//  FriendItemVO.h
//  Qingwen
//
//  Created by Aimy on 8/24/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWValueObject.h"

#import "UserVO.h"

@protocol FriendItemVO <NSObject>

@end

@interface FriendItemVO : QWValueObject

@property (nonatomic, strong) UserVO *friend;

@end
