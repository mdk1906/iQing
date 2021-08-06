//
//  QWCoreTextHelper.m
//  Qingwen
//
//  Created by Aimy on 7/6/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWCoreTextHelper.h"

#import "BookPageVO.h"

//占位大小
const NSString *kQWPlaceholderRectAttributeName = @"QWPlaceholderSizeAttributeName";
//占位图片
const NSString *kQWPlaceholderContentAttributeName = @"QWPlaceholderContentAttributeName";
//chapter
const NSString *kQWPlaceholderChapterAttributeName = @"QWPlaceholderChapterAttributeName";
//AdView
const NSString *kQWPlaceholderAdViewAttributeName = @"QWPlaceholderAdViewAttributeName";
CGFloat ascentCallback (void * refCon)
{
    NSValue *value = (__bridge NSValue *)(refCon);
    return value.CGRectValue.size.height / 2;
}

CGFloat descentCallback (void * refCon)
{
    NSValue *value = (__bridge NSValue *)(refCon);
    return value.CGRectValue.size.height / 2;
}

CGFloat widthCallback (void * refCon)
{
    NSValue *value = (__bridge NSValue *)(refCon);
    return value.CGRectValue.size.width;
}

void deallocCallback (void * refCon)
{
    CFRelease(refCon);
}

@implementation QWCoreTextHelper

+ (NSInteger)getPageIndexWithLocation:(NSInteger)location attributedString:(NSAttributedString *)attributedString inDrawRect:(CGRect)drawRect inTextRect:(CGRect)textRect framesetter:(CTFramesetterRef)aFramesetter
{
    if (!attributedString.length) {
        return 0;
    }
    
    if (!aFramesetter) {
        return 0;
    }
    
    CTFramesetterRef framesetter = CFRetain(aFramesetter);
    
    NSUInteger stringLength = attributedString.length;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    
    //frame
    CTFrameRef frame = nil;
    
    NSUInteger textPos = 0;
    NSUInteger pageIndex = 0;
    
    while (textPos < stringLength && textPos < location) {
        //frame
        frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, NULL);
        
        CFRange currentRange = CTFrameGetVisibleStringRange(frame);
        
        textPos += currentRange.length;
        
        CFRelease(frame);
        
        if (textPos >= location) {
            break;
        }
        
        pageIndex++;
    }
    
    CFRelease(path);
    CFRelease(framesetter);
    
    return pageIndex;
}

+ (NSInteger)getPageCountAndConfigPage:(NSMutableArray *)pages andAttributedString:(NSAttributedString *)attributedString inDrawRect:(CGRect)drawRect inTextRect:(CGRect)textRect framesetter:(CTFramesetterRef)aFramesetter
{
    if (!attributedString.length) {
        return 0;
    }
    
    if (!aFramesetter) {
        return 0;
    }
    
    CTFramesetterRef framesetter = CFRetain(aFramesetter);
    
    NSMutableAttributedString *tempAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    
    //frame
    CTFrameRef frame = nil;
    
    NSUInteger textPos = 0;
    NSUInteger pageIndex = 0;
    
    while (textPos < [tempAttributedString length]) {
        //frame
        BookPageVO *page = [BookPageVO new];
        
        frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, NULL);
        
        CFRange currentRange = CTFrameGetVisibleStringRange(frame);
        
        textPos += currentRange.length;
        
        CFRelease(frame);
        
        page.pageIndex = pageIndex;
        page.range = NSMakeRange(currentRange.location, currentRange.length);
        [pages addObject:page];
        
        pageIndex++;
        
    }
    
    CFRelease(path);
    CFRelease(framesetter);
    
    return pageIndex;
}


+ (NSMutableArray*)getPageCountAndConfigPageWithAttributedString:(NSAttributedString *)attributedString inDrawRect:(CGRect)drawRect inTextRect:(CGRect)textRect framesetter:(CTFramesetterRef)aFramesetter
{
    if (!attributedString.length) {
        return 0;
    }
    
    if (!aFramesetter) {
        return 0;
    }
    NSMutableArray *pages = [NSMutableArray new];
    CTFramesetterRef framesetter = CFRetain(aFramesetter);
    
    NSMutableAttributedString *tempAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    
    //frame
    CTFrameRef frame = nil;
    
    NSUInteger textPos = 0;
    NSUInteger pageIndex = 0;
    
    while (textPos < [tempAttributedString length]) {
        //frame
        BookPageVO *page = [BookPageVO new];
        
        frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, NULL);
        
        CFRange currentRange = CTFrameGetVisibleStringRange(frame);
        
        textPos += currentRange.length;
        
        CFRelease(frame);
        
        page.pageIndex = pageIndex;
        page.range = NSMakeRange(currentRange.location, currentRange.length);
        [pages addObject:page];
        
        pageIndex++;
        
    }
    
    CFRelease(path);
    CFRelease(framesetter);
    
    return pages;
}

+ (NSRange)getPageRangeAttributedString:(NSMutableAttributedString *)attributedString inDrawRect:(CGRect)drawRect inTextRect:(CGRect)textRect range:(NSRange)range draw:(BOOL)draw framesetter:(CTFramesetterRef)aFramesetter andCompleteBlock:(QWCoreTextHelperCompleteBlock)block
{
    
    if (!attributedString.length) {
        return NSMakeRange(NSNotFound, 0);
    }
    
    if (!aFramesetter) {
        return NSMakeRange(NSNotFound, 0);
    }
    
    CTFramesetterRef framesetter = CFRetain(aFramesetter);
    
    //设置坐标转换
    CGRect bounds = [QWReadingConfig sharedInstance].readingBounds;
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0);
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(c, CGAffineTransformIdentity);
    
    // Inverts the CTM to match iOS coordinates (otherwise text draws upside-down; Mac OS's system is different)
    CGContextTranslateCTM(c, 0.0f, bounds.size.height);
    CGContextScaleCTM(c, 1.0f, -1.0f);
    
    //设置坐标转换
    CGContextTranslateCTM(c, drawRect.origin.x, drawRect.size.height - textRect.origin.y - textRect.size.height);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    
    //frame
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(range.location, 0), path, NULL);
    
    CFRange currentRange = CTFrameGetVisibleStringRange(frame);
    
    if (draw) {
        do {
            if (!frame) {
                break;
            }
            
            id content = nil;
            
            //line origins
            CFArrayRef lines = CTFrameGetLines(frame);
            
            if (!lines) {
                break;
            }
            
            NSInteger numberOfLines = CFArrayGetCount(lines);
            CGPoint lineOrigins[numberOfLines];
            CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
            
            for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
                @autoreleasepool {
                    CGPoint lineOrigin = lineOrigins[lineIndex];
                    lineOrigin = CGPointMake(ceil(lineOrigin.x), ceil(lineOrigin.y));
                    
                    //line
                    CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
                    CFArrayRef runs = CTLineGetGlyphRuns(line);
                    NSInteger numberOfRuns = CFArrayGetCount(runs);
                    
                    for (CFIndex runIndex = 0; runIndex < numberOfRuns; runIndex++) {
                        @autoreleasepool {
                            //run
                            CTRunRef run = CFArrayGetValueAtIndex(runs, runIndex);
                            
                            CGFloat ascent;
                            CGFloat descent;
                            CGFloat leading;
                            
                            CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
                            CGFloat height = ascent + descent;
                            
                            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                            CGFloat x = lineOrigin.x + xOffset;
                            CGFloat y = lineOrigin.y - descent;
                            
                            __unused CGRect runRect = CGRectMake(x, y, width, height);
                            
                            NSDictionary *attributes = (NSDictionary *)CTRunGetAttributes(run);
                            
                            content = [attributes objectForKey:kQWPlaceholderContentAttributeName];
                            NSString *attributeName = [attributes objectForKey:kQWPlaceholderAdViewAttributeName];
                            if ([attributeName isEqualToString:@"chapterAd"]) {
                                CGFloat end = drawRect.size.height - y - height - 11 ;
                                if (y < drawRect.size.height/2 ) {
                                    if (UISCREEN_HEIGHT == 812.f || UISCREEN_HEIGHT == 896.f) {
                                        end = drawRect.size.height - y - height - 11 -20;
                                    }
                                }
                                
                                NSNumber *endInt = [NSNumber numberWithFloat:end];
                                
                                [[NSNotificationCenter defaultCenter]postNotificationName:@"showchapterAd" object:endInt];
                            }
                            
                            if ([attributeName isEqualToString:@"lastPageAd"]) {
                                
//                                NSNumber *objNo = [NSNumber numberWithInteger:lineIndex];
                                
                                [[NSNotificationCenter defaultCenter]postNotificationName:@"showlastPageAd" object:nil];
                            }
                            
                            if (content) {
                                break;
                            }
                            
                        }
                    }
                }
            }
            
            
            
            CTFrameDraw(frame, c);
            
            if (block) {
                if (content) {
                    block(content, QWCoreTextContentTypeCustom);
                }
                else {
                    UIImage *temp = UIGraphicsGetImageFromCurrentImageContext();
                    block(temp, QWCoreTextContentTypeContent);
                }
            }
            
            break;
        } while (0);
        
    }
    
    if (frame) {
        CFRelease(frame);
    }
    
    CFRelease(path);
    CFRelease(framesetter);
    
    UIGraphicsEndImageContext();
    [[NSNotificationCenter defaultCenter]postNotificationName:@"aloudStrPost" object:attributedString];
    return NSMakeRange(currentRange.location, currentRange.length);
}


+ (CGRect)getLineBounds:(CTLineRef)line point:(CGPoint)point {
    //配置line行的位置信息
    CGFloat ascent = 0;
    CGFloat descent = 0;
    CGFloat leading = 0;
    //在获取line行的宽度信息的同时得到其他信息
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    return CGRectMake(point.x, point.y, width, height);
}
@end

@implementation NSMutableAttributedString (QWCoreGraphicHelper)

- (NSMutableAttributedString *)stringByAppendingNewline
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"\n" attributes:@{}];
    
    [self appendAttributedString:string];
    return self;
}

- (NSMutableAttributedString *)stringByAppendingNewlineString:(NSString *)string andType:(QWReadingAttributeType)type
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:[[QWReadingConfig sharedInstance] attributesWithType:type]];
    [self appendAttributedString:attributedString];
    [self stringByAppendingNewline];
    
    if (type == QWReadingAttributeTypeSubtitle) {
        [self stringByAppendingNewline];
    }
    
    return self;
}
-(void)tagStrWithStr:(NSNotification *)noc{
    NSLog(@"真正标记的字符串 = %@",noc.object);
    
}
- (NSMutableAttributedString *)ttsStr:(NSString*)string oringStr:(NSString*)oringStr andType:(QWReadingAttributeType)type{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:oringStr attributes:[[QWReadingConfig sharedInstance] attributesWithType:type]];
    
    [attributedString addAttribute:(id)kCTForegroundColorAttributeName value:(id)[UIColor blueColor].CGColor range:[oringStr rangeOfString:string]];
    [self appendAttributedString:attributedString];
    [self stringByAppendingNewline];
    if (type == QWReadingAttributeTypeSubtitle) {
        [self stringByAppendingNewline];
    }
    return self;
}

- (NSMutableAttributedString *)stringByAppendingPlaceholerRect:(CGRect)rect content:(id)content
{
    
    NSMutableDictionary *params = @{kQWPlaceholderRectAttributeName: [NSValue valueWithCGRect:rect], kQWPlaceholderContentAttributeName: content, (NSString *)kCTForegroundColorAttributeName: [UIColor clearColor]}.mutableCopy;
    
    CTRunDelegateCallbacks callbacks;
    callbacks.version       = kCTRunDelegateVersion1;
    callbacks.getAscent     = ascentCallback;
    callbacks.getDescent    = descentCallback;
    callbacks.getWidth      = widthCallback;
    callbacks.dealloc       = deallocCallback;
    
    void *rectValue = (__bridge_retained void *)[NSValue valueWithCGRect:rect];
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, rectValue);
    
    params[(NSString *)kCTRunDelegateAttributeName] = (__bridge id)delegate;
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"*" attributes:params];
    
    CFRelease(delegate);
    
    [self appendAttributedString:string];
    [self stringByAppendingNewline];
    return self;
}

- (NSMutableAttributedString *)stringByAppendingAdRect:(CGRect)rect content:(id)content
{
    [self stringByAppendingNewline];
    NSMutableDictionary *params = @{kQWPlaceholderRectAttributeName: [NSValue valueWithCGRect:rect], kQWPlaceholderAdViewAttributeName: content, (NSString *)kCTForegroundColorAttributeName: [UIColor clearColor]}.mutableCopy;
    
    CTRunDelegateCallbacks callbacks;
    callbacks.version       = kCTRunDelegateVersion1;
    callbacks.getAscent     = ascentCallback;
    callbacks.getDescent    = descentCallback;
    callbacks.getWidth      = widthCallback;
    callbacks.dealloc       = deallocCallback;
    
    void *rectValue = (__bridge_retained void *)[NSValue valueWithCGRect:rect];
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, rectValue);
    
    params[(NSString *)kCTRunDelegateAttributeName] = (__bridge id)delegate;
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"*" attributes:params];
    
    CFRelease(delegate);
    
    [self appendAttributedString:string];
    
    return self;
}

@end
