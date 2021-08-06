//
//  QWReadingConfig.h
//  Qingwen
//
//  Created by Aimy on 7/6/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QWReadingBG) {
    QWReadingBGDefault = 0,
    QWReadingBGBlack,
    QWReadingBGGreen,
    QWReadingBGPink,
};

typedef NS_ENUM(NSInteger, QWReadingAttributeType) {
    QWReadingAttributeTypeTitle = 0,//卷名
    QWReadingAttributeTypeSubtitle,//章节名
    QWReadingAttributeTypeContent,//内容
};

UIKIT_EXTERN NSString * const __nonnull QWREADING_CHANGED;//修改了设置

@interface QWReadingConfig : NSObject <NSCoding>

+ (QWReadingConfig * __nonnull)sharedInstance;

@property (nonatomic, readonly) CGRect readingBounds;//当前的可读的屏幕范围（去掉边框）
@property (nonatomic, readonly) CGRect imageBounds;//当前的可读的屏幕范围（去掉边框）
@property (nonatomic, readonly) CGFloat danmuHeight; //弹幕的高度
@property (nonatomic, readonly) CGRect adBounds;//插屏广告
@property (nonatomic, copy, readonly, nullable) UIColor *readingColor;//根据背景颜色切换阅读界面字体颜色
@property (nonatomic, copy, readonly, nullable) UIColor *statusColor;//根据背景颜色切换状态栏颜色

@property (nonatomic) QWReadingBG readingBG;//当前的背景图

@property (nonatomic, copy, readonly, nullable) UIFont *titleFont;//当前的标题字体
@property (nonatomic, copy, readonly, nullable) UIFont *subtitleFont;//当前的副标题字体
@property (nonatomic, copy, readonly, nullable) UIFont *font;//当前的字体
@property (nonatomic, readonly) NSInteger fontSize;//当前字体大小

@property (nonatomic, copy, readonly, nonnull) NSArray *fontSzieString;//支持的字体大小的string

@property (nonatomic) BOOL landscape;//使用横屏

@property (nonatomic) CGFloat systemBrightness;//系统原始设置的屏幕亮度
@property (nonatomic) CGFloat brightness;//用户设置的屏幕亮度
@property (nonatomic) BOOL useSystemBrightness;//使用系统亮度
@property (nonatomic) BOOL traditional;//繁体输出
@property (nonatomic) BOOL originalFont;//原文输出
@property (nonatomic) BOOL alwaysBrightness;//屏幕常亮
@property (nonatomic) BOOL showDanmu; //开启弹幕
//@property (nonatomic) BOOL boyAloud; //男声
//@property (nonatomic) BOOL girlAloud; //女声
//@property (nonatomic) NSInteger aloudSpeed; //音速

- (NSDictionary * __nonnull)attributesWithType:(QWReadingAttributeType)type;
- (void)saveData;

//改变字体大小
- (BOOL)changeFont:(BOOL)small;
- (BOOL)canChangeFont:(BOOL)small;
- (BOOL)changeFontToSize:(NSString * __nonnull)size;

- (UIImage *_Nullable)readingBgImage;
@end
