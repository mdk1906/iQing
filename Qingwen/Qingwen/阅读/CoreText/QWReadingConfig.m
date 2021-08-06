//
//  QWReadingConfig.m
//  Qingwen
//
//  Created by Aimy on 7/6/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWReadingConfig.h"

#import <CoreText/CoreText.h>
#import "QWFileManager.h"

NSString * const QWREADING_CHANGED = @"QWREADING_CHANGED";

@interface QWReadingConfig ()

@property (nonatomic) CGRect readingBounds;//当前的可读的屏幕范围（去掉边框）
@property (nonatomic) CGRect imageBounds;//当前的可读的屏幕范围（去掉边框）

@property (nonatomic) CGRect adBounds;//插屏广告
@property (nonatomic) NSInteger fontSize;//当前字体大小

@property (nonatomic, copy) UIColor *readingColor;//根据背景颜色切换阅读界面字体颜色

@property (nonatomic, copy) UIColor *statusColor; //根据背景颜色切换状态栏颜色

@property (nonatomic, copy) UIFont *titleFont;//当前的标题字体
@property (nonatomic, copy) UIFont *subtitleFont;//当前的副标题字体
@property (nonatomic, copy) UIFont *font;//当前的字体
@property (nonatomic, copy) UIColor *aloudColor;//根据背景颜色切换朗读biao'ji界面字体颜色


@end

@implementation QWReadingConfig

static QWReadingConfig * __singleton__;

+ (QWReadingConfig *)sharedInstance
{
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        [QWReadingConfig loadData];
    });
    return __singleton__;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_readingBG forKey:@"_readingBG"];
    [aCoder encodeInteger:_fontSize forKey:@"_fontSize"];
    [aCoder encodeFloat:_systemBrightness forKey:@"systemBrightness"];
    [aCoder encodeFloat:_brightness forKey:@"_brightness"];
    [aCoder encodeBool:_useSystemBrightness forKey:@"_useSystemBrightness"];
    [aCoder encodeBool:_traditional forKey:@"_traditional"];
    [aCoder encodeBool:_originalFont forKey:@"_originalFont"];
    [aCoder encodeBool:_alwaysBrightness forKey:@"_alwaysBrightness"];
    [aCoder encodeBool:_showDanmu forKey:@"_showDanmu"];
    
//    [aCoder encodeBool:_boyAloud forKey:@"_boyAloud"];
//    [aCoder encodeBool:_girlAloud forKey:@"_girlAloud"];
//    [aCoder encodeBool:_aloudSpeed forKey:@"_aloudSpeed"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [self init]) {
        _readingBG = [aDecoder decodeIntegerForKey:@"_readingBG"];
        _fontSize = [aDecoder decodeIntegerForKey:@"_fontSize"];
        _systemBrightness = [aDecoder decodeFloatForKey:@"systemBrightness"];
        _brightness = [aDecoder decodeFloatForKey:@"_brightness"];
        _useSystemBrightness = [aDecoder decodeBoolForKey:@"_useSystemBrightness"];
        _traditional = [aDecoder decodeBoolForKey:@"_traditional"];
        _originalFont = [aDecoder decodeBoolForKey:@"_originalFont"];
        _alwaysBrightness = [aDecoder decodeBoolForKey:@"_alwaysBrightness"];
        _showDanmu = [aDecoder decodeBoolForKey:@"_showDanmu"];
//        _boyAloud = [aDecoder decodeObjectForKey:@"_boyAloud"];
//        _girlAloud = [aDecoder decodeObjectForKey:@"_girlAloud"];
//        _aloudSpeed = [aDecoder decodeIntegerForKey:@"_aloudSpeed"];
    }

    return self;
}

- (void)setReadingBG:(QWReadingBG)readingBG
{
    _readingBG = readingBG;
    [self changeAttributes];
}

- (CGRect)readingBounds
{
    if (UISCREEN_HEIGHT == 812.f || UISCREEN_HEIGHT == 896.f) {
        if (self.showDanmu) {
            return CGRectMake(0, 0, [QWSize screenWidth:self.landscape], [QWSize screenHeight:self.landscape] - self.danmuHeight -43 - 50 - 24);
        } else {
            
            return CGRectMake(0, 0, [QWSize screenWidth:self.landscape], [QWSize screenHeight:self.landscape] -43 - 50 - 24 );
            
        }
    }
    else{
        if (self.showDanmu) {
            return CGRectMake(0, 0, [QWSize screenWidth:self.landscape] - 30, [QWSize screenHeight:self.landscape] - 50 - self.danmuHeight - 43);
        } else {
            
            return CGRectMake(0, 0, [QWSize screenWidth:self.landscape] - 30, [QWSize screenHeight:self.landscape] - 50 - 43);
            
        }
    }
    
}

- (CGRect)imageBounds
{
    return CGRectInset([self readingBounds], 1, 1);
//    return CGRectMake(0, 0, UISCREEN_WIDTH, 200);
}
- (CGRect)adBounds{
    
    if (UISCREEN_HEIGHT == 812.f || UISCREEN_HEIGHT == 896.f) {
        
        return CGRectMake(0, 0, UISCREEN_WIDTH-30, (UISCREEN_WIDTH-30)*0.43 + 90);
    }
    else{
        return CGRectMake(0, 0, UISCREEN_WIDTH-30, (UISCREEN_WIDTH-30)*0.43 + 72);
    }
}

- (CGFloat)danmuHeight {
    return 74;
}

- (NSArray *)fontSzieString
{
    return @[@"12", @"14", @"16", @"18", @"20", @"22", @"24", @"26", @"28", @"30", @"32"];
}

static NSDictionary *titleAttributes = nil;
static NSDictionary *subtitleAttributes = nil;
static NSDictionary *contentAttributes = nil;
static UIFont *font = nil;

- (void)changeAttributes
{
    titleAttributes = nil;
    subtitleAttributes = nil;
    contentAttributes = nil;
    font = nil;
}

- (BOOL)changeFont:(BOOL)small
{
    if ([self canChangeFont:small]) {
        NSInteger index = [self.fontSzieString indexOfObject:@(self.fontSize).stringValue];
        if (small) {
            self.fontSize = [[self.fontSzieString objectAtIndex:index - 1] integerValue];
        }
        else {
            self.fontSize = [[self.fontSzieString objectAtIndex:index + 1] integerValue];
        }

        [self changeAttributes];

        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)canChangeFont:(BOOL)small
{
    NSInteger index = [self.fontSzieString indexOfObject:@(self.fontSize).stringValue];
    if (small) {
        return index > 0;
    }
    else {
        return index + 1 < self.fontSzieString.count;
    }
}

- (BOOL)changeFontToSize:(NSString * __nonnull)size
{
    NSInteger index = [self.fontSzieString indexOfObject:size];
    if (index == NSNotFound) {
        return NO;
    }

    self.fontSize = size.integerValue;
    [self changeAttributes];
    return YES;
}

- (UIImage *)readingBgImage {
    switch ([QWReadingConfig sharedInstance].readingBG) {
        case QWReadingBGDefault:
            return [UIImage imageNamed:@"reading_bg_1"];
            break;
        case QWReadingBGBlack:
            return [UIImage imageNamed:@"reading_bg_2"];
            break;
        case QWReadingBGGreen:
            return [UIImage imageWithColor:HRGB(0xceefce)];
            break;
        case QWReadingBGPink:
            return [UIImage imageWithColor:HRGB(0xfcdfe7)];
            break;
        default:
            return [UIImage imageNamed:@"reading_bg_1"];
            break;
    }
}


- (NSDictionary *)attributesWithType:(QWReadingAttributeType)type
{
    if (type == QWReadingAttributeTypeTitle) {
        if (titleAttributes) {
            return titleAttributes;
        }

        //文本居中
        CTTextAlignment alignment = kCTTextAlignmentCenter;

        //行距
        CGFloat linespace = 12.5;

        //组合设置
        CTParagraphStyleSetting settings[] = {
            { kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &alignment},//文本居中
            { kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &linespace },//行间距
            { kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &linespace },//最大行间距
            { kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &linespace },//最小行间距
        };

        //通过设置项产生段落样式对象
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings) / sizeof(CTParagraphStyleSetting));

        titleAttributes = @{(NSString *)kCTFontAttributeName: self.titleFont, (NSString *)kCTParagraphStyleAttributeName: (__bridge id)paragraphStyle, (NSString *)kCTForegroundColorAttributeName: [QWReadingConfig sharedInstance].readingColor,(NSString *)kCTKernAttributeName: @0.5};

        CFRelease(paragraphStyle);

        return titleAttributes;
    }
    else if (type == QWReadingAttributeTypeSubtitle) {
        if (subtitleAttributes) {
            return subtitleAttributes;
        }

        //文本居中
        CTTextAlignment alignment = kCTTextAlignmentCenter;

        //行距
        CGFloat linespace = 10.0;

        //组合设置
        CTParagraphStyleSetting settings[] = {
            { kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &alignment},//文本居中
            { kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &linespace },//行间距
            { kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &linespace },//最大行间距
            { kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &linespace },//最小行间距
        };

        //通过设置项产生段落样式对象
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings) / sizeof(CTParagraphStyleSetting));

        subtitleAttributes = @{(NSString *)kCTFontAttributeName: self.subtitleFont, (NSString *)kCTParagraphStyleAttributeName: (__bridge id)paragraphStyle, (NSString *)kCTForegroundColorAttributeName: [QWReadingConfig sharedInstance].readingColor};

        CFRelease(paragraphStyle);

        return subtitleAttributes;
    }
    else if (type == QWReadingAttributeTypeContent) {
        if (contentAttributes) {
            return contentAttributes;
        }

        //首行缩进
        CGFloat fristlineindent = 30;

        //段缩进
        CGFloat headindent = 0.0f;

        //段尾缩进
        CGFloat tailindent = 0.0f;

        //行距
        CGFloat linespace = 10.0;

        //组合设置
        CTParagraphStyleSetting settings[] = {
            { kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(CGFloat), &fristlineindent},//首行缩进
            { kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &linespace },//行间距
            { kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &linespace },//最大行间距
            { kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &linespace },//最小行间距
            { kCTParagraphStyleSpecifierHeadIndent, sizeof(CGFloat), &headindent},//段首缩进
            { kCTParagraphStyleSpecifierTailIndent, sizeof(CGFloat), &tailindent},//段尾缩进
        };

        //通过设置项产生段落样式对象
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings) / sizeof(CTParagraphStyleSetting));

        contentAttributes = @{(NSString *)kCTFontAttributeName: self.font, (NSString *)kCTParagraphStyleAttributeName: (__bridge id)paragraphStyle, (NSString *)kCTForegroundColorAttributeName: [QWReadingConfig sharedInstance].readingColor};
        
        CFRelease(paragraphStyle);
        
        return contentAttributes;
    }

    return nil;
}

- (UIColor *)readingColor
{
    switch ([QWReadingConfig sharedInstance].readingBG) {
        case QWReadingBGDefault:
            return HRGB(0x3f3528);
        case QWReadingBGBlack:
            return HRGB(0x888882);
        case QWReadingBGGreen:
            return HRGB(0x313d31);
        case QWReadingBGPink:
            return HRGB(0xb54660);
        default:
            return HRGB(0x3f3528);
    }
}
- (UIColor *)aloudColor
{
    switch ([QWReadingConfig sharedInstance].readingBG) {
        case QWReadingBGDefault:
            return HRGB(0x6A8D5F);
        case QWReadingBGBlack:
            return HRGB(0x1E1B1B);
        case QWReadingBGGreen:
            return HRGB(0x9CC59C);
        case QWReadingBGPink:
            return HRGB(0xFEFEFE);
        default:
            return HRGB(0x6A8D5F);
    }
}
- (UIColor *)statusColor
{
    switch ([QWReadingConfig sharedInstance].readingBG) {
        case QWReadingBGDefault:
            return HRGB(0x6A5B45);
        case QWReadingBGBlack:
            return HRGB(0x8A8A87);
        case QWReadingBGGreen:
            return HRGB(0x6F806C);
        case QWReadingBGPink:
            return HRGB(0xD37E92);
        default:
            return HRGB(0x6A5B45);
    }
}

- (UIFont *)titleFont
{
    return [UIFont boldSystemFontOfSize:self.subtitleFont.pointSize + 4];
}

- (UIFont *)subtitleFont
{
    return [UIFont boldSystemFontOfSize:self.font.pointSize + 4];
}

- (UIFont *)font
{
    if (!font) {
        font = [UIFont systemFontOfSize:self.fontSize];
    }
    return font;
}

+ (void)loadData
{
    NSString *archivingFilePath = [[QWFileManager qingwenPath] stringByAppendingPathComponent:@"reading_conig.archiver"];//添加储存的文件名
    NSData *data = [[NSMutableData alloc] initWithContentsOfFile:archivingFilePath];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    __singleton__ = [unarchiver decodeObjectForKey:@"reading_config"];
    if (!__singleton__) {
         __singleton__ = [[QWReadingConfig alloc] init];
        if (IS_IPAD_DEVICE) {
            __singleton__.fontSize = 20.0f;
        }
        else {
            __singleton__.fontSize = 16.f;
        }
        __singleton__.brightness = [UIScreen mainScreen].brightness;
        __singleton__.useSystemBrightness = YES;
        __singleton__.alwaysBrightness = YES;
    }

    if (__singleton__.fontSize < 12 || __singleton__.fontSize > 32) {
        if (IS_IPAD_DEVICE) {
            __singleton__.fontSize = 20.0f;
        }
        else {
            __singleton__.fontSize = 16.f;
        }
    }

    [unarchiver finishDecoding];
}

- (void)saveData
{
    NSString *archivingFilePath = [[QWFileManager qingwenPath] stringByAppendingPathComponent:@"reading_conig.archiver"];//添加储存的文件名
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:[[NSMutableData alloc] initWithContentsOfFile:archivingFilePath]];
    QWReadingConfig *config = [unarchiver decodeObjectForKey:@"reading_config"];
    BOOL change = NO;
    if ([QWReadingConfig sharedInstance].readingBG != config.readingBG ||
        [QWReadingConfig sharedInstance].traditional != config.traditional ||
        [QWReadingConfig sharedInstance].originalFont != config.originalFont ||
        [QWReadingConfig sharedInstance].fontSize != config.fontSize || [QWReadingConfig sharedInstance].showDanmu != config.showDanmu) {
        change = YES;
    }

    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self forKey:@"reading_config"];
    [archiver finishEncoding];
    [data writeToFile:archivingFilePath atomically:YES];

    if (change) {
        [[NSNotificationCenter defaultCenter] postNotificationName:QWREADING_CHANGED object:nil];
    }
}

@end
