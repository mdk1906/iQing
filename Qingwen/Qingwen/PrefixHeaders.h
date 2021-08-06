//
//  PrefixHeaders.h
//  Qingwen
//
//  Created by Aimy on 7/1/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#ifndef Qingwen_PrefixHeaders_h
#define Qingwen_PrefixHeaders_h

#ifdef DEBUG
//
#define NSLog(...) NSLog(__VA_ARGS__)

#else

//干掉log
#define NSLog(...) {}
//干掉断言
//
#ifndef NS_BLOCK_ASSERTIONS
#define NS_BLOCK_ASSERTIONS
#endif
#define _NSAssertBody

#endif

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import <BlocksKit/BlocksKit+UIKit.h>
#import <Block-KVO/MTKObserving.h>
#import <MagicalRecord/MagicalRecord.h>

#import "QWDefine.h"

#import "Qingwen-Swift.h"

//safe
#import "NSMutableArray+safe.h"
#import "NSMutableDictionary+safe.h"

#import "NSObject+QW.h"

#import "UIViewController+create.h"
#import "UIView+create.h"

#import "UIView+EnlargeArea.h"
#import "UIViewController+loading.h"
#import "UIView+loading.h"

#import "QWTracker.h"
#import "QWGlobalValue.h"
#import "QWBannedWords.h"
#import "QWConvertImageString.h"
#import "QWSize.h"
#import "QWColor.h"
#import "QWKeychain.h"
#import "QWHelper.h"
#import "QWRouter.h"
#import "QWFileManager.h"
#import "QWColor.h"
#import "QWBaseView.h"
#import "QWBindingValue.h"
#import "QWMyMissionVC.h"
#import "QWMymedelVC.h"
#import "QWMyAchievementVC.h"
#import "QWAchievementBounced.h"
#ifndef DEBUG

//3.0删除
//#import <UMengAnalytics-NO-IDFA/MobClick.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "BaiduMobStat.h"
#import "StatisticVO.h"
#import "QWActivityTracing.h"
#import "QWUserStatistics.h"

#endif

#endif
