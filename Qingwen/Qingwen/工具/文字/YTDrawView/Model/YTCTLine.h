//
//  YTCTLine.h
//  CoreTextDemo
//
//  Created by aron on 2018/7/16.
//  Copyright © 2018年 aron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface YTCTLine : NSObject

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) CTLineRef ctLine;

@end
