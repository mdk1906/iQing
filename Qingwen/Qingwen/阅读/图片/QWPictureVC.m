//
//  QWPictureVC.m
//  Qingwen
//
//  Created by Aimy on 7/2/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWPictureVC.h"

#import "QWPictureCVCell.h"

#import "ContentItemVO.h"

#import "QWPictureTopView.h"
#import "QWPictureBottomView.h"
#import "QWReadingConfig.h"
#import "UIView+create.h"

#import "QWPictureAnimation.h"

#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>

@interface QWPictureVC () <QWPictureTopViewDelegate, QWPictureBottomViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) QWPictureTopView *topView;
@property (nonatomic, strong) QWPictureBottomView *bottomView;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;

@property (nonatomic) BOOL showSetting;

@end

@implementation QWPictureVC

+ (void)load
{
    QWMappingVO *vo = [QWMappingVO new];
    vo.className = [NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject;
    vo.storyboardName = @"QWReading";
    vo.storyboardID = @"picture";

    [[QWRouter sharedInstance] registerRouterVO:vo withKey:@"picture"];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.extraData) {
        self.pictures = [self.extraData objectForCaseInsensitiveKey:@"pictures"];
        self.index = [self.extraData objectForCaseInsensitiveKey:@"index"];
    }

    self.collectionView.backgroundColor = [UIColor blackColor];
    
    // Do any additional setup after loading the view.
    self.layout.itemSize = CGSizeMake([QWSize screenWidth:[QWReadingConfig sharedInstance].landscape], [QWSize screenHeight:[QWReadingConfig sharedInstance].landscape]);

    self.fd_interactivePopDisabled = YES;
    self.fd_prefersNavigationBarHidden = YES;

    self.topView = [QWPictureTopView createWithNib];
    self.topView.delegate = self;
    [self.view addSubview:self.topView];
    self.topView.countLabel.text = [NSString stringWithFormat:@"1/%@", @(self.pictures.count)];

    self.bottomView = [QWPictureBottomView createWithNib];
    self.bottomView.delegate = self;
    [self.view addSubview:self.bottomView];

    [self resize:CGSizeMake([QWSize screenWidth], [QWSize screenHeight])];
    self.collectionView.contentSize = CGSizeMake([QWSize screenWidth] * self.pictures.count, [QWSize screenHeight]);
    self.collectionView.contentOffset = CGPointMake([QWSize screenWidth] * self.index.integerValue, 0);
    [self.layout invalidateLayout];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - animtaion

- (id<UIViewControllerAnimatedTransitioning>)pushAnimations
{
    return [QWPictureAnimation animationWithType:YES];
}

- (id<UIViewControllerAnimatedTransitioning>)popAnimations
{
    return [QWPictureAnimation animationWithType:NO];
}

#pragma mark - delegate

- (void)topView:(QWPictureTopView *)view didClickedBackBtn:(id)sender
{
    [self backToReadingVC];
}

- (void)bottomView:(QWPictureBottomView *)view didClickedRotatingBtn:(id)sender
{
    QWPictureCVCell *cell = self.collectionView.visibleCells.firstObject;
    [cell rotateImage];
}

- (void)bottomView:(QWPictureBottomView *)view didClickedSaveBtn:(id)sender
{
    QWPictureCVCell *cell = self.collectionView.visibleCells.firstObject;
    [cell saveImageToDisk];
}

#pragma mark - actions

- (void)backToReadingVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showSettingViews
{
    [self.topView showWithAnimated];
    [self.bottomView showWithAnimated];
}

- (void)hideAllSettingViews
{
    [self.topView hideWithAnimated];
    [self.bottomView hideWithAnimated];
}

#pragma mark - collectionview

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger currentIndex = self.collectionView.contentOffset.x / [QWSize screenWidth] + 1;
    self.topView.countLabel.text = [NSString stringWithFormat:@"%@/%@", @(currentIndex), @(self.pictures.count)];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.pictures.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QWPictureCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.manager = self.operationManager;
    NSString *imageName = self.pictures[indexPath.item];
    [cell updateImageWithUrl:imageName bookId:self.bookId volumeId:self.volumeId chapterId:self.chapterId];
    return cell;
}

- (void)resize:(CGSize)size
{
    [QWReadingConfig sharedInstance].landscape = size.width > size.height;

    NSInteger currentIndex = [(NSString *)[self.topView.countLabel.text componentsSeparatedByString:@"/"].firstObject integerValue] - 1;
    self.layout.itemSize = CGSizeMake([QWSize screenWidth:[QWReadingConfig sharedInstance].landscape], [QWSize screenHeight:[QWReadingConfig sharedInstance].landscape]);
    self.collectionView.contentOffset = CGPointMake([QWSize screenWidth] * currentIndex, 0);
    [self.collectionView reloadData];
}

@end
