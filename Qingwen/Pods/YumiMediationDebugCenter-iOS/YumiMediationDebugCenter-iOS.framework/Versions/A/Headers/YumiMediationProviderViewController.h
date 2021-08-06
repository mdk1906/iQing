//
//  YumiMediationProviderViewController.h
//  YumiMediationSDK-iOS
//
//  Created by ShunZhi Tang on 2017/7/18.
//  Copyright © 2017年 JiaDingYi. All rights reserved.
//

#import "YumiMediationProviderInfo.h"
#import <UIKit/UIKit.h>

@interface YumiMediationProviderViewController : UIViewController

@property (nonatomic) NSArray<YumiMediationProviderInfo *> *providers;
@property (nonatomic) NSString *requestName;

@end
