//
//  QWGDTReadNativeAdView.h
//  Qingwen
//
//  Created by qingwen on 2019/3/19.
//  Copyright © 2019 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QWGDTReadNativeAdView : UIView
-(instancetype)initWithFrame:(CGRect)frame withBook:(NSNumber*)bookId withChapter:(NSNumber*)chapter;
-(instancetype)initWithFrame:(CGRect)frame;
-(void)getBookId:(NSNumber *)bookId getChapterId:(NSNumber *)chapter getFree:(NSNumber *)free getLastAd:(NSNumber *)lastAd;

@end
