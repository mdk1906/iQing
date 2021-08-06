//
//  bindingVO.h
//  Qingwen
//
//  Created by mumu on 16/11/18.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import "QWValueObject.h"

@protocol BindingVO <NSObject>

@end

@interface BindingVO : QWValueObject

@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, copy, nullable) NSString *channel;
@property (nonatomic, copy, nullable) NSNumber *binding;
@property (nonatomic, copy, nullable) NSString *nickname;

@end
