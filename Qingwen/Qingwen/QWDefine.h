//
//  QWDefine.h
//  Qingwen
//
//  Created by Aimy on 7/1/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#ifndef Qingwen_QWDefine_h
#define Qingwen_QWDefine_h

//end edting
#define END_EDITING [[[UIApplication sharedApplication].delegate window] endEditing:YES]

//weak strong self for retain cycle
#define WEAK_SELF __weak typeof(self)weakSelf            = self
#define STRONG_SELF STRONG_SELF_NIL_RETURN
#define KVO_STRONG_SELF KVO_STRONG_SELF_NIL_RETURN

#define STRONG_SELF_NIL_RETURN __strong typeof(weakSelf)self = weakSelf; if ( ! self) return ;
#define KVO_STRONG_SELF_NIL_RETURN __strong typeof(weakSelf)kvoSelf = weakSelf; if ( ! kvoSelf) return ;

// 单例
#undef	DEF_SINGLETON
#define DEF_SINGLETON( __class ) \
+ (__class * __nonnull)sharedInstance \
{ \
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once(&once, ^{ __singleton__ = [[__class alloc] init]; } ); \
return __singleton__; \
}

#endif
