//
//  QWScrollView.m
//  Qingwen
//
//  Created by Aimy on 8/8/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWScrollView.h"

#import "QWWeakObjectDeathNotifier.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface QWScrollView () <UIGestureRecognizerDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

@property (nonatomic, strong) QWEmptyView *emptyView;

@end

@implementation QWScrollView

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.emptyDataSetSource = self;
    self.emptyDataSetDelegate = self;
}

- (QWEmptyView *)emptyView
{
    if ( ! _emptyView) {
        _emptyView = [QWEmptyView createWithNib];
    }

    return _emptyView;
}

- (void)setUseDarkEmptyView:(BOOL)useDarkEmptyView
{
    _useDarkEmptyView = useDarkEmptyView;
    self.emptyView.useDark = useDarkEmptyView;
}

#pragma mark - empty delegate
- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
{
    return self.emptyView;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if (self.contentOffset.x <= 0) {
            UIPanGestureRecognizer *pan = (id)gestureRecognizer;
            CGPoint point = [pan translationInView:gestureRecognizer.view];
            if (point.x >= 0) {
                return NO;
            }
        }
    }

    return YES;
}

#pragma mark - safe
- (void)setDelegate:(id<UITableViewDelegate>)delegate
{
    [super setDelegate:delegate];

    if (delegate == nil) {
        return;
    }

    QWWeakObjectDeathNotifier *wo = [QWWeakObjectDeathNotifier new];
    [wo setOwner:delegate];
    WEAK_SELF;
    [wo setBlock:^(QWWeakObjectDeathNotifier *sender) {
        STRONG_SELF;
        self.delegate = nil;
        self.emptyDataSetSource = nil;
        self.emptyDataSetDelegate = nil;
        NSLog(@"%@ set delegate nil", NSStringFromClass([self class]));
    }];
}

@end
