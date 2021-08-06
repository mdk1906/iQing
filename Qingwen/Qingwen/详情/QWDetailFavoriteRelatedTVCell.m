//
//  QWDetailFavoriteRelatedTVCell.m
//  Qingwen
//
//  Created by wei lu on 10/02/18.
//  Copyright © 2018 iQing. All rights reserved.
//


#import "QWDetailFavoriteRelatedTVCell.h"

#import "QWDetailFavoriteRelatedCVCell.h"
#import "FavoriteBooksList.h"

@interface QWDetailFavoriteRelatedTVCell () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;



@property (nonatomic, copy) FavoriteBooksListVO *listVO;

@end

@implementation QWDetailFavoriteRelatedTVCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    CGFloat width = 0;
    if (ISIPHONE9_7) {
        if (IS_LANDSCAPE) {
            width = UISCREEN_WIDTH / 7;
        }
        else {
            width = UISCREEN_WIDTH / 5;
        }
    }
    else {
        width = UISCREEN_WIDTH / 3;
    }
    
    CGFloat height = width + 25;
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
        label.text = @"暂无相关书单";
        self.collectionView.backgroundView = label;
    }
}

+ (CGFloat)heightForCellData:(id)data
{
    CGFloat width = 0;
    if (ISIPHONE9_7) {
        if (IS_LANDSCAPE) {
            width = UISCREEN_WIDTH / 7;
        }
        else {
            width = UISCREEN_WIDTH / 5;
        }
    }
    else {
        width = UISCREEN_WIDTH / 3;
    }
    CGFloat height = width  + 25;
    return height;
}

- (void)updateWithListVO:(FavoriteBooksListVO *)vo
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
    QWDetailFavoriteRelatedCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    FavoriteBooksVO *book = self.listVO.results[indexPath.item];
    [cell updateWithBookVO:book];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    FavoriteBooksVO *book = self.listVO.results[indexPath.item];
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"id"] = book.nid;
    [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"favorite" andParams:params]];
}

@end

