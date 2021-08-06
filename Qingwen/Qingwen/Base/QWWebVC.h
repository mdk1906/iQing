//
//  QWWebVC.h
//  
//
//  Created by Aimy on 9/7/15.
//
//

#import "QWBaseVC.h"
#import "QWWebView.h"
@interface QWWebVC : QWBaseVC
@property (nonatomic, strong) QWWebView *webView;
@property (nonatomic, strong, readonly) NSString *url;

@end
