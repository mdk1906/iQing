//
//  QWAuthenticationView.m
//  Qingwen
//
//  Created by mumu on 2017/8/10.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWAuthenticationView.h"
#import "AuthenticationVO.h"
#import <YYText/YYText.h>
#import <TencentOpenAPI/QQApiInterface.h>

@interface QWAuthenticationView()

@property (strong, nonatomic) IBOutlet YYLabel *attentionLabel;

@property (strong, nonatomic) IBOutlet UITextField *nameTF;

@property (strong, nonatomic) IBOutlet UITextField *IDCardTF;

@property (strong, nonatomic) IBOutlet UITextField *payeeMemberTF;

@property (strong, nonatomic) IBOutlet UITextField *payeeTypeTF;

@property (strong, nonatomic) IBOutlet UITextField *payeeNumberTF;

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) UIScrollView *scrollView;

@end
@implementation QWAuthenticationView

- (void)awakeFromNib {
    [super awakeFromNib];
    NSMutableAttributedString *mutableAttribut = [[NSMutableAttributedString alloc] initWithString:@"应国家相关法律规定，您必须绑定手机号并登记实名信息后方可投稿。如需登记或修改，请联系客服 QQ：3012575446" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12],
                                                                                                                                                                       NSForegroundColorAttributeName:
                                                                                                                                                                           HRGB(0x888888)}];
    
    WEAK_SELF;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"3012575446" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray <NSTextCheckingResult *> *result = [regex matchesInString:mutableAttribut.string options:0 range:NSMakeRange(0, mutableAttribut.string.length)];
    [result enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        STRONG_SELF;
        YYTextHighlight *highlight = [YYTextHighlight new];
//        [highlight setColor:HRGB(0xfea958)];
        highlight.tapAction = ^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            STRONG_SELF;
            NSString *qq = [text attributedSubstringFromRange:range].string;
            if ([QQApiInterface isQQInstalled]) {
                [[QWShareManager sharedInstance] sendMessageWithqq:qq];
            }
            else {
                UIPasteboard *pb = [UIPasteboard generalPasteboard];
                pb.string = qq;
                [self showToastWithTitle:@"复制成功" subtitle:nil type:ToastTypeAlert];
            }
        };
        [mutableAttribut yy_setColor:[UIColor colorQWPinkDark] range:obj.range];
        [mutableAttribut yy_setUnderlineStyle:NSUnderlineStyleSingle range:obj.range];
        [mutableAttribut yy_setTextHighlight:highlight range:obj.range];
    }];
    self.attentionLabel.attributedText = mutableAttribut;
}

- (void)showWithAuthor:(AuthenticationVO *)vo {
    self.nameTF.text = vo.real_name;
    self.IDCardTF.text = vo.id_card;
    self.payeeMemberTF.text = vo.wallet_name;
    self.payeeTypeTF.text = vo.channel;
    self.payeeNumberTF.text = vo.wallet_account;
}

@end
