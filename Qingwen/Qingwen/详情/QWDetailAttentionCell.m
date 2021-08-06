//
//  QWDetailAttentionCell.m
//  Qingwen
//
//  Created by mumu on 17/1/4.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWDetailAttentionCell.h"

@interface QWDetailAttentionCell()

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *authorName;
@property (strong, nonatomic) IBOutlet UIButton *attentionBtn;
@property (strong, nonatomic) IBOutlet UILabel *signatureLabel;
@property (weak, nonatomic) IBOutlet UIImageView *medalImg;


@property (strong, nonatomic) UserVO *user;
@end

@implementation QWDetailAttentionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    WEAK_SELF;
    [self bk_whenTapped:^{
        STRONG_SELF;
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"profile_url"] = self.user.profile_url;
        params[@"username"] = self.user.username;

        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"user" andParams:params]];
    }];
}

- (void)updateAttentionCell:(UserVO *)author attention:(NSNumber *)attention{
    self.user = author;
    self.signatureLabel.text = @"";
        self.signatureLabel.text = author.signature;
    self.authorName.font = self.signatureLabel.font;
    self.authorName.text = author.username;
    [self.avatarImageView qw_setImageUrlString:[QWConvertImageString convertPicURL:author.avatar imageSizeType:QWImageSizeTypeAvatarThumbnail] placeholder:[UIImage imageNamed:@"mycenter_logo"] animation:YES];
    [self.medalImg qw_setImageUrlString:author.adorn_medal placeholder:nil animation:nil];
    if (attention.boolValue) {
        [self.attentionBtn setTitle:@"已关注" forState:UIControlStateNormal];
        [self.attentionBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_13_1"] forState:UIControlStateNormal];
        [self.attentionBtn setTitleColor:HRGB(0x888888) forState:UIControlStateNormal];
    }
    else {
        [self.attentionBtn setTitle:@"加关注" forState:UIControlStateNormal];
        [self.attentionBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_1_1"] forState:UIControlStateNormal];
        [self.attentionBtn setTitleColor:[UIColor colorQWPinkDark] forState:UIControlStateNormal];

    }
    if (author.nid == [QWGlobalValue sharedInstance].nid) {
        self.attentionBtn.hidden = true;
    }
}
- (IBAction)onPressedAttentionBtn:(UIButton *)sender {
    [self.delegate attentionCell:self didClickedAttentionBtn:sender];
}

@end
