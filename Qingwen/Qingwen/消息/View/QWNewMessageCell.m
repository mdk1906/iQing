//
//  QWNewMessageCell.m
//  Qingwen
//
//  Created by mumu on 17/3/3.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWNewMessageCell.h"
#import <YYText.h>
#import "ExpandVO.h"
#import "NSString+url.h"

#define kPadding  8

@interface QWNewMessageCell()
@property (strong, nonatomic) IBOutlet UIButton *dateBtn;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bubbleImageView;

@property (strong, nonatomic) IBOutlet  UIButton *linkBtn;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *linkLabelHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *dateViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contenLabelTrailling;

@property (strong, nonatomic) NewMessageVO *message;
@end

@implementation QWNewMessageCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contenLabelTrailling.constant = UISCREEN_WIDTH / 5;
    self.linkBtn.userInteractionEnabled = false;
    WEAK_SELF;
    [self.bubbleImageView bk_whenTapped:^{
        STRONG_SELF;
        NSLog(@"%@",self.message);
        if ([self.message.expand.links isEmpty]) {
            return;
        }
        NSString *routerString = [NSString getRouterVCUrlStringFromUrlString:self.message.expand.links];
        
        [[QWRouter sharedInstance] routerWithUrlString:routerString];
    }];
}

- (void)updateCellWithMessageVO:(NewMessageVO *)message {
    if (!message) {
    }
    self.message = message;
    if (message.showDateTime) {
        self.dateViewHeightConstraint.constant = 45;
    }
    else {
        self.dateViewHeightConstraint.constant = 0;
    }
    if (message.expand.links.length > 0) {
        self.linkLabelHeightConstraint.constant = 27;
        self.linkBtn.hidden = false;
    }
    else {
        self.linkLabelHeightConstraint.constant = 0;
        self.linkBtn.hidden = true;
    }
    
    if (message.showDateTime) {
        [self.dateBtn setTitle:[QWHelper shortDateToString:message.created_time] forState:UIControlStateNormal];
    }
    
    if (message.content) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineHeightMultiple = 1.4;
        NSRange range = NSMakeRange(0, message.content.length);
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:message.content];
        [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
        WEAK_SELF;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"《([^《》]{1,})》" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray<NSTextCheckingResult *> *result = [regex matchesInString:message.content options:0 range:NSMakeRange(0, message.content.length)];
        [result enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            STRONG_SELF;
            [attributedText yy_setColor:HRGB(0xfea958) range:obj.range];
        }];
        self.contentLabel.attributedText = attributedText;
        
    }
}

- (void)updateAvatarImage:(NSString *)avatar {
    [self.avatarImageView qw_setImageUrlString:[QWConvertImageString convertPicURL:avatar imageSizeType:QWImageSizeTypeAvatar] placeholder:self.placeholder animation:true];
//    self.avatarImageView.image = [UIImage imageNamed:@"message_test"];
}


+ (CGFloat)heightWithMessage:(NewMessageVO *)message {
    if (!message) {
        return 105;
    }
    
    CGFloat height = 105;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 1.4;
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize: 14], NSForegroundColorAttributeName: HRGB(0x333333), NSParagraphStyleAttributeName: paragraphStyle};
    CGFloat width = UISCREEN_WIDTH - kPadding - 50 - 25 - (UISCREEN_WIDTH / 5);
    CGSize size = CGSizeMake(width, CGFLOAT_MAX);
    CGRect frame = [message.content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    
    if (!message.showDateTime) {
        height = height - 45;
    }
    if (message.expand.links.length == 0 || !message.expand) {
        height = height - 27;
        frame.size.height = frame.size.height > (50 - kPadding * 2) ? frame.size.height : (50 - kPadding * 2);
    }

//    frame.size.height = frame.size.height > 60 ? frame.size.height: 60;
    height = height + frame.size.height - 17;
    return height > 55 ? height : 55;
}
@end
