//
//  QWCollectionView.m
//  Qingwen
//
//  Created by Aimy on 7/23/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWCollectionView.h"

#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "UIView+create.h"
#import "QWWeakObjectDeathNotifier.h"

@interface QWCollectionView () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, strong) QWEmptyView *emptyView;

@end

@implementation QWCollectionView

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

#pragma mark - safe
- (void)setDelegate:(id<UICollectionViewDelegate>)delegate
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
        self.dataSource = nil;
        self.emptyDataSetSource = nil;
        self.emptyDataSetDelegate = nil;
        NSLog(@"%@ set delegate nil", NSStringFromClass([self class]));
    }];
}

@end
