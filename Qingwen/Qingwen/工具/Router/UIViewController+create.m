//
//  UIViewController+create.m
//  OneStoreFramework
//
//  Created by mdk mdk on 2018/5/21.
//  Copyright (c) 2014年 OneStore. All rights reserved.
//

#import "UIViewController+create.h"

#import "QWMappingVO.h"
#import "QWRouter.h"

@interface QWRouter ()

@property (nonatomic, strong) NSMutableDictionary *mapping;

@end

@implementation UIViewController (create)

#pragma mark - 通过QWMappingVO创建VC

+ (instancetype)createWithMappingVOKey:(NSString *)aKey extraData:(NSDictionary<NSString *, id> *)aParam
{
    return [self createWithMappingVO:[QWRouter sharedInstance].mapping[aKey] extraData:aParam];
}

+ (instancetype)createWithMappingVO:(QWMappingVO *)aMappingVO extraData:(NSDictionary *)aParam
{
    if (aMappingVO.className == nil) {
        NSLog(@"QWMappingVO error %@, className is nil",aMappingVO.description);
        return nil;
    }
    
    Class class = NSClassFromString(aMappingVO.className);
    if (!class) {
        NSLog(@"QWMappingVO error %@, no such class",aMappingVO);
        return nil;
    }
    
    UIViewController *vc = nil;
    
    if (aMappingVO.createdType == QWMappingClassCreateByCode) {
        vc = [class new];
    }
    else if (aMappingVO.createdType == QWMappingClassCreateByXib) {
        NSString *nibName = aMappingVO.nibName;
        if ( ! nibName.length) {
            nibName = [class getStoryBoardIDOrNibNameWithType:[aParam[@"type"] integerValue]];
        }

        vc = [class createFromXibWithNibName:nibName bundleName:aMappingVO.bundleName];
    }
    else if (aMappingVO.createdType == QWMappingClassCreateByStoryboard) {
        NSString *storyboardID = aMappingVO.storyboardID;
        if ( ! storyboardID.length) {
            storyboardID = [class getStoryBoardIDOrNibNameWithType:[aParam[@"type"] integerValue]];
        }

        vc = [class createFromStoryboardWithStoryboardID:storyboardID storyboardName:aMappingVO.storyboardName bundleName:aMappingVO.bundleName];
    }
    
    aParam = aParam ?: @{};
    vc.extraData = aParam;
    
    return vc;
}

+ (instancetype)createFromXib
{
    return [self createFromXibWithNibName:[NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject];
}

+ (instancetype)createFromXibWithNibName:(NSString *)aNibName
{
    return [self createFromXibWithNibName:aNibName bundleName:nil];
}

+ (instancetype)createFromXibWithBundleName:(NSString *)aBundleName
{
    return [self createFromXibWithNibName:[NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject bundleName:aBundleName];
}

+ (instancetype)createFromXibWithNibName:(NSString *)aNibName bundleName:(NSString *)aBundleName
{
    NSBundle *bundle = [self getBundleWithBundleName:aBundleName];
    return [[self alloc] initWithNibName:aNibName bundle:bundle];
}

//storyboard
+ (instancetype)createFromStoryboard
{
    return [self createFromStoryboardWithStoryboardName:[NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject];
}

+ (instancetype)createFromStoryboardWithStoryboardName:(NSString *)aStoryboardName
{
    return [self createFromStoryboardWithStoryboardID:[NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject storyboardName:aStoryboardName];
}

+ (instancetype)createFromStoryboardWithStoryboardID:(NSString *)aStoryboardID storyboardName:(NSString *)aStoryboardName
{
    return [self createFromStoryboardWithStoryboardID:aStoryboardID storyboardName:aStoryboardName bundleName:nil];
}

+ (instancetype)createFromStoryboardWithStoryboardName:(NSString *)aStoryboardName bundleName:(NSString *)aBundleName
{
    return [self createFromStoryboardWithStoryboardID:[NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject storyboardName:aStoryboardName bundleName:aBundleName];
}

+ (instancetype)createFromStoryboardWithStoryboardID:(NSString *)aStoryboardID storyboardName:(NSString *)aStoryboardName bundleName:(NSString *)aBundleName
{
    NSBundle *bundle = [self getBundleWithBundleName:aBundleName];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:aStoryboardName bundle:bundle];
    if (aStoryboardID.length) {
        return [storyboard instantiateViewControllerWithIdentifier:aStoryboardID];
    }
    else {
        return [storyboard instantiateInitialViewController];
    }
}

+ (NSBundle *)getBundleWithBundleName:(NSString *)aBundleName
{
    NSBundle *bundle = [NSBundle mainBundle];
    if (aBundleName.length) {
        bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:aBundleName withExtension:@"bundle"]];
    }
    
    return bundle;
}

@end
