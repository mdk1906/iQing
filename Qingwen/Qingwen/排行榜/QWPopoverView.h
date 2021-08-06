//
//  QWPopoverView.h
//  Qingwen
//
//  Created by mumu on 16/9/20.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QWPopoverView : UIView

-(id)initWithPoint:(CGPoint)point titles:(NSArray *)titles currentSelected:(NSString *)selectedTitle images:(NSArray *)images;

/**
弹出框
 @param point 要弹出的位置
 @param size  弹出宽度和高度
 
 */
- (instancetype) initWithPoint:(CGPoint)point titles:(NSArray *)titles size:(CGSize)size;

- (instancetype)initWithPoint:(CGPoint)point titles:(NSArray *)titles size:(CGSize)size stype:(UITableViewCellStyle)style;
-(void)show;
-(void)dismiss;
-(void)dismiss:(BOOL)animated;

@property (nonatomic) BOOL isShow;
@property (nonatomic, copy) UIColor *borderColor;
@property (nonatomic, copy) void (^selectRowAtIndex)(NSInteger index);

@property (nonatomic) UITableViewCellStyle style;
@end
