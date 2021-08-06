//
//  QWWebView.h
//  
//
//  Created by Aimy on 9/7/15.
//
//

#import <UIKit/UIKit.h>

@interface QWWebView : UIWebView

/**
 *  设置cookie
 *
 *  @param aDomain
 *  @param aName
 *  @param aValue
 */
+ (void)setCookie:(NSString *)aDomain name:(NSString *)aName value:(NSString *)aValue;
/**
 *  设置cookie
 *
 *  @param aName
 *  @param aValue
 */
+ (void)setCookieName:(NSString *)aName value:(NSString *)aValue;
/**
 *  清除cookies
 */
+ (void)clearCookies;

/**
 *  添加默认的cookies
 */
+ (void)setupDefaultCookies;

@end
