//
//  QWCategoryVC.m
//  Qingwen
//
//  Created by Aimy on 7/1/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWCategoryCVC.h"

#import "QWCategoryCVCell.h"
#import "QWCategoryLogic.h"
#import "QWOperationParam.h"
#import "QWCollectionView.h"
#import "QWTableView.h"
#import "QWReachability.h"
#import "QWDiscussTVC.h"
#import "UIViewController+create.h"

@interface QWCategoryCVC () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet QWCollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;

@property (strong, nonatomic) QWCategoryLogic *logic;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation QWCategoryCVC

+ (void)load
{
    QWMappingVO *vo = [QWMappingVO new];
    vo.className = [NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject;
    vo.storyboardName = @"QWCategory";

    [[QWRouter sharedInstance] registerRouterVO:vo withKey:@"category"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.layout.headerReferenceSize = CGSizeZero;
    self.layout.footerReferenceSize = CGSizeZero;

    self.searchBar.frame = CGRectMake(0, 7, UISCREEN_WIDTH, 30);
    self.navigationItem.titleView = self.searchBar;
    [self.searchBar setImage:[UIImage imageNamed:@"search_icon"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.searchBar setValue:QWPINK forKeyPath:@"_searchField.textColor"];
    [self.searchBar setValue:QWPINK forKeyPath:@"_searchField._placeholderLabel.textColor"];

    WEAK_SELF;
    self.collectionView.mj_header = [QWRefreshHeader headerWithRefreshingBlock:^{
        STRONG_SELF;
        [self getData];
    }];
}

- (void)dealloc
{
    [self removeAllObservationsOfObject:[QWReachability sharedInstance]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    WEAK_SELF;
    [self observeObject:[QWReachability sharedInstance] property:@"currentNetStatus" withBlock:^(__weak id self, __weak id object, id old, id newVal) {
        KVO_STRONG_SELF;
        if ([QWReachability sharedInstance].isConnectedToNet && kvoSelf.logic.categoryVO == nil) {
            [kvoSelf getData];
        }
    }];
}

- (QWCategoryLogic *)logic
{
    if (!_logic) {
        _logic = [QWCategoryLogic logicWithOperationManager:self.operationManager];
    }

    return _logic;
}

- (void)getData {
    WEAK_SELF;
    self.logic.categoryVO = nil;
    self.collectionView.emptyView.showError = NO;
    [self.logic getCategoryWithCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView reloadData];
        self.collectionView.emptyView.showError = YES;
    }];
}

- (void)setPageShow:(BOOL)enable
{
    self.collectionView.scrollsToTop = enable;
}

- (void)repeateClickTabBarItem:(NSInteger)count
{
    if (count && count % 2 == 0) {
        [self getData];
    }
}

#pragma mark - search bar delegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"QWSearch" bundle:nil];
    UIViewController *vc = [sb instantiateInitialViewController];
    [self.navigationController pushViewController:vc animated:YES];
    return NO;
}

#pragma mark - collection view delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPHONE_DEVICE) {
        return CGSizeMake((UISCREEN_WIDTH - 30) / 3, (UISCREEN_WIDTH - 30) / 3 + 29);
    }
    else {
        if (IS_LANDSCAPE) {
            return CGSizeMake((UISCREEN_WIDTH - 60) / 6, (UISCREEN_WIDTH - 60) / 6 + 29);
        }
        else {
            return CGSizeMake((UISCREEN_WIDTH - 40) / 4, (UISCREEN_WIDTH - 40) / 4 + 29);
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.logic.categoryVO.results.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static UIImage *placeholder = nil;
    if (!placeholder) {
        placeholder = [UIImage imageNamed:@"placeholder157x157"];
    }

    QWCategoryCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    CategoryItemVO *vo = self.logic.categoryVO.results[indexPath.item];
    cell.titleLabel.text = vo.name;
    [cell.imageView qw_setImageUrlString:[QWConvertImageString convertPicURL:vo.cover imageSizeType:QWImageSizeTypeCategory] placeholder:placeholder animation:YES];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryItemVO *vo = self.logic.categoryVO.results[indexPath.item];
    [vo toList];
}

- (void)resize:(CGSize)size
{
    [self.layout invalidateLayout];
}

@end
