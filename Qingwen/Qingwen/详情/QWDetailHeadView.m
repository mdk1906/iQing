//
//  QWDetailHeadView.m
//  Qingwen
//
//  Created by Aimy on 9/9/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWDetailHeadView.h"
#import "QWBaseCVCell.h"
#import <YYText.h>

@interface QWDetailHeadView ()

@property (strong, nonatomic) IBOutlet UIView *backgroundView;

@property (strong, nonatomic) IBOutlet UIButton *gotoReadingBtn;

@property (strong, nonatomic) IBOutlet UIImageView *bookImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleHeightConstraints;

@property (strong, nonatomic) IBOutlet UILabel *chargeLabel;
@property (strong, nonatomic) IBOutlet UILabel *heavyChargeLabel;
@property (strong, nonatomic) IBOutlet UIButton *countBtn;

@property (strong, nonatomic) IBOutlet YYLabel *introLabel;

@property (strong, nonatomic) IBOutlet UILabel *countAndUpdateLabel;

@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UIImageView *authorImageView;

@property (nonatomic, strong) BookVO *book;

@property (nonatomic) CGFloat height;

@property (strong, nonatomic) UIVisualEffectView *blurView;
@property (strong, nonatomic) IBOutlet UIImageView *effectBgView;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *categoryBtns;

@property (strong, nonatomic) IBOutlet UIButton *payBtn;

@property (weak, nonatomic) IBOutlet UIButton *rankBtn;
@property (weak, nonatomic) IBOutlet UIButton *endBtn;
@property (weak, nonatomic) IBOutlet UILabel *updateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bookImageVIewTopConstraint;

@end

@implementation QWDetailHeadView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.bookImageView.layer.masksToBounds = YES;
    
    self.effectBgView.clipsToBounds = YES;
    self.titleLabel.userInteractionEnabled = false;
    if (IOS_SDK_MORE_THAN(8.0)) {
        self.blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        self.blurView.translatesAutoresizingMaskIntoConstraints = NO;
        self.blurView.alpha = .95f;
        [self.effectBgView addSubview:self.blurView];
        [self.blurView autoCenterInSuperview];
        [self.blurView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.effectBgView];
        [self.blurView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.effectBgView];
    }
    //iphoneX
    if(ISIPHONEX){
        if (@available(iOS 11.0, *)) {
            [self.backgroundView autoSetDimension:ALDimensionHeight toSize:404];
            self.bookImageVIewTopConstraint.constant = 118;
        }
    }
}

- (void)updateWithBook:(BookVO *)book andAttention:(NSNumber *)attention showAll:(BOOL)showAll
{
    self.book = book;
    
    VolumeCD *volumeCD = [VolumeCD findLastReadingVolumeWithBookId:book.nid];
    if (volumeCD) {
        [self.gotoReadingBtn setTitle:@"继续阅读" forState:UIControlStateNormal];
    }
    else {
        [self.gotoReadingBtn setTitle:@"开始阅读" forState:UIControlStateNormal];
    }
    
    [self.categoryBtns enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < book.categories.count) {
            CategoryItemVO *itemVO = book.categories[idx];
            [obj setTitle:[NSString stringWithFormat:@" %@ ", itemVO.name] forState:UIControlStateNormal];
        }
        else {
            obj.hidden = YES;
        }
    }];
    
    [self.bookImageView qw_setImageUrlString:[QWConvertImageString convertPicURL:book.cover imageSizeType:QWImageSizeTypeCoverThumbnail] placeholder:[UIImage imageNamed:@"placeholder114x1 52"] animation:YES];
    if (IOS_SDK_MORE_THAN(8.0)) {
        self.effectBgView.image = [UIImage imageWithColor:HRGB(0xF1F1F1)];
        [self.effectBgView qw_setImageUrlString:[QWConvertImageString convertPicURL:book.cover imageSizeType:QWImageSizeTypeCoverThumbnail] placeholder:nil animation:YES];
    }
    else {
        self.effectBgView.image = [UIImage imageWithColor:HRGB(0x505050)];
    }
    
    self.titleLabel.text = book.title;
    //当字数过多时,会
    if ([self.titleLabel getSizeWithWidth:self.titleLabel.frame.size.width - 20 textString:book.title].height > self.titleLabel.frame.size.height) {
        self.titleLabel.userInteractionEnabled = true;
        [self.titleLabel bk_whenTapped:^{
            [self showToastWithTitle:book.title subtitle:nil type:ToastTypeAlert];
        }];
    }else {
        self.titleLabel.userInteractionEnabled = false;
    }
    
    [self addRankBtn];
    [self addEndBtn];
    [self addPayingBtn];
    
    self.authorLabel.text = book.author_name;
    self.updateLabel.text = [NSString stringWithFormat:@"更新时间: %@",[QWHelper shortDate1ToString:book.updated_time]];
    UserVO *user = self.book.author.firstObject;
    if (user) {
        [self.authorImageView qw_setImageUrlString:[QWConvertImageString convertPicURL:user.avatar imageSizeType:QWImageSizeTypeAvatarThumbnail] placeholder:[UIImage imageNamed:@"mycenter_logo"] animation:YES];
    }
    self.chargeLabel.text = [NSString stringWithFormat:@"信仰: %@   战力: %@", [QWHelper countToShortString:book.belief] ?: @0, [QWHelper countToShortString:book.combat] ?: @0];
    
    [self.countBtn setTitle:[NSString stringWithFormat:@" %@ ",[QWHelper countToString:book.count]] forState:UIControlStateNormal];
    self.countBtn.hidden = false;
    if ([book.is_vip isEqualToString:@"1"]) {
        [self.countBtn setTitle:@"VIP" forState:UIControlStateNormal];
        [self.countBtn setBackgroundImage:book.vipImg forState:0];
        self.countBtn.hidden = false;
        self.countBtn.titleLabel.textAlignment = 1;
    }
    self.countAndUpdateLabel.text = [NSString stringWithFormat:@"%@轻石／%@重石／%@人气／%@收藏", [QWHelper countToShortString:book.coin], [QWHelper countToShortString:book.gold], [QWHelper countToShortString:book.views], [QWHelper countToShortString:book.follow_count]];
    
    [self setupIntroLabel:showAll];
}

//设置intro
- (void)setupIntroLabel: (BOOL)showAll {
    
    if (showAll) {
        self.introLabel.numberOfLines = 0;
    }
    else {
        self.introLabel.numberOfLines = 2;
    }
    
    NSString *introText = [NSString stringWithFormat:@"简介: %@",self.book.intro];
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
                [self.delegate headView:self didClickedShowAllBtn:nil];
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
- (CGFloat)heightWithBook:(BookVO *)book
{
    if (!book) {
        return 320;
    }
    
    if (self.height > 0) {
        return self.height;
    }
    
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize: 12], NSForegroundColorAttributeName: HRGB(0xAEAEAE)};
    CGSize size = CGSizeMake(UISCREEN_WIDTH - 20, CGFLOAT_MAX);
    CGRect frame = [book.intro boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    self.height = frame.size.height + 280;
    return self.height;
}

+ (CGFloat)minHeightWithBook:(BookVO *)book
{
    return 320;
}

- (IBAction)onPressedImageView:(id)sender {
    if (self.book.cover.length) {
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"pictures"] = @[self.book.cover];
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"picture" andParams:params]];
    }
}

- (IBAction)onPressedChargeBtn:(id)sender {
    [self.delegate headView:self didClickedChargeBtn:sender];
}

- (IBAction)onPressedHeavyChargeBtn:(id)sender {
    [self.delegate headView:self didClickedHeavyChargeBtn:sender];
}

- (IBAction)onPressedPressBtn:(id)sender {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"book_url"] = self.book.press_url;
    params[@"title"] = self.book.press;
    [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"list" andParams:params]];
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

- (IBAction)onPressedCategoryBtn:(UIButton *)sender {
    
    CategoryItemVO *vo = self.book.categories[sender.tag];
    //    [vo toList];
    //    NSMutableDictionary *params = [NSMutableDictionary new];
    //    params["title"] = "小说库";
    //    params["tags"] = [[3,"日轻"],[1,"战力"]]
    //    params["categories"] = 12
    //    params["riqing"] = 1
    //    params["order"] = 1
    //    params = {"title":"小说库","tags":[],"categories":""}
    //    QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "booklibrary", andParams: params))
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"title"] = @"小说库";
    params[@"tags"] = @[@[@3,vo.name],@[@1,@"更新"]];
    params[@"order"] = @1;
    [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"booklibrary" andParams:params]];
}

- (IBAction)onPressedDirectoryBtn:(id)sender {
    [self.delegate headView:self didClickedDirectoryBtn:sender];
}

- (IBAction)onPressedGotoReadingBtn:(id)sender {
    [self.delegate headView:self didClickedGotoReadingBtn:sender];
}

- (IBAction)onPressedBtningBtn:(id)sender {
    [self.delegate headView:self didClickedShowAllBtn:nil];
}


- (void)addRankBtn {
    switch (self.book.rank.integerValue) {
        case 4: //黄金
            [self.rankBtn setTitle:@"黄金" forState:UIControlStateNormal];
            [self.rankBtn setBackgroundColor:HRGB(0xE6CA70)];
            self.rankBtn.hidden = false;
            break;
        case 3: //白银
            [self.rankBtn setTitle:@"白银" forState:UIControlStateNormal];
            [self.rankBtn setBackgroundColor:HRGB(0xA5BBD4)];
            self.rankBtn.hidden = false;
            break;
        case 5: //签约
            [self.rankBtn setTitle:@"青铜" forState:UIControlStateNormal];
            [self.rankBtn setBackgroundColor:HRGB(0x76914F)];
            self.rankBtn.hidden = false;
            break;
        case 6:
            [self.rankBtn setTitle:@"白金" forState:UIControlStateNormal];
            [self.rankBtn setBackgroundColor:HRGB(0xFF6A19)];
            self.rankBtn.hidden = false;
            break;
        default:
            self.rankBtn.hidden = true;
            break;
    }
}

- (void)addEndBtn{
    //    switch (self.book.end.integerValue) {
    ////
    //        case 0:
    //
    //            break;
    //        case 1:
    //            [self.endBtn setTitle:@"完结" forState:UIControlStateNormal];
    //            [self.endBtn setBackgroundColor:HRGB(0xB77AF5)];
    //            self.endBtn.hidden = false;
    //        default:
    //
    //            break;
    //    }
    if (self.book.end.integerValue == 0) {
        [self.endBtn setTitle:@"连载" forState:UIControlStateNormal];
        [self.endBtn setBackgroundColor:HRGB(0x7AC4F5)];
        self.endBtn.hidden = false;
    }
    else if (self.book.end.integerValue == 1){
        [self.endBtn setTitle:@"完结" forState:UIControlStateNormal];
        [self.endBtn setBackgroundColor:HRGB(0xB77AF5)];
        self.endBtn.hidden = false;
    }
    else{
        self.endBtn.hidden = true;
    }
}
- (void)addPayingBtn {
    if (self.book.need_pay.integerValue > 0) {
        switch (self.book.discount.integerValue) {
            case 100:
                [self.payBtn setTitle:@"付费" forState:UIControlStateNormal];
                [self.payBtn setBackgroundColor:HRGB(0xfa8490)];
                self.payBtn.hidden = false;
                break;
            case 0:
                [self.payBtn setTitle:@"限免" forState:UIControlStateNormal];
                [self.payBtn setBackgroundColor:HRGB(0x6cc3c1)];
                self.payBtn.hidden = false;
                break;
            default:
            {   if ([self.book.channel intValue] == 14){
                
            }else{
                NSInteger value = (100 - self.book.discount.integerValue);
                NSString *discount = @"";
                if(100 > self.book.discount.integerValue){
                    discount = [NSString stringWithFormat:@" -%ld％ ",value];
                    [self.payBtn setTitle:discount forState:UIControlStateNormal];
                    [self.payBtn setBackgroundColor:HRGB(0x6cc3c1)];
                }else{
                    [self.payBtn setTitle:@"付费" forState:UIControlStateNormal];
                    [self.payBtn setBackgroundColor:HRGB(0xfa8490)];
                }
                self.payBtn.hidden = false;
            }
                
                break;
            }
        }
    }
    else {
        self.payBtn.hidden = true;
    }
}


@end
