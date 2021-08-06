//
//  QWBlickListTVCell.m
//  Qingwen
//
//  Created by mumu on 2017/9/29.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWBlickListTVCell.h"

@interface QWBlickListTVCell()

@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UIImageView *sexImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) IBOutlet UILabel *introLabel;

@end

@implementation QWBlickListTVCell

- (void)updateWithUserVO:(UserVO *)user {
    [self.avatar qw_setImageUrlString:[QWConvertImageString convertPicURL:user.avatar imageSizeType:QWImageSizeTypeAvatar] placeholder:[UIImage imageNamed:@"mycenter_logo"] animation:true];
    self.sexImageView.image = (user.sex && user.sex.integerValue == 1) ? [UIImage imageNamed:@"sex1"] : [UIImage imageNamed:@"sex0"];
    self.nameLabel.text = user.username;
    self.introLabel.text = user.signature;
}

@end
