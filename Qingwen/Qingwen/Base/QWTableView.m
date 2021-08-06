//
//  QWTableView.m
//  Qingwen
//
//  Created by Aimy on 7/23/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWTableView.h"

#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "QWEmptyView.h"
#import "QWWeakObjectDeathNotifier.h"

@interface QWTableView () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, strong) QWEmptyView *emptyView;

@end

@implementation QWTableView

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
        self.dataSource = nil;
        self.emptyDataSetSource = nil;
        self.emptyDataSetDelegate = nil;
        NSLog(@"%@ set delegate nil", NSStringFromClass([self class]));
    }];
}

@end
