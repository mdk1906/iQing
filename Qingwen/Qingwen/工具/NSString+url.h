//
//  NSString+url.h
//  Qingwen
//
//  Created by 二零一四的天空 on 16/6/3.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (url)
- (BOOL)isEmpty;
/**
 *  string找出含有的URL 并处理
 */
- (NSMutableAttributedString * _Nullable)matchURlString:(NSString * _Nullable)string;
/**
 *  输入字符串，输出URL的数组
 *  @param string 输入一个NSString
 */
- (NSArray * _Nullable)matchURlArray:(NSString * _Nullable)string;
/**
 *  组装本地方法url
 *  @return  返回mapping + 传人Vo的字典数组
 */
+ (NSString * _Nullable)getRouterVCUrlStringFromUrlString:(NSString * _Nullable)urlString;

/**
 @return 判断返回是书或者演绘
 */
- (QWReadingType)readingType;

- (NSString * _Nonnull)routerKey;
@end
