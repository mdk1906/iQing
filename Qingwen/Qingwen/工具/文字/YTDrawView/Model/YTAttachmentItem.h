//
//  YTAttachmentItem.h
//  CoreTextDemo
//
//  Created by aron on 2018/7/12.
//  Copyright © 2018年 aron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YTBaseDataItem.h"

typedef NS_ENUM(NSUInteger, YTAttachmentType) {
    YTAttachmentTypeImage,
    YTAttachmentTypeView,
};


/**
 对其方式枚举

 - YTAttachmentAlignTypeBottom: 底部对其
 - YTAttachmentAlignTypeCenter: 居中对其
 - YTAttachmentAlignTypeTop: 顶部对其
 */
typedef NS_ENUM(NSUInteger, YTAttachmentAlignType) {
    YTAttachmentAlignTypeBottom,
    YTAttachmentAlignTypeCenter,
    YTAttachmentAlignTypeTop,
};

@interface YTAttachmentItem : YTBaseDataItem

@property (nonatomic, assign) YTAttachmentType type;
@property (nonatomic, strong) id attachment;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) YTAttachmentAlignType align;///<对其方式
@property (nonatomic, assign) CGFloat ascent;///<文本内容的ascent，用于计算attachment内容的ascent
@property (nonatomic, assign) CGFloat descent;///<文本内容的descent，用于计算attachment内容的descent
@property (nonatomic, assign) CGSize size;///<attachment内容的大小

- (UIImage *)image;
- (UIView *)view;

@end
