//
//  YTDrawView.h
//  CoreTextDemo
//
//  Created by aron on 2018/7/12.
//  Copyright © 2018年 aron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RichTextData.h"
#import "YTBaseDataItem.h"
#import "YTAttachmentItem.h"

@interface YTDrawView : UIView

@property (nonatomic, assign) NSInteger numberOfLines; ///<行数
@property (nonatomic, strong) NSAttributedString *truncationToken;///<截断的标识字符串，默认是"..."
@property (nonatomic, copy) ClickActionHandler truncationActionHandler;///<截断的标识字符串点击事件
@property (nonatomic, strong) NSString *text;///<文本内容
@property (nonatomic, strong) UIColor *textColor;///<字体颜色
@property (nonatomic, strong) UIFont *font;///<字体
@property (nonatomic, strong) UIColor *shadowColor;///<阴影颜色
@property (nonatomic, assign) CGSize shadowOffset;///<阴影偏移位置
@property (nonatomic, assign) CGFloat shadowAlpha;///<阴影透明度
@property (nonatomic, assign) CGFloat lineSpacing;///<行间距
@property (nonatomic, assign) CGFloat paragraphSpacing;///<段落间距
@property (nonatomic, assign) CTTextAlignment textAlignment;///<文字排版样式

/**
 添加自定义的字符串并且设置字符串属性

 @param string 字符串
 @param attributes 字符串的属性
 @param clickActionHandler 点击事件，暂时没效果 TODO
 */
- (void)addString:(NSString *)string attributes:(NSDictionary *)attributes clickActionHandler:(ClickActionHandler)clickActionHandler;

/**
 添加链接

 @param link 链接的地址
 @param clickActionHandler 链接点击事件
 */
- (void)addLink:(NSString *)link clickActionHandler:(ClickActionHandler)clickActionHandler;

/**
 添加图片

 @param image 图片
 @param size 图片大小
 @param clickActionHandler 图片点击事件
 */
- (void)addImage:(UIImage *)image size:(CGSize)size clickActionHandler:(ClickActionHandler)clickActionHandler;

/**
 添加UIView对象

 @param view UIView对象
 @param size UIView对象大小
 @param clickActionHandler UIView对象点击事件
 */
- (void)addView:(UIView *)view size:(CGSize)size clickActionHandler:(ClickActionHandler)clickActionHandler;

/**
 添加UIView对象
 
 @param view UIView对象
 @param size UIView对象大小
 @param align 对其方式
 @param clickActionHandler UIView对象点击事件
 */
- (void)addView:(UIView *)view size:(CGSize)size align:(YTAttachmentAlignType)align clickActionHandler:(ClickActionHandler)clickActionHandler;

@end
