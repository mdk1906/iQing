//
//  BulletVO.h
//  Qingwen
//
//  Created by mumu on 16/12/8.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import "QWValueObject.h"

@protocol BulletVO <NSObject>

@end

@interface BulletVO : QWValueObject

@property (nonatomic, copy) NSString *value;

@property (nonatomic, copy) NSString *avatar;

@property (assign) NSInteger key;

//客户端字段
@property (assign) BOOL isMine;
@property (nonatomic, copy) NSNumber *showAvatar;
@property (assign) BOOL placeholder;
@end
