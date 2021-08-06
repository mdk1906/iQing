//
//  MessageDataVO.h
//  Qingwen
//
//  Created by Aimy on 12/3/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWValueObject.h"

@interface MessageDataVO : QWValueObject

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *sub_title;
@property (nonatomic, copy, nullable) NSString *content;
@property (nonatomic, copy, nullable) NSString *cover;
@property (nonatomic, copy, nullable) NSString *end_notes;

@end
