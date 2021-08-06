//
//  QWBulletView.m
//  Qingwen
//
//  Created by mumu on 16/12/8.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import "QWBulletView.h"

#define kPadding 5

#define kSpeed 100

@interface QWBulletView()

@property (nonatomic, strong) UILabel *textLable;
@property (nonatomic, strong) UIImageView *avatarImageView;

@property (assign) BOOL isWalking;

@property (assign) BOOL isDealloc;

@end

@implementation QWBulletView

- (instancetype)initWithBulletVO:(BulletVO *)bullet {
    if (self == [super init]) {
        if (bullet.placeholder) {
            self.bounds = CGRectMake(0, 0, 100, 24);
            self.placeholder = true;
            return self;
        }
        self.backgroundColor = [UIColor clearColor];
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:13],
                                     };
        CGSize size = CGSizeMake(UISCREEN_WIDTH - 10, CGFLOAT_MAX);
        CGRect frame = [bullet.value boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        
        self.avatarImageView = [UIImageView new];
        [self.avatarImageView qw_setImageUrlString:[QWConvertImageString convertPicURL:bullet.avatar imageSizeType:QWImageSizeTypeAvatarThumbnail] placeholder:[UIImage imageNamed:@"mycenter_logo"] cornerRadius:frame.size.height borderWidth:0.5 borderColor:[UIColor whiteColor] animation:false completeBlock:nil];
        self.avatarImageView.backgroundColor = [UIColor clearColor];
        
        self.textLable = [UILabel new];
        self.textLable.textColor = [UIColor whiteColor];
        
        if (bullet.isMine) {
            NSDictionary *attributes = @{
                                         NSFontAttributeName: [UIFont systemFontOfSize:13],
                                         NSForegroundColorAttributeName: [UIColor whiteColor],
                                         NSUnderlineStyleAttributeName: @1
                                         };
            self.textLable.attributedText = [[NSMutableAttributedString alloc]initWithString:[[QWBannedWords sharedInstance] cryptoStringWithText:bullet.value] attributes:attributes];
        } else {
            NSDictionary *attributes = @{
                                         NSFontAttributeName: [UIFont systemFontOfSize:13],
                                         NSForegroundColorAttributeName: [UIColor whiteColor]
                                         };
            self.textLable.attributedText = [[NSMutableAttributedString alloc]initWithString:[[QWBannedWords sharedInstance] cryptoStringWithText:bullet.value] attributes:attributes];
                                                                                                                      
        }
        
        if (bullet.showAvatar.boolValue) {
            self.bounds = CGRectMake(0, 0, frame.size.width + frame.size.height + kPadding * 3 + 50, frame.size.height);
            self.avatarImageView.frame = CGRectMake(0, 0, frame.size.height, frame.size.height);
            
            self.textLable.frame = CGRectMake(kPadding * 2 + frame.size.height, 0, frame.size.width, frame.size.height);
            [self addSubview:self.avatarImageView];
            [self addSubview:self.textLable];
        } else {
            self.bounds = CGRectMake(0, 0, frame.size.width + kPadding * 2 + 50, frame.size.height);
            self.textLable.frame = CGRectMake(kPadding, 0, frame.size.width, frame.size.height);
            self.avatarImageView.hidden = true;
            [self addSubview:self.textLable];
        }

    }
    return self;
}

- (void)startAnimation {
    //字数越长 跑的越慢 字数越短 跑的越快
    CGFloat wholeWidth = CGRectGetWidth(self.frame) + [QWSize screenWidth];
    CGFloat speed = kSpeed;
    CGFloat startDur = (CGRectGetWidth(self.frame) + 50) / speed;  //当前完全进入的时间
    CGFloat wholeDur = wholeWidth / speed;
    
    __block CGRect frame = self.frame;
    if (self.bulletMoveBlock) {
        self.bulletMoveBlock(QWBulletViewStart);
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(startDur * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //手动判断，是否已经释放了资源
        if (self.isDealloc) {
            return ;
        }
        if (self.bulletMoveBlock) {
            self.bulletMoveBlock(QWBulletViewEnter);
            self.isWalking = true;
        }
    });
    [UIView animateWithDuration:wholeDur delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        frame.origin.x = - CGRectGetWidth(frame);
        self.frame = frame;
    } completion:^(BOOL finished) {
        if (self.bulletMoveBlock) {
            self.bulletMoveBlock(QWBulletViewEnd);
            self.isWalking = false;
        }
        [self removeFromSuperview];
    }];
}

- (void)stopAnimation {
    self.isDealloc = true;
    [self.layer removeAllAnimations];
    [self removeFromSuperview];
}

- (void)dealloc {
//    NSLog(@"%@--call %@",[self class], NSStringFromSelector(_cmd));

}

@end
