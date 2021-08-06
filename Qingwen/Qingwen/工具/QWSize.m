//
//  Qingwen.m
//  Qingwen
//
//  Created by Aimy on 14/11/30.
//  Copyright (c) 2014年 Qingwen. All rights reserved.
//

#import "QWSize.h"

@implementation QWSize

static inline CGFLOAT_TYPE CGFloat_ceil(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return ceil(cgfloat);
#else
    return ceilf(cgfloat);
#endif
}

+ (CGFloat)getLengthWithSizeType:(QWSizeType)sizeType andLength:(CGFloat)length
{
    CGFloat resultLength = length * [[self multiplicative][@([self getCurrentSizeType])] doubleValue] / [[self multiplicative][@(sizeType)] doubleValue];
    resultLength = ceil(resultLength);
    
    return resultLength;
}

+ (QWSizeType)getCurrentSizeType
{
    static QWSizeType currentSizeType = QWSizeTypeNone;
    
    if (currentSizeType == QWSizeTypeNone) {
        if (ISIPHONE3_5) {
            currentSizeType = QWSizeType3_5;
        }
        else if (ISIPHONE4_0) {
            currentSizeType = QWSizeType4_0;
        }
        else if (ISIPHONE4_7) {
            currentSizeType = QWSizeType4_7;
        }
        else if (ISIPHONE5_5) {
            currentSizeType = QWSizeType5_5;
        }
        else if (ISIPHONE9_7) {
            currentSizeType = QWSizeType9_7;
        }
    }
    
    return currentSizeType;
}

+ (NSDictionary *)multiplicative
{
    return @{@0:@0,
             @1:@320,
             @2:@320,
             @3:@375,
             @4:@414,
             @5:@768};
}

+ (CGFloat)screenWidth
{
    if (IOS_SDK_MORE_THAN(8.0) || !IS_LANDSCAPE) {
        return [UIScreen mainScreen].bounds.size.width;
    }
    else {
        return [UIScreen mainScreen].bounds.size.height;
    }
}

+ (CGFloat)screenWidth:(BOOL)landscape
{
    CGFloat width = [self screenWidth];
    CGFloat height = [self screenHeight];
    if (landscape) {
        return MAX(width, height);
    }
    else {
        return MIN(width, height);
    }
}

+ (CGFloat)screenHeight
{
    if (IOS_SDK_MORE_THAN(8.0) || !IS_LANDSCAPE) {
        return [UIScreen mainScreen].bounds.size.height;
    }
    else {
        return [UIScreen mainScreen].bounds.size.width;
    }
}

+ (CGFloat)screenHeight:(BOOL)landscape
{
    CGFloat width = [self screenWidth];
    CGFloat height = [self screenHeight];
    if (landscape) {
        return MIN(width, height);
    }
    else {
        return MAX(width, height);
    }
}
//自适应高度
+ (CGFloat)customAutoHeigh:(NSString *)contentString width:(CGFloat)width num:(CGFloat)num
{
    CGRect rect = [contentString boundingRectWithSize:CGSizeMake(width, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:FONT(num)} context:nil];
    return rect.size.height;
}
//自适应宽度
+ (CGFloat)autoWidth:(NSString *)nameString width:(CGFloat)width height:(CGFloat)height num:(CGFloat)num
{
    CGSize size = CGSizeMake(width, height);
    //    CGSize labelSize = [nameString sizeWithFont:FONT(num) constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    CGRect  labelSize = [nameString boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:FONT(num)} context:nil];
    return labelSize.size.width;
    
}
+ (CGFloat)bannerHeight{
    return 60;
}
+ (NSInteger)hideLabelLayoutHeight:(NSString *)content withTextFontSize:(CGFloat)mFontSize withWidth:(CGFloat)width
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //行距
    CGFloat linespace = 10.0;
    
    paragraphStyle.lineSpacing = linespace;  // 段落高度
    paragraphStyle.firstLineHeadIndent = 30;
    paragraphStyle.maximumLineHeight = linespace;
    paragraphStyle.minimumLineHeight = linespace;
    
    
    NSMutableAttributedString *attributes = [[NSMutableAttributedString alloc] initWithString:content];
    
    [attributes addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:mFontSize] range:NSMakeRange(0, content.length)];
    [attributes addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, content.length)];
    
    CGSize attSize = [attributes boundingRectWithSize:CGSizeMake(UISCREEN_WIDTH-40, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    
    return attSize.height;
}
+ (CGSize)sizeLabelToFit:(NSAttributedString *)aString width:(CGFloat)width height:(CGFloat)height {
    UILabel *tempLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    tempLabel.attributedText = aString;
    tempLabel.numberOfLines = 0;
    [tempLabel sizeToFit];
    CGSize size = tempLabel.frame.size;
     size = CGSizeMake(CGFloat_ceil(size.width), CGFloat_ceil(size.height));
    return size;
}

+ (int)getAttributedStringHeightWithString:(NSAttributedString *)  string  WidthValue:(int) width
{
    int total_height = 0;
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);    //string 为要计算高度的NSAttributedString
    CGRect drawingRect = CGRectMake(0, 0, width, 1000);  //这里的高要设置足够大
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, drawingRect);
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
    CGPathRelease(path);
    CFRelease(framesetter);
    
    NSArray *linesArray = (NSArray *) CTFrameGetLines(textFrame);
    
    CGPoint origins[[linesArray count]];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    
    int line_y = (int) origins[[linesArray count] -1].y;  //最后一行line的原点y坐标
    
    CGFloat ascent;
    CGFloat descent;
    CGFloat leading;
    
    CTLineRef line = (__bridge CTLineRef) [linesArray objectAtIndex:[linesArray count]-1];
    CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    
    total_height = 1000 - line_y + (int) descent +1;    //+1为了纠正descent转换成int小数点后舍去的值
    
    CFRelease(textFrame);
    
    return total_height;
    
}

@end
