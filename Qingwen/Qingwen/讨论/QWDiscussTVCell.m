//
//  QWDiscussTVCell.m
//  Qingwen
//
//  Created by Aimy on 8/11/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWDiscussTVCell.h"

#import "DiscussItemVO.h"
#import <YYText.h>

@interface QWDiscussTVCell ()

@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet UILabel *userLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet YYLabel *contentLabel;
@property (strong, nonatomic) IBOutlet UIButton *countBtn;
@property (strong, nonatomic) IBOutlet UIImageView *sexImageView;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray<UIImageView *> *imageViews;

@property (strong, nonatomic) DiscussItemVO *itemVO;

@end

@implementation QWDiscussTVCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.placeholder = [UIImage imageNamed:@"mycenter_logo"];

    self.userImageView.userInteractionEnabled = YES;
    WEAK_SELF;
    [self.userImageView bk_whenTapped:^{
        STRONG_SELF;
        if (self.itemVO.user.profile_url && self.itemVO.user.username) {
            NSMutableDictionary *params = @{}.mutableCopy;
            params[@"profile_url"] = self.itemVO.user.profile_url;
            params[@"username"] = self.itemVO.user.username;
            
            if (self.itemVO.user.sex) {
                params[@"sex"] = self.itemVO.user.sex;
            }
            if (self.itemVO.user.adorn_medal) {
                params[@"adorn_medal"] = self.itemVO.user.adorn_medal;
            }
            if (self.itemVO.user.avatar) {
                params[@"avatar"] = self.itemVO.user.avatar;
            }
            [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"user" andParams:params]];
        }
    }];
}

- (void)updateWithDiscussItemVO:(DiscussItemVO *)vo
{    
    self.itemVO = vo;

    self.userLabel.text = vo.user.username;

//    if (vo.user.sex.integerValue == 1) {
//        self.sexImageView.image = [UIImage imageNamed:@"sex1"];
//    }
//    else if (vo.user.sex.integerValue == 2) {
//        self.sexImageView.image = [UIImage imageNamed:@"sex0"];
//    }
    [self.sexImageView qw_setImageUrlString:vo.user.adorn_medal placeholder:nil animation:nil];
    NSMutableArray *tags = [NSMutableArray array];
    if (vo.top.boolValue) {
        TagVO *tag = [TagVO new];
        tag.type = @1;
        tag.local = YES;
        tag.value = @"discuss_top";
        [tags addObject:tag];
    }

    NSArray *tempTags = [vo.tags filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == 1"]];
    if (tempTags.count) {
        [tags addObjectsFromArray:tempTags];
    }

    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < tags.count) {
            TagVO *tag = tags[idx];
            if (tag) {
                obj.hidden = NO;
                if (tag.local) {
                    obj.image = [UIImage imageNamed:tag.value];
                }
                else {
                    [obj qw_setImageUrlString:[NSString stringWithFormat:@"%@?imageView2/2/h/%@/w/%@/", tag.value, @([UIScreen mainScreen].scale * 20), @([UIScreen mainScreen].scale * 26)] placeholder:nil animation:YES];
                }
            }
            else {
                obj.hidden = YES;
            }
        }
        else {
            obj.hidden = YES;
        }
    }];

    if (vo.count.integerValue > 999) {
        [self.countBtn setTitle:@" 999+" forState:UIControlStateNormal];
    }
    else {
        [self.countBtn setTitle:[NSString stringWithFormat:@" %@", vo.count.stringValue] forState:UIControlStateNormal];
    }

    [self.userImageView qw_setImageUrlString:[QWConvertImageString convertPicURL:vo.user.avatar imageSizeType:QWImageSizeTypeAvatarThumbnail] placeholder:self.placeholder cornerRadius:16.5 borderWidth:0 borderColor:[UIColor clearColor] animation:YES completeBlock:nil];

    self.timeLabel.text = [QWHelper shortDateToString:vo.updated_time];

    NSString *content = [[QWBannedWords sharedInstance] cryptoStringWithText:vo.content];

    if (!content) {
        content = @"";
    }

    if (vo.title.length) {
        content = [NSString stringWithFormat:@"%@\n%@", vo.title, content];
    }

    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:content];

//    [attributedText setYy_lineHeightMultiple:20];
    [attributedText setYy_minimumLineHeight:20];
    [attributedText setYy_maximumLineHeight:40];
    [attributedText setYy_color:HRGB(0x505050)];
    [attributedText setYy_font:[UIFont systemFontOfSize:14]];

    {
        WEAK_SELF;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"《([^《》]{1,})》" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray<NSTextCheckingResult *> *result = [regex matchesInString:attributedText.string options:0 range:NSMakeRange(0, attributedText.string.length)];
        [result enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            STRONG_SELF;
            [attributedText yy_setColor:HRGB(0xfea958) range:obj.range];
        }];
    }

    {
        WEAK_SELF;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@([^@《》\\[\\] ]{1,})( |$)" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray<NSTextCheckingResult *> *result = [regex matchesInString:attributedText.string options:0 range:NSMakeRange(0, attributedText.string.length)];
        [result enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            STRONG_SELF;
            [attributedText yy_setColor:HRGB(0xfb83ac) range:obj.range];
        }];
    }

    {
        WEAK_SELF;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray<NSTextCheckingResult *> *result = [regex matchesInString:attributedText.string options:0 range:NSMakeRange(0, attributedText.length)];
        [result enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            STRONG_SELF;
            [attributedText yy_setColor:[UIColor blueColor] range:obj.range];
            [attributedText yy_setTextUnderline:[YYTextDecoration decorationWithStyle:YYTextLineStyleSingle] range:obj.range];
        }];
    }
    
    //    YYTextSimpleEmoticonParser *parser = [YYTextSimpleEmoticonParser new];
    //    parser.emoticonMapper = [QWExpressionManager sharedManager].imagePattern;
    //    self.contentLabel.textParser = parser;
    self.contentLabel.attributedText = attributedText;

    CGSize size = CGSizeMake([QWSize screenWidth] - 15 - 15, 100);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:size text:attributedText];
    self.contentLabel.textLayout = layout;
    self.contentLabel.numberOfLines = 5;
    self.contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;

}

+ (CGFloat)heightForCellData:(DiscussItemVO *)data
{
    DiscussItemVO *vo = data;

    NSString *content = vo.content;

    if (!content) {
        content = @"";
    }

    if (vo.title.length) {
        content = [NSString stringWithFormat:@"%@\n%@", vo.title, content];
    }

    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:content];

//    [attributedText setYy_lineHeightMultiple:20];
    [attributedText setYy_minimumLineHeight:20];
    [attributedText setYy_maximumLineHeight:40];
    [attributedText setYy_color:HRGB(0x505050)];
    [attributedText setYy_font:[UIFont systemFontOfSize:14]];

    CGSize size = CGSizeMake([QWSize screenWidth] - 15 - 15, 100);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:size text:attributedText];
    
    return layout.textBoundingSize.height + 51 + 10;
}

@end
