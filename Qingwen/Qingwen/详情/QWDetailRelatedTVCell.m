//
//  QWDetailRelatedTVCell.m
//  Qingwen
//
//  Created by Aimy on 7/2/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWDetailRelatedTVCell.h"

#import "QWDetailRelatedCVCell.h"
#import "ListVO.h"

@interface QWDetailRelatedTVCell () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;

@property (nonatomic, copy) ListVO *listVO;

@end

@implementation QWDetailRelatedTVCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    CGFloat width = 0;
    if (ISIPHONE9_7) {
        if (IS_LANDSCAPE) {
            width = UISCREEN_WIDTH / 9;
        }
        else {
            width = UISCREEN_WIDTH / 7;
        }
    }
    else if (ISIPHONE4_7 || ISIPHONE5_5) {
        width = UISCREEN_WIDTH / 5;
    }
    else {
        width = UISCREEN_WIDTH / 4;
    }

    CGFloat height = width / 0.75 + 25;
    self.layout.itemSize = CGSizeMake(width, height);

    self.collectionView.scrollsToTop = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self showEmpty];
}

- (void)showEmpty
{
    if (self.listVO.results.count) {
        self.collectionView.backgroundView = nil;
    }
    else {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_WIDTH, 20)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = HRGB(0x505050);
        label.font = [UIFont systemFontOfSize:15];
        label.text = @"暂无相关作品";
        self.collectionView.backgroundView = label;
    }
}

+ (CGFloat)heightForCellData:(id)data
{
    CGFloat width = 0;
    if (ISIPHONE9_7) {
        if (IS_LANDSCAPE) {
            width = UISCREEN_WIDTH / 9;
        }
        else {
            width = UISCREEN_WIDTH / 7;
        }
    }
    else if (ISIPHONE4_7 || ISIPHONE5_5) {
        width = UISCREEN_WIDTH / 5;
    }
    else {
        width = UISCREEN_WIDTH / 4;
    }
    CGFloat height = width / 0.75 + 45;
    return height;
}

- (void)updateWithListVO:(ListVO *)vo
{
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.listVO = vo;
    [self showEmpty];
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.listVO.results.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QWDetailRelatedCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    BookVO *book = self.listVO.results[indexPath.item];
    [cell updateWithBookVO:book];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    BookVO *book = self.listVO.results[indexPath.item];
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"url"] = book.url;
    params[@"id"] = book.nid;
    [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"book" andParams:params]];
}

@end
