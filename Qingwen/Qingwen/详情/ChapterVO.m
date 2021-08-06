//
//  ChapterVO.m
//  Qingwen
//
//  Created by Aimy on 7/6/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "ChapterVO.h"

#import "QWCoreTextHelper.h"
#import "QWReadingConfig.h"
#import "QWReadingManager.h"
#import "BookCD.h"

@implementation ChapterVO
@synthesize framesetter = _framesetter;

- (instancetype)init
{
    self = [super init];
    self.bookPages = @{}.mutableCopy;
    self.readingBG = [QWReadingConfig sharedInstance].readingBG;
    return self;
}

- (NSString *)points {
    NSNumber *points = [_points toNumberIfNeeded];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    formatter.roundingMode = NSNumberFormatterRoundFloor;
    formatter.maximumFractionDigits = 2;
    return [formatter stringFromNumber:points];
}

- (CTFramesetterRef)framesetter
{
    if ( ! _framesetter) {
        NSAttributedString *tempAttributedString = self.attributedString.copy;
        _framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)tempAttributedString);
    }
    
    return _framesetter;
}

- (BOOL)isFirstChapter
{
    return self.chapterIndex == 0;
}

- (void)configChapter
{
    if (self.completed) {
        return ;
    }
    
    @synchronized(self) {
        if (_framesetter) {
            CFRelease(_framesetter);
            _framesetter = nil;
        }
    }
    
    self.readingBG = [QWReadingConfig sharedInstance].readingBG;
    self.fontSize = [QWReadingConfig sharedInstance].fontSize;
    self.traditional = [QWReadingConfig sharedInstance].traditional;
    self.landscape = [QWReadingConfig sharedInstance].landscape;
    self.originalFont = [QWReadingConfig sharedInstance].originalFont;
    self.showDanmu = [QWReadingConfig sharedInstance].showDanmu;
    
    WEAK_SELF;
    ContentVO *vo = self.contentVO;
    //    if(self.originalFont && self.originalContentVO != nil){
    //        vo = self.originalContentVO;
    //    }
    
    NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
    [attributedString appendAttributedString:[[NSMutableAttributedString new] stringByAppendingPlaceholerRect:[QWReadingConfig sharedInstance].imageBounds content:kQWPlaceholderChapterAttributeName]];
    
    [vo.results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        @autoreleasepool {
            STRONG_SELF;
            
            ContentItemVO *itemVO = obj;
            NSMutableAttributedString *string = [NSMutableAttributedString new];
            
            if (itemVO.type.integerValue == 1) {//图片
                [string stringByAppendingPlaceholerRect:[QWReadingConfig sharedInstance].imageBounds content:itemVO.value];
            }
            else {
                NSString *crypt = [[QWBannedWords sharedInstance] cryptoStringWithText:[itemVO.value stringWithType:self.traditional Origin:self.originalFont]];
                [string stringByAppendingNewlineString:crypt andType:QWReadingAttributeTypeContent];
            }
            
            [attributedString appendAttributedString:string];
            
#ifndef DEBUG
            if (!itemVO.value.length) {
                StatisticVO *statistic = [StatisticVO new];
                statistic.bookId = [QWReadingManager sharedInstance].bookCD.nid.stringValue;
                statistic.chapterId = self.nid.stringValue;
                statistic.contentUrl = self.content_url;
                statistic.contentItemId = itemVO.nid.stringValue;
                statistic.type = itemVO.type.stringValue;
                [[BaiduMobStat defaultStat] logEvent:@"contentEmpty" eventLabel:statistic.toJSONString];
            }
#endif
        }
    }];
    
    NSMutableArray *page1 = [NSMutableArray new];
    NSAttributedString *tempAttributedString = attributedString.copy;
    CTFramesetterRef framesetter1 = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)tempAttributedString);
    page1 = [QWCoreTextHelper getPageCountAndConfigPageWithAttributedString:attributedString inDrawRect:[QWReadingConfig sharedInstance].readingBounds inTextRect:[QWReadingConfig sharedInstance].readingBounds framesetter:framesetter1];
    int insert = [self.insert_page intValue];
    for (int i =0; i<page1.count;i++ ) {
        BookPageVO *page = page1[i];
        if (insert != 0) {
            NSLog(@"insert = %d self.insert_ad = %d [QWReadingManager sharedInstance].offline =%@",insert,[self.insert_ad intValue],[QWReadingManager sharedInstance].offline?@"yes":@"no");
            if (i % insert == 0 && [self.insert_ad intValue] == 1 && i != 0 &&[QWReadingManager sharedInstance].offline == NO) {
                NSMutableAttributedString *string = [NSMutableAttributedString new];
                NSInteger location = page.range.location;
                NSInteger length = page.range.length;
                NSString* str= [NSString stringWithFormat:@"%@",attributedString.string];
                NSString *strJieQu1 = [str substringFromIndex:location];
                NSString *strJieQu2 = [strJieQu1 substringToIndex:length];
                NSArray *contentArr = [NSArray new];
                contentArr = [strJieQu2 componentsSeparatedByString:@"\n"];
                NSString *firstStr = contentArr[0];
                if ([firstStr isEqualToString:@""]) {
                    return;
                }
                NSRange nowrange = [attributedString.string rangeOfString:firstStr];
                int index = (int)nowrange.location + (int)nowrange.length;
                [string stringByAppendingAdRect:[QWReadingConfig sharedInstance].adBounds content:@"chapterAd"];
                [attributedString insertAttributedString:string atIndex:index];
                
            }
        }
    }
    
    if ([self.lastPageAd intValue] == 0 && self.lastPageAd != nil) {
        NSMutableAttributedString *string = [NSMutableAttributedString new];
        [string stringByAppendingAdRect:[QWReadingConfig sharedInstance].imageBounds content:@"lastPageAd"];
        [attributedString appendAttributedString:string];
    }
    
    self.attributedString = attributedString;
    
    
    NSMutableArray *pages = @[].mutableCopy;
    self.pageCount = [QWCoreTextHelper getPageCountAndConfigPage:pages andAttributedString:self.attributedString inDrawRect:[QWReadingConfig sharedInstance].readingBounds inTextRect:[QWReadingConfig sharedInstance].readingBounds framesetter:self.framesetter];
    [pages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        STRONG_SELF;
        BookPageVO *page = obj;
        page.volumeId = self.volumeId;
        page.chapterIndex = self.chapterIndex;
        page.pageIndex = idx;
        self.bookPages[@(page.pageIndex)] = page;
        NSLog(@"page123 = %@", page);
    }];
    self.completed = YES;
    
}

- (void)clearChapter
{
    _completed = NO;
    _attributedString = nil;
    
    @synchronized(self) {
        if (_framesetter) {
            CFRelease(_framesetter);
            _framesetter = nil;
        }
    }
    
    [_bookPages removeAllObjects];
    _pageCount = 0;
}

- (void)dealloc
{
    [self clearChapter];
}
- (UIImage *)convertViewToImage:(UIView *)view {
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
    
}

@end
