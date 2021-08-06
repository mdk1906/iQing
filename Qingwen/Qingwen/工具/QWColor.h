//
//  QWColor.h
//  Qingwen
//
//  Created by Aimy on 9/8/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define HRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(rgbValue & 0xFF)) / 255.0 \
alpha:1.0]

#define HRGBA(rgbValue, a) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(rgbValue & 0xFF)) / 255.0 \
alpha:a]

#define QWPINK             [UIColor colorQWPink]
#define QWPINK_TRANSPARENT [UIColor colorQWPinkTransparent]

@interface UIColor (QW)

+ (UIColor *)randomColor;

+ (UIColor *)colorF9;
+ (UIColor *)colorF4;
+ (UIColor *)colorDC;
+ (UIColor *)colorAE;
+ (UIColor *)color84;
+ (UIColor *)color50;
+ (UIColor *)color55;
+ (UIColor *)color69;
+ (UIColor *)colorF1;
+ (UIColor *)color33;
+ (UIColor *)cloroFB;
+ (UIColor *)colorDD; //浅灰
+ (UIColor *)colorFA; //淡红
+ (UIColor *)colorFE; //黄色
+ (UIColor *)colorF8; //浅灰
+ (UIColor *)color9A; //浅灰
+ (UIColor *)colorQWPink;
+ (UIColor *)colorQWPinkDark;
+ (UIColor *)colorQWPinkTransparent;

+ (UIColor *)colorA6;
+ (UIColor *)colorEE; //eeebeb
+ (UIColor *)colorVote;//投票颜色
@end
