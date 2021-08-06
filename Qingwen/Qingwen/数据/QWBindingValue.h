//
//  QWBindingValue.h
//  Qingwen
//
//  Created by mumu on 2017/8/14.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

UIKIT_EXTERN NSString * const __nonnull BINDING_CHANGED;//登录状态修改


@interface QWBindingValue : NSObject

+ (QWBindingValue * __nonnull)sharedInstance;

@property (nonatomic, copy, nullable) BindingVO *qq;
@property (nonatomic, copy, nullable) BindingVO *wx;
@property (nonatomic, copy, nullable) BindingVO *sina;
@property (nonatomic, copy, nullable) BindingVO *bindPhone;

@property (nonatomic, copy, nullable) AuthenticationVO *autor;

- (void)update;
- (BOOL)isBindPhone;
- (BOOL)isAuthentication;
@end
