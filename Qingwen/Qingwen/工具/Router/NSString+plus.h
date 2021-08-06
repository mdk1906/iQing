//
//  NSString+plus.h
//  Qingwen
//
//  Created by Aimy on 8/27/14.
//  Copyright (c) 2014 Qingwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (plus)

- (NSUInteger)byteCount;

/**
 *  NSString转为NSNumber
 *
 *  @return NSNumber
 */
- (NSNumber*)toNumber;
/**
 *  urlencoding
 *
 *  @return 
 */
- (NSString *)urlEncoding;
/**
 *  urldecoding
 *
 *  @return
 */
- (NSString *)urlDecoding;
/**
 *  url encoding所有字符
 *
 *  @return
 */
- (NSString *)urlEncodingAllCharacter;

/**
 *  功能:html语句居中处理
 */
- (NSString *)makeHtmlAlignCenter;

/**
 *  功能:拼装2个组合字串(知道首字串长度)
 */
- (NSAttributedString *)attributedStringWithHeadAttributes:(NSDictionary *)aAttributes
                                            tailAttributes:(NSDictionary *)bAttributes
                                                headLength:(NSUInteger)aLength;

/**
 *  功能:拼装2个组合字串(知道尾字串长度)
 */
- (NSAttributedString *)attributedStringWithHeadAttributes:(NSDictionary *)aAttributes
                                            tailAttributes:(NSDictionary *)bAttributes
                                                tailLength:(NSUInteger)aLength;

/**
 *  功能:拼装3个组合字串(知道首尾长度)
 */
- (NSAttributedString *)attributedStringWithHeadAttributes:(NSDictionary *)aAttributes
                                             midAttributes:(NSDictionary *)bAttributes
                                            tailAttributes:(NSDictionary *)cAttributes
                                                headLength:(NSUInteger)aLength
                                                tailLength:(NSUInteger)cLength;

/**
 *  替换字符串中指定的内容
 *
 *  @param fromAry    扫描字符串
 *  @param replaceAry 用于替换的字符串
 *
 *  @return 返回的结果
 */
- (NSString *)replaceFromArray:(NSArray *)fromAry withArray:(NSArray *)replaceAry;

/**
 *  功能:版本号比较
 */
- (NSComparisonResult)versionCompare:(NSString *)aString;

@end
