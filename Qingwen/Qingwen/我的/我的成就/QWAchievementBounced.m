//
//  QWAchievementBounced.m
//  Qingwen
//
//  Created by qingwen on 2018/9/17.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import "QWAchievementBounced.h"
#import "QWMyAchievementVC.h"

@interface QWAchievementBounced()
{
    UIView *backView;
    UIImageView *imgView;
    UILabel *titleLab;
    UILabel *contentLab;
    UILabel *rewardLab;
    UIButton *checkBtn;
    UIButton *cancelBtn;
}
@end
@implementation QWAchievementBounced

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame dict:(NSDictionary *)data{
    if (self == [super initWithFrame:frame]) {
        NSLog(@"数据字典 = %@",data);
        backView = [UIView new];
        backView.frame = CGRectMake(0, 0, UISCREEN_WIDTH, UISCREEN_HEIGHT);
        backView.userInteractionEnabled = YES;
        backView.backgroundColor = HRGB(0x000000);
        backView.alpha = 0.8;
        [self addSubview:backView];
        
        UIImageView *shineImg = [UIImageView new];
        shineImg.image = [UIImage imageNamed:@"旋转"];
        shineImg.frame = CGRectMake((UISCREEN_WIDTH-UISCREEN_WIDTH*0.842)/2, (UISCREEN_HEIGHT-UISCREEN_WIDTH*0.842)/2+20, UISCREEN_WIDTH*0.842, UISCREEN_WIDTH*0.842);
        
        CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 1.0];
        rotationAnimation.duration = 10;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = HUGE_VALF;
        [shineImg.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        
        [self addSubview:shineImg];
        
        imgView = [UIImageView new];
        imgView.image = [UIImage imageNamed:@"文字框"];
        imgView.frame = CGRectMake(58, (UISCREEN_HEIGHT-(UISCREEN_WIDTH-116)*0.817)/2, UISCREEN_WIDTH-116, (UISCREEN_WIDTH-116)*0.817);
        imgView.userInteractionEnabled = YES;
        [self addSubview:imgView];
        
        titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 110, UISCREEN_WIDTH-116, 20)];
//        titleLab.textColor = HRGB(0x4b1724);
//        titleLab.font = [UIFont systemFontOfSize:16];
        titleLab.textAlignment = 1;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]init];
        NSString *str0 = @"恭喜达成 ";
        NSDictionary *dictAttr0 = @{NSFontAttributeName:[UIFont boldSystemFontOfSize: 16],NSForegroundColorAttributeName:HRGB(0x4b1724)};
        NSAttributedString *attr0 = [[NSAttributedString alloc]initWithString:str0 attributes:dictAttr0];
        
        NSString *str1 = data[@"task_name"];
        NSDictionary *dictAttr1 = @{NSFontAttributeName:[UIFont boldSystemFontOfSize: 20],NSForegroundColorAttributeName:HRGB(0xCC214A)};
        NSAttributedString *attr1 = [[NSAttributedString alloc]initWithString:str1 attributes:dictAttr1];
        
        NSString *str2 = @"成就";
        NSDictionary *dictAttr2 = @{NSFontAttributeName:[UIFont boldSystemFontOfSize: 16],NSForegroundColorAttributeName:HRGB(0x4b1724)};
        NSAttributedString *attr2 = [[NSAttributedString alloc]initWithString:str2 attributes:dictAttr2];
        [attributedString appendAttributedString:attr0];
        [attributedString appendAttributedString:attr1];
        [attributedString appendAttributedString:attr2];
        titleLab.attributedText = attributedString;
        [imgView addSubview:titleLab];
        
        contentLab = [[UILabel alloc] initWithFrame:CGRectMake(0, kMaxY(titleLab.frame)+10, UISCREEN_WIDTH-116, 20)];
        contentLab.textColor = HRGB(0x666666);
        contentLab.font = [UIFont systemFontOfSize:14];
        contentLab.text = data[@"task_conrats"];
        contentLab.textAlignment = 1;
        [imgView addSubview:contentLab];
        
        rewardLab = [[UILabel alloc] initWithFrame:CGRectMake(0, kMaxY(contentLab.frame)+10, UISCREEN_WIDTH-116, 20)];
        rewardLab.textColor = HRGB(0x666666);
        rewardLab.font = [UIFont systemFontOfSize:14];
        rewardLab.text = data[@"task_instruction"];
        rewardLab.textAlignment = 1;
        [imgView addSubview:rewardLab];
        
        checkBtn = [UIButton new];
        checkBtn.frame = CGRectMake((UISCREEN_WIDTH-123)/2, kMaxY(imgView.frame)-123*0.282/2, 123, 123*0.282);
        [checkBtn setImage:[UIImage imageNamed:@"按钮-1"] forState:0];
        [checkBtn addTarget:self action:@selector(onpressClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:checkBtn];
        
        cancelBtn = [UIButton new];
        cancelBtn.frame = CGRectMake((UISCREEN_WIDTH-40)/2, kMaxY(imgView.frame)+ 40, 40, 40);
        [cancelBtn setImage:[UIImage imageNamed:@"成就弹框取消"] forState:0];
        [cancelBtn addTarget:self action:@selector(onpressCancel) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelBtn];
    }
    return self;
}
-(void)onpressCancel{
    NSLog(@"取消");
    [self removeFromSuperview];
}
-(void)onpressClick{
    NSLog(@"跳转");
    QWMyAchievementVC *vc = [QWMyAchievementVC new];
    
    UITabBarController *tabBarVc = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController *nav = (UINavigationController *)tabBarVc.selectedViewController;
    [nav pushViewController:vc animated:YES];
    [self removeFromSuperview];
}
@end
