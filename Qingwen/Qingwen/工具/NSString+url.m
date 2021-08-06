//
//  NSString+url.m
//  Qingwen
//
//  Created by 二零一四的天空 on 16/6/3.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import "NSString+url.h"

@implementation NSString (url)

- (BOOL)isEmpty {
    if ([self isEqualToString:@""] || !self) {
        return true;
    }
    return false;
}

- (NSMutableAttributedString *)matchURlString:(NSString *)string {
    
    NSError *error;
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:string];
    NSString *regulaStr = @"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        
        [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:match.range];
        [attriString addAttribute:(NSString *)kCTUnderlineStyleAttributeName
                            value:(id)[NSNumber numberWithInt:kCTUnderlineStyleSingle]
                            range:match.range];
    }
    
    return attriString;
}

- (NSArray *)matchURlArray:(NSString *)string {
    
    NSError *error;
    NSString *regulaStr = @"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    
    return arrayOfAllMatches;
}

+ (NSString *)getRouterVCUrlStringFromUrlString:(NSString *)urlString {
    
    if ([urlString isEmpty]) {
        return nil;
    }
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *urlHost = url.host;
    if ([QWScheme isEqualToString:url.scheme]){
        return urlString;
    }

    
#if DEBUG
    if(([urlHost rangeOfString:@"menma"].location == NSNotFound)
       && !([urlHost isEqualToString:@"m.iqing.in"])
       && !([urlHost isEqualToString:@"www.iqing.com"])
       && !([urlHost isEqualToString:@"www.iqing.in"])
       && !([urlHost isEqualToString:@"m.iqing.com"])) {
        return  urlString;
    }
#else
    if (!([urlHost isEqualToString:@"m.iqing.in"])
        && !([urlHost isEqualToString:@"www.iqing.com"])
        && !([urlHost isEqualToString:@"www.iqing.in"])
        && !([urlHost isEqualToString:@"m.iqing.com"])) {
        return  urlString;
    }
#endif

    if ([urlString rangeOfString:@"iqing"].location == NSNotFound) {
        
        return urlString;
    }
    
    if (!([urlString rangeOfString:@"book"].location == NSNotFound)){
        return [urlString getBookRouterUrl];
    }
    if (!([urlString rangeOfString:@"favorite"].location == NSNotFound)){
        return [urlString getFavoriteRouterUrl];
    }
    if (!([urlString rangeOfString:@"/read"].location == NSNotFound)){
        return [urlString getReadingRouterUrl];
    }
    if (!([urlString rangeOfString:@"/play/"].location == NSNotFound)){
        return [urlString getGameRouterUrl];
    }
    if (!([urlString rangeOfString:@"/u/"].location == NSNotFound)) {
        return [urlString getProfileRouterUrl];
    }
    if (!([urlString rangeOfString:@"/forum/"].location == NSNotFound)) {
        return [urlString getBrandRouterUrl];
    }
    if (!([urlString rangeOfString:@"aid="].location == NSNotFound)) {
        return [urlString getActivityRouterUrl];
    }
    if (!([urlString rangeOfString:@"/actopic/"].location == NSNotFound)) {
        return [urlString getActivity1RouterUrl];
    }
    if (!([urlString rangeOfString:@"/subject/"].location == NSNotFound)) {
        return [urlString getTopikkuRouterUrl];
    }
    if (!([urlString rangeOfString:@"/thread/"].location == NSNotFound)) {
        return [urlString getThreadRouterUrl];
    }
    if (!([urlString rangeOfString:@"discussdetail"].location == NSNotFound)) {
        return [urlString getDiscussdetailRouterURL];
    }
    
    
    return [urlString getWebRouterUrl];
}


/**
 格式化特殊字符串

 @param pattern 正则匹配的模式
 @param prefix 需要替换的前缀
 @return 客户端需要用到的RouteValue
 */
- (NSString *)getRouterValueWithPattern: (NSString *)pattern prefix: (NSString *)prefix{
    NSRange range = NSMakeRange(0, self.length);
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSTextCheckingResult *result = [regex firstMatchInString:self options:NSMatchingReportProgress range:range];
    if (result) {
        NSString *bookId = [self substringWithRange:result.range];
        if (prefix) { //需要替换
            return [bookId stringByReplacingOccurrencesOfString:prefix withString:@""];
        }
        return bookId;
    }
    return nil;
}

- (NSString *)getBookRouterUrl {
    NSString * pattern = @"/book/[0-9]+";
    NSString *value = [self getRouterValueWithPattern:pattern prefix:@"/book/"];
    NSMutableDictionary *params = @{}.mutableCopy;
    if (value) {
        params[@"id"] = value;
        return [NSString getRouterVCUrlStringFromUrlString:@"book" andParams:params];
    }
    else {
        return [self getWebRouterUrl];
    }
}

- (NSString *)getFavoriteRouterUrl {
    NSString * pattern = @"/favorite/[0-9]+";
    NSString *value = [self getRouterValueWithPattern:pattern prefix:@"/favorite/"];
    NSMutableDictionary *params = @{}.mutableCopy;
    if (value) {
        params[@"id"] = value;
        return [NSString getRouterVCUrlStringFromUrlString:@"favorite" andParams:params];
    }
    else {
        return [self getWebRouterUrl];
    }
}

- (NSString *)getReadingRouterUrl {
    NSString * pattern = @"/read/[0-9]+";
    NSString *value = [self getRouterValueWithPattern:pattern prefix:@"/read/"];
    NSMutableDictionary *params = @{}.mutableCopy;
    if (value) {
        params[@"chapter_id"] = value;
        return [NSString getRouterVCUrlStringFromUrlString:@"reading" andParams:params];
    }
    else {
        return [self getWebRouterUrl];
    }
}


- (NSString *)getGameRouterUrl {
    NSString * pattern = @"/play/[0-9]+";
    NSString *value = [self getRouterValueWithPattern:pattern prefix:@"/play/"];
    NSMutableDictionary *params = @{}.mutableCopy;
    if (value) {
        params[@"book_url"] = [NSString stringWithFormat:@"%@/game/%@/",[QWOperationParam currentDomain],value];
        return [NSString getRouterVCUrlStringFromUrlString:@"gamedetail" andParams:params];
    }
    else {
        return [self getWebRouterUrl];
    }
}

- (NSString *)getBrandRouterUrl {
    NSString * pattern = @"/forum/[a-zA-Z0-9]+";
    NSString *value = [self getRouterValueWithPattern:pattern prefix:@"/forum/"];
    NSMutableDictionary *params = @{}.mutableCopy;
    if (value) {
        NSString *discussUrl = [NSString stringWithFormat:@"%@/brand/%@/",[QWOperationParam currentBfDomain],value];
        params[@"url"] = discussUrl;
        return [NSString getRouterVCUrlStringFromUrlString:@"discuss" andParams:params];

    }
    else {
        return [self getWebRouterUrl];
    }
}

- (NSString *)getThreadRouterUrl {
    NSString * pattern = @"/thread/[a-zA-Z0-9]+";
    NSString *value = [self getRouterValueWithPattern:pattern prefix:@"/thread/"];
    NSMutableDictionary *params = @{}.mutableCopy;
    if (value) {
        NSString *discussUrl = [NSString stringWithFormat:@"%@/v3/post/%@/",[QWOperationParam currentBfDomain],value];
        params[@"url"] = discussUrl;
        return [NSString getRouterVCUrlStringFromUrlString:@"discussdetail" andParams:params];
        
    }
    else {
        return [self getWebRouterUrl];
    }
}

-(NSString * )getDiscussdetailRouterURL{
    NSString * pattern = @"/post/[a-zA-Z0-9]+";
    NSString *value = [self getRouterValueWithPattern:pattern prefix:@"/thread/"];
    NSMutableDictionary *params = @{}.mutableCopy;
    if (value) {
        NSString *discussUrl = [NSString stringWithFormat:@"%@/v3%@/",[QWOperationParam currentBfDomain],value];
        params[@"url"] = discussUrl;
        return [NSString getRouterVCUrlStringFromUrlString:@"discussdetail" andParams:params];
        
    }
    else {
        return [self getWebRouterUrl];
    }
}
- (NSString *)getActivityRouterUrl {
    NSString * pattern = @"aid=\\d+";
    NSString *value = [self getRouterValueWithPattern:pattern prefix:@"aid="];
    NSMutableDictionary *params = @{}.mutableCopy;
    if (value) {
        NSString *activityUrl = [NSString stringWithFormat:@"%@/activity/%@/",[QWOperationParam currentDomain],value];
        params[@"activity"] = activityUrl;
        return [NSString getRouterVCUrlStringFromUrlString:@"actopic" andParams:params];
    }
    else {
        return [self getWebRouterUrl];
    }
}
- (NSString *)getActivity1RouterUrl {
    NSString * pattern = @"/actopic/\\d+";
    NSString *value = [self getRouterValueWithPattern:pattern prefix:@"/actopic/"];
    NSMutableDictionary *params = @{}.mutableCopy;
    if (value) {
        NSString *activityUrl = [NSString stringWithFormat:@"%@/activity/%@/",[QWOperationParam currentDomain],value];
        params[@"activity"] = activityUrl;
        return [NSString getRouterVCUrlStringFromUrlString:@"actopic" andParams:params];

    }
    else {
        return [self getWebRouterUrl];
    }
}


- (NSString *)getProfileRouterUrl {
    NSString * pattern = @"/u/[a-zA-Z0-9]+";
    NSString *value = [self getRouterValueWithPattern:pattern prefix:@"/u/"];
    NSMutableDictionary *params = @{}.mutableCopy;
    if (value) {
        NSString *profileUrl = [NSString stringWithFormat:@"https://box.iqing.in/user/%@/profile/",value];
        params[@"profile_url"] = profileUrl;
        return [NSString getRouterVCUrlStringFromUrlString:@"user" andParams:params];
    }
    else {
        return [self getWebRouterUrl];
    }
}

- (NSString *)getTopikkuRouterUrl {
    NSString * pattern = @"/subject/[a-zA-Z0-9]+";
    NSString *value = [self getRouterValueWithPattern:pattern prefix:@"/subject/"];
    NSMutableDictionary *params = @{}.mutableCopy;
    if (value) {
        NSString *topikkuUrl = [NSString stringWithFormat:@"%@/topikku/%@/",[QWOperationParam currentDomain],value];
        params[@"activity"] = topikkuUrl;
        params[@"topic"] = @1;
        return [NSString getRouterVCUrlStringFromUrlString:@"actopic" andParams:params];
    }
    else {
       return [self getWebRouterUrl];
    }
}

- (NSString *)getWebRouterUrl {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"url"] = self;
    return [NSString getRouterVCUrlStringFromUrlString:@"web" andParams:params];
}
- (QWReadingType)readingType;
 {
    if ([self isEmpty]) {
        return QWReadingTypeOther;
    }
    
    if (!([self rangeOfString:@"/book/"].location == NSNotFound)) {
        return QWReadingTypeBook;
    }
    if (!([self rangeOfString:@"/game/"].location == NSNotFound)) {
        return QWReadingTypeGame;
    }
    return QWReadingTypeOther;
}

- (NSString *)routerKey {
    if (self.readingType == QWReadingTypeGame) {
        return @"gamedetail";
    }
    if (self.readingType == QWReadingTypeBook) {
        return @"book";
    }
    return @"No Router Key";
}
@end
