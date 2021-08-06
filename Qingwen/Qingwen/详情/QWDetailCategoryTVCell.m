//
//  QWDetailCategoryTVCell.m
//  Qingwen
//
//  Created by Aimy on 7/21/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWDetailCategoryTVCell.h"

#import "QWDetailCategoryCVCell.h"

@interface QWDetailCategoryTVCell () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;
@property (nonatomic, copy) NSArray *categorys;

@end

@implementation QWDetailCategoryTVCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)updateWithData:(BookVO *)data
{
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    NSInteger ITEM_COUNT = 8;
    NSInteger ITEM_LINE_COUNT = 4;

    if (IS_IPAD_DEVICE) {
        ITEM_COUNT = 5;
        ITEM_LINE_COUNT = 5;
    }

    self.categorys = (id)data.categories;
    if (self.categorys.count > ITEM_COUNT) {
        self.categorys = [self.categorys subarrayWithRange:NSMakeRange(0, ITEM_COUNT)];
    }
    else if (self.categorys.count < ITEM_COUNT) {
        NSInteger count = self.categorys.count;
        NSMutableArray *categorys = self.categorys.mutableCopy;
        while (count < ITEM_COUNT) {
            [categorys addObject:[CategoryItemVO new]];
            count++;
        }
        self.categorys = categorys;
    }

    self.collectionView.scrollsToTop = NO;

    CGFloat itemWidth = [QWSize getLengthWithSizeType:QWSizeType4_0 andLength:60];
    self.layout.itemSize = CGSizeMake(itemWidth, ceil(itemWidth * 36 / 85));
    CGFloat edge = (UISCREEN_WIDTH - ITEM_LINE_COUNT * itemWidth) / (ITEM_LINE_COUNT + 1);
    if (IS_IPHONE_DEVICE) {
        self.layout.sectionInset = UIEdgeInsetsMake(edge - 1, edge - 1, edge - 1, edge - 1);
        self.layout.minimumLineSpacing = edge;
    }
    else {
        self.layout.sectionInset = UIEdgeInsetsMake(20, edge - 1, 20, edge - 1);
        self.layout.minimumLineSpacing = 20;
    }

    self.layout.minimumInteritemSpacing = edge;
    [self.collectionView reloadData];

    if (!self.categorys.count) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_WIDTH, 20)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = HRGB(0xaeaeae);
        label.font = [UIFont systemFontOfSize:18];
        label.text = @"暂无作品分类";
        self.collectionView.backgroundView = label;
    }
    else {
        self.collectionView.backgroundView = nil;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.categorys.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QWDetailCategoryCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    CategoryItemVO *vo = self.categorys[indexPath.item];
    [cell.categoryBtn setTitle:vo.name forState:UIControlStateNormal];
    cell.hidden = vo.name == nil;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryItemVO *vo = self.categorys[indexPath.item];
    [vo toList];
}

@end
