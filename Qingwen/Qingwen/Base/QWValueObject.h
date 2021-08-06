//
//  QWValueObject.h
//  Qingwen
//
//  Created by Aimy on 7/4/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface QWValueObject : JSONModel

/**
 *  通过字典创建VO
 *
 *  @param aDict 字典
 *
 *  @return VO
 */
+ (_Nullable instancetype)voWithDict:(NSDictionary<NSString *, id> * _Nullable)aDict;
+ (_Nullable instancetype)voWithJson:(NSString * _Nullable)aJson;

@end
