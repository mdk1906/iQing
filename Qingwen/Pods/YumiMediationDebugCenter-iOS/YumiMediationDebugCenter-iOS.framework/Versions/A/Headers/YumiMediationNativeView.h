//
//  YumiMediationNativeView.h
//  YumiMediationSDK-iOS
//
//  Created by 王泽永 on 2017/9/22.
//  Copyright © 2017年 JiaDingYi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YumiMediationNativeView : UIView

@property (strong, nonatomic) IBOutlet UIImageView *icon;
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UIImageView *coverImage;
@property (strong, nonatomic) IBOutlet UILabel *desc;
@property (strong, nonatomic) IBOutlet UIButton *callToAction;
@property (strong, nonatomic) IBOutlet UIButton *closeButton;

@end
