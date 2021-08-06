//
//  QWDetailFavoriteRelatedCVCell.m
//  Qingwen
//
//  Created by wei lu on 10/02/18.
//  Copyright © 2018 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QWDetailFavoriteRelatedCVCell.h"

#import "FavoriteBooksVO.h"

@interface QWDetailFavoriteRelatedCVCell ()

@property (nonatomic, strong) UIImageView *coverImage;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UILabel *titleLabel;


@end

@implementation QWDetailFavoriteRelatedCVCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.placeholder = [UIImage imageNamed:@"placeholder114x152"];
    [self setUpViews];
    
}

- (void)setUpViews
{
    self.coverImage = [[UIImageView alloc] init];
    self.coverImage.clipsToBounds = YES;
    self.coverImage.cornerRadius = 6.0;
    
    self.countLabel = [[UILabel alloc] init];
    self.countLabel.font = [UIFont systemFontOfSize:11.0];
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    self.countLabel.textColor = [UIColor color69];
    self.countLabel.backgroundColor = [UIColor whiteColor];
    self.countLabel.cornerRadius = 6.0;
    self.countLabel.clipsToBounds = YES;
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:15.0];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor color50];
    [self.contentView addSubview:self.coverImage];
    [self.coverImage addSubview:self.countLabel];
    [self.contentView addSubview:self.titleLabel];
    


    [self.coverImage autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.coverImage autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.coverImage autoSetDimension:ALDimensionHeight toSize:94];
    [self.coverImage autoSetDimension:ALDimensionWidth toSize:94];
    
    
    [self.countLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.coverImage];
    [self.countLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.coverImage ];
    [self.countLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.coverImage];
    [self.countLabel autoSetDimension:ALDimensionHeight toSize:25];
    
    [self.titleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.coverImage withOffset:6.0];
    [self.titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.coverImage ];
    [self.titleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.coverImage ];
    
}

- (void)updateWithBookVO:(FavoriteBooksVO *)favorite
{
    self.titleLabel.text = favorite.title;
    self.countLabel.text = [NSString stringWithFormat:@"共%@作品", favorite.work_count.stringValue];
    [MultipleImagesToolsAsset multipleImagesSetUrlWithGroupUrls:favorite.cover defaultImage:self.placeholder animation:(YES) completeHandle:^(NSArray<UIImageView *> * photos) {
        NSMutableArray * imagesArray = [[NSMutableArray alloc] init];
        if(photos.count < 3){
            long index = 0;
            long loopCnt = 0;
            for (index = 0; index < photos.count; index++) {
                [imagesArray addObject:[photos objectAtIndex:index]];
            }
            loopCnt = 3 - photos.count;
            long index2;
            for (index2 = 0; index2 < loopCnt; index2++) {
                UIImageView *defaultPic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_fav"]] ;
                [imagesArray addObject:defaultPic];
            }
            self.coverImage.image = [MultipleImagesToolsAsset drawImagesWithImageArray:imagesArray size:self.frame.size corner:true count:3 startX:0 row:1];
        }else{
            self.coverImage.image = [MultipleImagesToolsAsset drawImagesWithImageArray:photos size:self.frame.size corner:true count:3 startX:0 row:1];
        }
        
    }];
}

@end
