//
//  QWGameDetailHeadTVCell.m
//  Qingwen
//
//  Created by Aimy on 9/29/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWGameDetailHeadTVCell.h"

#import "BookCD.h"
#import "QWHelper.h"
#import <YYText.h>

@interface QWGameDetailHeadTVCell ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *usersignatureLabel;
@property (strong, nonatomic) IBOutlet YYLabel *introLabel;
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;

@property (strong, nonatomic) IBOutlet UIButton *attentionBtn;

@property (nonatomic, strong) BookVO *book;

@property (nonatomic) CGFloat height;

@end

@implementation QWGameDetailHeadTVCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)updateWithData:(BookVO *)book andAttention:(NSNumber *)attention isMyself:(NSNumber *)myself discussCount:(NSNumber *)discussCount showAll:(BOOL)showAll
{
    self.book = book;

    self.titleLabel.text = book.title;
    self.subtitleLabel.text = [NSString stringWithFormat:@"%@重石／%@轻石／%@人气／%@收藏", [QWHelper countToShortString:book.gold], [QWHelper countToShortString:book.coin], [QWHelper countToShortString:book.views], [QWHelper countToShortString:book.follow_count]];

    self.usernameLabel.text = book.author_name;
    UserVO *user = book.author.firstObject;
    self.usersignatureLabel.text = @" ";
    if (user) {
        self.usersignatureLabel.text = user.signature;
        self.usernameLabel.text = user.username;
        [self.userImageView qw_setImageUrlString:[QWConvertImageString convertPicURL:user.avatar imageSizeType:QWImageSizeTypeAvatarThumbnail] placeholder:[UIImage imageNamed:@"mycenter_logo"] animation:YES];
    }
    
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
    self.attentionBtn.hidden = myself.boolValue;
    
    if (showAll) {
        self.introLabel.numberOfLines = 0;
    }
    else {
        self.introLabel.numberOfLines = 2;
    }

    NSString *introText = [NSString stringWithFormat:@"简介：%@",book.intro];
    //YYLabel 遇到\n，会换行
    NSString *temText = [introText stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    temText = [temText stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (showAll) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:introText attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: HRGB(0xAEAEAE)}];
        CGSize size = CGSizeMake(UISCREEN_WIDTH - 20, CGFLOAT_MAX);
        YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:size text:attributedString];
        self.introLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:introText attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: HRGB(0xAEAEAE)}];
        self.introLabel.textLayout = layout;
    }
    else {
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:temText attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: HRGB(0xAEAEAE)}];

        CGSize size = CGSizeMake(CGFLOAT_MAX, 20);
        YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:size text:attributedString];

        if (layout.textBoundingSize.width > (UISCREEN_WIDTH - 20) * 1.5) {//大于1.5行
            size = CGSizeMake((UISCREEN_WIDTH - 20) * 1.5, 20);
            layout = [YYTextLayout layoutWithContainerSize:size text:attributedString];
            attributedString = [[NSMutableAttributedString alloc] initWithString:[temText substringWithRange:layout.visibleRange] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: HRGB(0xAEAEAE)}];
            [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"..." attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: HRGB(0xAEAEAE)}]];

             NSMutableAttributedString *more = [[NSMutableAttributedString alloc] initWithString:@"更多" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: HRGB(0xfb83ac)}];
            YYTextHighlight *highlight = [YYTextHighlight new];
            [highlight setColor:HRGB(0xfb83ac)];
            WEAK_SELF;
            highlight.tapAction = [^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
                STRONG_SELF;
                [self.delegate headCell:self didClickedShowAllBtn:nil];
            } copy];
            [attributedString appendAttributedString:more];
            [attributedString yy_setTextHighlight:highlight range:attributedString.yy_rangeOfAll];
            self.introLabel.attributedText = attributedString;
            size = CGSizeMake(UISCREEN_WIDTH - 20, CGFLOAT_MAX);
            layout = [YYTextLayout layoutWithContainerSize:size text:attributedString];
            self.introLabel.textLayout = layout;
        }
        else {
            CGSize size = CGSizeMake(UISCREEN_WIDTH - 20, CGFLOAT_MAX);
            YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:size text:attributedString];
            self.introLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:introText attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: HRGB(0xAEAEAE)}];
            self.introLabel.numberOfLines = 1;
            self.introLabel.textLayout = layout;
        }
    }
}

- (IBAction)onPressedAuthorBtn:(id)sender {
    UserVO *author = self.book.author.firstObject;
    if (author.profile_url.length) {
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"profile_url"] = author.profile_url;
        params[@"username"] = author.username;

        if (author.sex) {
            params[@"sex"] = author.sex;
        }

        if (author.avatar) {
            params[@"avatar"] = author.avatar;
        }
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"user" andParams:params]];
    }
    else {
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"book_url"] = self.book.author_url;
        params[@"title"] = self.book.author_name;
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"list" andParams:params]];
    }
}

- (IBAction)onPressedAttentionBtn:(id)sender {
    [self.delegate headCell:self didClickedAttentionBtn:sender];
}

- (CGFloat)heightWithBook:(BookVO *)book
{
    if (!book) {
        return 154;
    }

    if (self.height > 0) {
        return self.height;
    }

    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize: 12], NSForegroundColorAttributeName: HRGB(0xAEAEAE)};
    CGSize size = CGSizeMake(UISCREEN_WIDTH - 20, CGFLOAT_MAX);
    CGRect frame = [book.intro boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    self.height = frame.size.height + 95;
    return self.height;
}

+ (CGFloat)minHeightWithBook:(BookVO *)book
{
    return  130;
}

@end
