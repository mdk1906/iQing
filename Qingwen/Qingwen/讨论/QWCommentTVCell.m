//
//  QWCommentTVCell.m
//  Qingwen
//
//  Created by Aimy on 8/11/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWCommentTVCell.h"

#import "UserVO.h"
#import <YYText.h>
#import "DiscussItemVO.h"

@interface QWCommentTVCell ()

@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet UIButton *referenceBtn;

@property (strong, nonatomic) IBOutlet UILabel *userLabel;
@property (strong, nonatomic) IBOutlet UILabel *orderLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet YYLabel *contentLabel;
@property (strong, nonatomic) IBOutlet UIImageView *sexImageView;

@property (strong, nonatomic) DiscussItemVO *itemVO;

@end

@implementation QWCommentTVCell

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

- (void)updateWithCommentItemVO:(DiscussItemVO *)vo
{
    self.itemVO = vo;

//    if (vo.user.sex.integerValue == 1) {
//        self.sexImageView.image = [UIImage imageNamed:@"sex1"];
//    }
//    else if (vo.user.sex.integerValue == 2) {
//        self.sexImageView.image = [UIImage imageNamed:@"sex0"];
//    }
    [self.sexImageView qw_setImageUrlString:vo.user.adorn_medal placeholder:nil animation:nil];
    self.userLabel.text = vo.user.username;

    [self.userImageView qw_setImageUrlString:[QWConvertImageString convertPicURL:vo.user.avatar imageSizeType:QWImageSizeTypeAvatarThumbnail] placeholder:self.placeholder cornerRadius:16.5 borderWidth:0 borderColor:[UIColor clearColor] animation:YES completeBlock:nil];

    self.orderLabel.text = [NSString stringWithFormat:@"%@楼", vo.order];

    self.timeLabel.text = [QWHelper shortDateToString:vo.updated_time];

    NSString *content =  [[QWBannedWords sharedInstance] cryptoStringWithText:vo.content];
    if (vo.refer && ![vo.refer isEqualToNumber:@(-1)]) {
        content = [NSString stringWithFormat:@"回复%@楼: \n%@", vo.refer,content];
    }

    if (!content) {
        content = @"";
    }

    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:content];

//    [attributedText setYy_lineHeightMultiple:20];
    [attributedText setYy_minimumLineHeight:20];
    [attributedText setYy_maximumLineHeight:40];
    [attributedText setYy_color:HRGB(0x505050)];
    [attributedText setYy_font:[UIFont systemFontOfSize:14]];

    {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[QWExpressionManager sharedManager].pattern options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray<NSTextCheckingResult *> *result = [regex matchesInString:attributedText.string options:0 range:NSMakeRange(0, attributedText.string.length)];
        [result enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *expression = [content substringWithRange:obj.range];
            UIImage *image = [UIImage imageNamed:[expression substringWithRange:NSMakeRange(1, expression.length - 2)]];
            UIFont *font = [UIFont systemFontOfSize:14];
            NSAttributedString *attachmentString = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeCenter attachmentSize:image.size alignToFont:font alignment:YYTextVerticalAlignmentBottom];
            [attributedText replaceCharactersInRange:obj.range withAttributedString:attachmentString];
        }];
    }

    {
        WEAK_SELF;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"《([^《》]{1,})》" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray<NSTextCheckingResult *> *result = [regex matchesInString:attributedText.string options:0 range:NSMakeRange(0, attributedText.string.length)];
        [result enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            STRONG_SELF;
            YYTextHighlight *highlight = [YYTextHighlight new];
            [highlight setColor:HRGB(0xfea958)];
//            highlight.tapAction = [^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
//                NSMutableDictionary *params = @{}.mutableCopy;
//                params[@"book_name"] = [text attributedSubstringFromRange:range].string;
//                [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"search" andParams:params]];
//            } copy];
            [attributedText yy_setColor:HRGB(0xfea958) range:obj.range];
            [attributedText yy_setTextHighlight:highlight range:obj.range];
        }];
    }

    {
        WEAK_SELF;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@([^@《》\\[\\] ]{1,})( |$)" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray<NSTextCheckingResult *> *result = [regex matchesInString:attributedText.string options:0 range:NSMakeRange(0, attributedText.string.length)];
        [result enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            STRONG_SELF;
            YYTextHighlight *highlight = [YYTextHighlight new];
            [highlight setColor:HRGB(0xfb83ac)];
//            highlight.tapAction = [^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
//                NSString *username = [text attributedSubstringFromRange:obj.range].string;
//                username = [username substringWithRange:NSMakeRange(1, username.length - 1)];
//                username = [username stringByReplacingOccurrencesOfString:@" " withString:@""];
//                NSMutableDictionary *params = @{}.mutableCopy;
//                params[@"username"] = username;
//                [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"user" andParams:params]];
//            } copy];
            [attributedText yy_setColor:HRGB(0xfb83ac) range:obj.range];
            [attributedText yy_setTextHighlight:highlight range:obj.range];
        }];
    }
    
    {
        WEAK_SELF;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray<NSTextCheckingResult *> *result = [regex matchesInString:attributedText.string options:0 range:NSMakeRange(0, attributedText.length)];
        [result enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            STRONG_SELF;
            YYTextHighlight *highlight = [YYTextHighlight new];
            [highlight setColor:[UIColor blueColor]];
            [attributedText yy_setColor:[UIColor blueColor] range:obj.range];
            [attributedText yy_setTextUnderline:[YYTextDecoration decorationWithStyle:YYTextLineStyleSingle] range:obj.range];
            [attributedText yy_setTextHighlight:highlight range:obj.range];
        }];
    }

//    YYTextSimpleEmoticonParser *parser = [YYTextSimpleEmoticonParser new];
//    parser.emoticonMapper = [QWExpressionManager sharedManager].imagePattern;
//    self.contentLabel.textParser = parser;
    self.contentLabel.attributedText = attributedText;

    CGSize size = CGSizeMake([QWSize screenWidth] - 30, CGFLOAT_MAX);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:size text:attributedText];
    self.contentLabel.textLayout = layout;
}

+ (CGFloat)heightForCellData:(DiscussItemVO *)data
{
    DiscussItemVO *vo = data;
    NSString *content = vo.content;
    if (vo.refer && ![vo.refer isEqualToNumber:@(-1)]) {
        content = [NSString stringWithFormat:@"回复%@楼:\n%@", vo.refer, vo.content];
    }

    if (!content) {
        content = @"";
    }

    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:content];

//    [attributedText setYy_lineHeightMultiple:20];
    [attributedText setYy_minimumLineHeight:20];
    [attributedText setYy_maximumLineHeight:40];
    [attributedText setYy_color:HRGB(0x505050)];
    [attributedText setYy_font:[UIFont systemFontOfSize:14]];
    
    {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[QWExpressionManager sharedManager].pattern options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray<NSTextCheckingResult *> *result = [regex matchesInString:attributedText.string options:0 range:NSMakeRange(0, attributedText.string.length)];
        [result enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *expression = [content substringWithRange:obj.range];
            UIImage *image = [UIImage imageNamed:[expression substringWithRange:NSMakeRange(1, expression.length - 2)]];
            UIFont *font = [UIFont systemFontOfSize:16];
            NSAttributedString *attachmentString = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeCenter attachmentSize:image.size alignToFont:font alignment:YYTextVerticalAlignmentBottom];
            [attributedText replaceCharactersInRange:obj.range withAttributedString:attachmentString];
        }];
    }

    CGSize size = CGSizeMake([QWSize screenWidth] - 30, CGFLOAT_MAX);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:size text:attributedText];

    return layout.textBoundingSize.height + 50 + 10;
}

@end
