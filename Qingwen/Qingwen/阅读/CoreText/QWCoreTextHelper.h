//
//  QWCoreTextHelper.h
//  Qingwen
//
//  Created by Aimy on 7/6/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QWReadingConfig.h"
#import <CoreText/CoreText.h>

typedef NS_ENUM(NSUInteger, QWCoreTextContentType) {
    QWCoreTextContentTypeContent = 0,//文字内容(uiimage)
    QWCoreTextContentTypeCustom,//自定义
    QWCoreTextContentTypeError = 999,//错误
};

NS_ASSUME_NONNULL_BEGIN

//占位大小
extern const NSString *kQWPlaceholderRectAttributeName;
//占位图片
extern const NSString *kQWPlaceholderContentAttributeName;
//chapter
extern const NSString *kQWPlaceholderChapterAttributeName;

typedef void(^QWCoreTextHelperCompleteBlock)(id __nullable content, QWCoreTextContentType type);

@interface QWCoreTextHelper : NSObject

/**
 *  获取第n个字符的page index
 *
 *  @param attributedString 富文本
 *  @param drawRect         幕布rect
 *  @param textRect         文件rect
 *  @param c                context
 */
+ (NSInteger)getPageIndexWithLocation:(NSInteger)location attributedString:(NSAttributedString *)attributedString inDrawRect:(CGRect)drawRect inTextRect:(CGRect)textRect framesetter:(CTFramesetterRef)framesetter;

/**
 *  获得page个数
 *
 */
+ (NSInteger)getPageCountAndConfigPage:(NSMutableArray *)pages andAttributedString:(NSAttributedString *)attributedString inDrawRect:(CGRect)drawRect inTextRect:(CGRect)textRect framesetter:(CTFramesetterRef)framesetter;

/**
 *  获取某range之后的一页显示的range
 *
 *  @param attributedString 富文本
 *  @param drawRect         幕布rect
 *  @param textRect         文件rect
 *  @param c                context
 */
+ (NSRange)getPageRangeAttributedString:(NSAttributedString *)attributedString inDrawRect:(CGRect)drawRect inTextRect:(CGRect)textRect range:(NSRange)range draw:(BOOL)draw framesetter:(CTFramesetterRef)framesetter andCompleteBlock:(QWCoreTextHelperCompleteBlock __nullable)block;

+ (NSMutableArray*)getPageCountAndConfigPageWithAttributedString:(NSAttributedString *)attributedString inDrawRect:(CGRect)drawRect inTextRect:(CGRect)textRect framesetter:(CTFramesetterRef)aFramesetter;

@end

@interface NSMutableAttributedString (QWCoreTextHelper)
/**
 *  添加换行
 *
 *  @return self
 */
- (NSMutableAttributedString *)stringByAppendingNewline;

/**
 *  添加文字,并换行
 *
 *  @param string  字符
 *
 *  @return self
 */
- (NSMutableAttributedString *)stringByAppendingNewlineString:(NSString *)string andType:(QWReadingAttributeType)type;

/**
 *  添加图文混排占位字符
 *
 *  @param rect      图片rect
 *  @param imageName 图片名称
 *
 *  @return self
 */
- (NSMutableAttributedString *)stringByAppendingPlaceholerRect:(CGRect)rect content:(id)content;
/**
 *  添加广告混排占位字符
 *
 *  @param rect      广告rect
 *  @param imageName 广告
 *
 *  @return self
 */
- (NSMutableAttributedString *)stringByAppendingAdRect:(CGRect)rect content:(id)content;

- (NSMutableAttributedString *)ttsStr:(NSString*)string oringStr:(NSString*)oringStr andType:(QWReadingAttributeType)type;


@end

NS_ASSUME_NONNULL_END
