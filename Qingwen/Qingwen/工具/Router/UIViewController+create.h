//
//  UIViewController+create.h
//  Qingwen
//
//  Created by mdk mdk on 2018/5/21.
//  Copyright (c) 2014年 Qingwen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QWMappingVO;

@interface UIViewController (create)

#pragma mark - create
/**
 *  通过mappingvo的key创建vc
 *
 *  @param aKey
 *  @param aParam
 *
 *  @return
 */
+ (nullable instancetype)createWithMappingVOKey:(NSString *)aKey extraData:(NSDictionary *)aParam;
/**
 *  vc创建
 *
 *  @param aMappingVO QWMappingVO
 *  @param aParam     创建参数
 *
 *  @return QWVC
 */
+ (nullable instancetype)createWithMappingVO:(QWMappingVO *)aMappingVO extraData:(NSDictionary *)aParam;
/**
 *  从xib创建vc
 *
 *  @param aBundleName res bundle name，NibName = self.class
 *
 *  @return QWVC
 */
+ (nullable instancetype)createFromXib;
/**
 *  从xib创建vc
 *
 *  @param aBundleName res bundle name，NibName = self.class
 *
 *  @return QWVC
 */
+ (nullable instancetype)createFromXibWithBundleName:(nullable NSString *)aBundleName;
/**
 *  从xib创建vc
 *
 *  @param aNibName
 *  @param aBundleName
 *
 *  @return QWVC
 */
+ (nullable instancetype)createFromXibWithNibName:(nullable NSString *)aNibName;
/**
 *  从xib创建vc
 *
 *  @param aNibName
 *  @param aBundleName
 *
 *  @return QWVC
 */
+ (nullable instancetype)createFromXibWithNibName:(nullable NSString *)aNibName bundleName:(nullable NSString *)aBundleName;
/**
 *  从storyboard创建vc
 *
 *  @param aStoryboardName self.class，storyboardID = self.class
 *
 *  @return QWVC
 */
+ (nullable instancetype)createFromStoryboard;
/**
 *  从storyboard创建vc
 *
 *  @param storyboardID = self.class
 *
 *  @return QWVC
 */
+ (nullable instancetype)createFromStoryboardWithStoryboardName:(NSString *)aStoryboardName;
/**
 *  @param
 *
 *  @return QWVC
 */
+ (nullable instancetype)createFromStoryboardWithStoryboardID:(nullable NSString *)aStoryboardID storyboardName:(NSString *)aStoryboardName;
/**
 *  从storyboard创建vc
 *
 *  @param storyboardID = self.class
 *
 *  @return QWVC
 */
+ (nullable instancetype)createFromStoryboardWithStoryboardName:(NSString *)aStoryboardName bundleName:(nullable NSString *)aBundleName;
/**
 *  @param aBundleName res bundle name，storyboardID = self.class
 *
 *  @return QWVC
 */
+ (nullable instancetype)createFromStoryboardWithStoryboardID:(nullable NSString *)aStoryboardID storyboardName:(NSString *)aStoryboardName bundleName:(nullable NSString *)aBundleName;

@end

NS_ASSUME_NONNULL_END
