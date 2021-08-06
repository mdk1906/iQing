//
//  OTSMappingVO.h
//  Qingwin
//
//  Created by Aimy on 14-6-28.
//  Copyright (c) 2014年 Qingwin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QWMappingClassCreateType)
{
    QWMappingClassCreateByStoryboard = 0,//storyboard方式创建
    QWMappingClassCreateByXib        = 1,//xib方式创建
    QWMappingClassCreateByCode       = 2,//编码方式创建
};

typedef NS_ENUM(NSUInteger, QWMappingClassPlatformType)
{
    QWMappingClassPlatformTypeUniversal = 0,//任何平台都load
    QWMappingClassPlatformTypePhone     = 1,//只在iPhone上load
    QWMappingClassPlatformTypePad       = 2,//只在iPad上load
};

@interface QWMappingVO : NSObject
/**
 *  创建的类名
 */
@property (nonatomic, strong) NSString *className;
/**
 *  创建的方式
 */
@property (nonatomic) QWMappingClassCreateType createdType;
/**
 *  load过滤
 */
@property (nonatomic) QWMappingClassPlatformType loadFilterType;
/**
 *  资源文件存放的bundle名称
 */
@property (nonatomic, strong) NSString *bundleName;
/**
 *  资源文件名称
 */
@property (nonatomic, strong) NSString *nibName;
/**
 *  storyboard名称
 */
@property (nonatomic, strong) NSString *storyboardName;
/**
 *  storyboard中storyboardID名称
 */
@property (nonatomic, strong) NSString *storyboardID;
/**
 *  进入此界面需要先登陆
 */
@property (nonatomic) BOOL needLogin;
/**
 *  是否模态
 */
@property (nonatomic) BOOL model;

/**
 * 模态的方式
 */
@property (nonatomic, assign) UIModalPresentationStyle modalPresentationStyle;

@end
