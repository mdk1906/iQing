//
//  QWMessageBookTVCell.m
//  Qingwen
//
//  Created by Aimy on 8/27/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWMessageBookTVCell.h"

@interface QWMessageBookTVCell ()

@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descLabel;
@property (strong, nonatomic) IBOutlet UIView *contentBackgroundView;
@property (strong, nonatomic) IBOutlet UIImageView *bookImageView;
@property (strong, nonatomic) IBOutlet UILabel *contentTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *contentSubtitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *subDescLabel;
@property (strong, nonatomic) IBOutlet UIImageView *sexImageView;

@property (nonatomic, strong) MessageVO *itemVO;
@property (nonatomic, strong) UIImage *placeholder2;

@end

@implementation QWMessageBookTVCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.userImageView.layer.cornerRadius = 17;
    self.userImageView.layer.masksToBounds = YES;

    self.contentBackgroundView.layer.cornerRadius = 5.f;

    self.placeholder = [UIImage imageNamed:@"mycenter_logo"];
    self.placeholder2 = [UIImage imageNamed:@"placeholder114x152"];

    WEAK_SELF;
    self.userImageView.userInteractionEnabled = YES;
    [self.userImageView bk_whenTapped:^{
        STRONG_SELF;
        MessageVO *itemVO = self.itemVO;
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"profile_url"] = itemVO.user.profile_url;
        params[@"username"] = itemVO.user.username;

        if (itemVO.user.sex) {
            params[@"sex"] = itemVO.user.sex;
        }

        if (itemVO.user.avatar) {
            params[@"avatar"] = itemVO.user.avatar;
        }
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"user" andParams:params]];
    }];
}

- (void)updateWithMessage:(MessageVO *)itemVO
{
    self.itemVO = itemVO;

    if (!itemVO.isValid) {
        self.userImageView.image = nil;
        self.titleLabel.text = nil;
        self.descLabel.text = nil;
        self.contentBackgroundView.hidden = YES;
        self.titleLabel.text = nil;
        self.contentSubtitleLabel.text = nil;
        self.timeLabel.text = nil;
        self.subDescLabel.text = nil;
        return;
    }

    self.contentBackgroundView.hidden = NO;

    if (itemVO.type.integerValue == 1) {
        if (itemVO.user.sex.integerValue == 1) {
            self.sexImageView.image = [UIImage imageNamed:@"sex1"];
        }
        else if (itemVO.user.sex.integerValue == 2) {
            self.sexImageView.image = [UIImage imageNamed:@"sex0"];
        }

        [self.userImageView qw_setImageUrlString:[QWConvertImageString convertPicURL:itemVO.user.avatar imageSizeType:QWImageSizeTypeAvatar] placeholder:self.placeholder animation:YES];
        self.titleLabel.text = itemVO.user.username;
        self.descLabel.text = itemVO.desc;
        [self.bookImageView qw_setImageUrlString:[QWConvertImageString convertPicURL:itemVO.data.cover imageSizeType:QWImageSizeTypeCover] placeholder:self.placeholder2 animation:YES];
        if (itemVO.data.title.length) {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineHeightMultiple:18];
            [paragraphStyle setMinimumLineHeight:18];
            [paragraphStyle setMaximumLineHeight:18];
            [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:itemVO.data.title attributes:@{NSParagraphStyleAttributeName: paragraphStyle}];
            self.contentTitleLabel.attributedText = attributedString;
        }
        else {
            self.contentTitleLabel.attributedText = [NSAttributedString new];
        }
        self.contentSubtitleLabel.text = itemVO.data.sub_title;
        self.timeLabel.text = [QWHelper shortDateToString:itemVO.created_time];
        self.subDescLabel.text = itemVO.data.end_notes;
    }
    else if (itemVO.type.integerValue == 3) {
        if (itemVO.user.sex.integerValue == 1) {
            self.sexImageView.image = [UIImage imageNamed:@"sex1"];
        }
        else if (itemVO.user.sex.integerValue == 2) {
            self.sexImageView.image = [UIImage imageNamed:@"sex0"];
        }

        [self.userImageView qw_setImageUrlString:[QWConvertImageString convertPicURL:itemVO.user.avatar imageSizeType:QWImageSizeTypeAvatar] placeholder:self.placeholder animation:YES];
        self.titleLabel.text = itemVO.user.username;
        self.descLabel.text = itemVO.desc;

        if (itemVO.data.content.length) {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineHeightMultiple:18];
            [paragraphStyle setMinimumLineHeight:18];
            [paragraphStyle setMaximumLineHeight:18];
            [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:itemVO.data.content attributes:@{NSParagraphStyleAttributeName: paragraphStyle}];
            self.contentTitleLabel.attributedText = attributedString;
        }
        else {
            self.contentTitleLabel.attributedText = [NSAttributedString new];
        }

        self.timeLabel.text = [QWHelper shortDateToString:itemVO.created_time];
        self.subDescLabel.text = itemVO.data.end_notes;
    }
}

@end
