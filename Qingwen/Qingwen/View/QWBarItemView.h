//
//  QWBarItemView.h
//  Qingwen
//
//  Created by mumu on 17/3/27.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QWBarItemView : UIView

typedef void (^QWLeftBarItemActionBlock)(UIButton  * _Nullable btn);

@property (nonatomic, strong, nullable) NSArray *titleBtns;

- (instancetype _Nonnull)initWithTitles:(NSArray * _Nonnull )titles actionBlock:(QWLeftBarItemActionBlock _Nullable)actionBlock;

- (instancetype _Nonnull)initWithTitles:(NSArray * _Nonnull)titles titleWidth:(CGFloat)width padding:(CGFloat)padding actionBlock:(QWLeftBarItemActionBlock _Nullable)actionBlock;

- (instancetype _Nonnull)initWithTitles:(NSArray *_Nonnull)titles titleWidth:(CGFloat)width actionBlock:(QWLeftBarItemActionBlock)actionBlock;
@end

NS_ASSUME_NONNULL_END
