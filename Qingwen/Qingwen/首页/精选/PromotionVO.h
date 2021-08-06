//
//  PromotionVO.h
//  Qingwen
//
//  Created by Aimy on 12/7/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWValueObject.h"

@protocol PromotionVO <NSObject>

@end

@interface PromotionVO : QWValueObject

@property (nonatomic, nullable, copy) NSString *title;
@property (nonatomic, nullable, copy) NSString *url;
@property (nonatomic, nullable, copy) NSString *cover;

@end
