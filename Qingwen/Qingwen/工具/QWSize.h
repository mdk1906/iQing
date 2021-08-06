//
//  QWSize.h
//  Qingwen
//
//  Created by Aimy on 14/11/30.
//  Copyright (c) 2014年 Qingwen. All rights reserved.
//

#import <Foundation/Foundation.h>

//1像素
#define PX1_LINE (1.0 / [UIScreen mainScreen].scale)

//设备当前宽高
#define UISCREEN_WIDTH  [QWSize screenWidth]
#define UISCREEN_HEIGHT [QWSize screenHeight]

#define FONT(A) [UIFont systemFontOfSize:A]

#define kMaxX(X) CGRectGetMaxX(X)
#define kMaxY(Y) CGRectGetMaxY(Y)

#define QWBannerAdHeight 60

//判断ios版本
#define IOS_SDK_MORE_THAN_OR_EQUAL(__num) [UIDevice currentDevice].systemVersion.floatValue >= (__num)
#define IOS_SDK_MORE_THAN(__num) [UIDevice currentDevice].systemVersion.floatValue > (__num)
#define IOS_SDK_LESS_THAN(__num) [UIDevice currentDevice].systemVersion.floatValue < (__num)

//判断设备
#define IS_IPAD_DEVICE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE_DEVICE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define ISIPHONE3_5  ISEQUAL_SCREEN_BOUNDS(CGSizeMake(320, 480),  CGSizeMake(480, 320))
#define ISIPHONE4_0  ISEQUAL_SCREEN_BOUNDS(CGSizeMake(320, 568),  CGSizeMake(568, 320))
#define ISIPHONE4_7  ISEQUAL_SCREEN_BOUNDS(CGSizeMake(375, 667),  CGSizeMake(667, 375))
#define ISIPHONE5_5  ISEQUAL_SCREEN_BOUNDS(CGSizeMake(414, 736),  CGSizeMake(736, 414))
#define ISIPHONE9_7  ISEQUAL_SCREEN_BOUNDS(CGSizeMake(1024, 768), CGSizeMake(768, 1024))
#define ISIPHONEX    (UISCREEN_WIDTH == 375.f && UISCREEN_HEIGHT == 812.f)
#define ISIPHONEXR    (UISCREEN_WIDTH == 414.f && UISCREEN_HEIGHT == 896.f)
#define ISIPHONEXSMAX    (UISCREEN_WIDTH == 414.f && UISCREEN_HEIGHT == 896.f)
#define ISEQUAL_SCREEN_BOUNDS(vSize, lSize) (CGSizeEqualToSize(vSize, [[UIScreen mainScreen] bounds].size) || CGSizeEqualToSize(lSize, [[UIScreen mainScreen] bounds].size))

//判断横竖屏
#define IS_LANDSCAPE UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)


typedef NS_ENUM(NSInteger, QWSizeType)
{
    QWSizeTypeNone = 0,
    QWSizeType3_5,
    QWSizeType4_0,
    QWSizeType4_7,
    QWSizeType5_5,
    QWSizeType9_7,
};

@interface QWSize : NSObject

+ (CGFloat)getLengthWithSizeType:(QWSizeType)sizeType andLength:(CGFloat)length;

+ (CGFloat)screenWidth;
+ (CGFloat)screenWidth:(BOOL)landscape;
+ (CGFloat)screenHeight;
+ (CGFloat)screenHeight:(BOOL)landscape;
+ (CGFloat)bannerHeight;
//自适应高度
+ (CGFloat)customAutoHeigh:(NSString *)contentString width:(CGFloat)width num:(CGFloat)num;

//自适应宽度
+ (CGFloat)autoWidth:(NSString *)nameString width:(CGFloat)width height:(CGFloat)height num:(CGFloat)num;

+ (NSInteger)hideLabelLayoutHeight:(NSString *)content withTextFontSize:(CGFloat)mFontSize withWidth:(CGFloat)width;

+ (int)getAttributedStringHeightWithString:(NSAttributedString *)  string  WidthValue:(int) width;
@end
