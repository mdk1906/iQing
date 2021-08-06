//
//  QWAnnouncementView.m
//  Qingwen
//
//  Created by qingwen on 2018/12/14.
//  Copyright © 2018 iQing. All rights reserved.
//

#import "QWAnnouncementView.h"
@interface QWAnnouncementView()

@property (nonatomic, strong) UILabel *titles;

@property (nonatomic, strong) UILabel *content;

@property (nonatomic, strong) UIButton *sureBtn;

@property (nonatomic, strong) UIView *alertView;
@end

@implementation QWAnnouncementView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.8;
        [self setupView];
    }
    return self;
}
-(instancetype)initWithFrame2:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.8;
        [self setupView2];
    }
    return self;
}
-(void)setupView{
    _alertView = [UIView new];
    _alertView.frame = CGRectMake(20, (UISCREEN_HEIGHT-300)/2, UISCREEN_WIDTH-40, 300);
    _alertView.backgroundColor = [UIColor whiteColor];
    _alertView.layer.cornerRadius = 3;
    _alertView.layer.masksToBounds = YES;
    [self addSubview:_alertView];
    
    _titles = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, UISCREEN_WIDTH-40, 20)];
    _titles.textColor = HRGB(0x595656);
    _titles.textAlignment = 1;
    _titles.font = [UIFont systemFontOfSize:20];
    _titles.text = @"公告";
    [_alertView addSubview:_titles];
    
    _content = [[UILabel alloc] initWithFrame:CGRectMake(0, kMaxY(_titles.frame)+25, UISCREEN_WIDTH-40, 150)];
    _content.textColor = HRGB(0x828080);
    _content.font = [UIFont systemFontOfSize:14];
    _content.text = @"“ 根据相关政策规定，应主管部门要求，\n轻文将暂时停止公开服务。\n\n恢复时间待定，有新的进展我们会在第一时间发布公告，\n请耐心等待。\n\n对于暂停公开服务期间给用户带来的不便，\n我们将在服务恢复后统一进行补偿。 ”";
    _content.numberOfLines = 0;
    _content.textAlignment = 1;
    [_alertView addSubview:_content];
    
    _sureBtn = [UIButton new];
    [_sureBtn setTitle:@"确定" forState:0];
    _sureBtn.backgroundColor = HRGB(0x83B4FF);
    _sureBtn.frame = CGRectMake(18, kMaxY(_content.frame)+20, UISCREEN_WIDTH-40-18-18, 34);
    [_sureBtn setTitleColor:[UIColor whiteColor] forState:0];
    _sureBtn.layer.cornerRadius = 3;
    [_sureBtn bk_whenTapped:^{
        [self->_alertView removeFromSuperview];
        [self removeFromSuperview];
        
    }];
    _sureBtn.layer.masksToBounds = YES;
    [_alertView addSubview:_sureBtn];
    
}
-(void)setupView2{
    _alertView = [UIView new];
    _alertView.frame = CGRectMake(20, (UISCREEN_HEIGHT-300)/2, UISCREEN_WIDTH-40, 300);
    _alertView.backgroundColor = [UIColor whiteColor];
    _alertView.layer.cornerRadius = 3;
    _alertView.layer.masksToBounds = YES;
    
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    [window addSubview:_alertView];
    
    _titles = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, UISCREEN_WIDTH-40, 20)];
    _titles.textColor = HRGB(0x595656);
    _titles.textAlignment = 1;
    _titles.font = [UIFont systemFontOfSize:20];
    _titles.text = @"公告";
    [_alertView addSubview:_titles];
    
    _content = [[UILabel alloc] initWithFrame:CGRectMake(0, kMaxY(_titles.frame)+25, UISCREEN_WIDTH-40, 150)];
    _content.textColor = HRGB(0x828080);
    _content.font = [UIFont systemFontOfSize:14];
    _content.text = @"“ 根据相关政策规定，应主管部门要求，\n轻文将暂时停止公开服务。\n\n恢复时间待定，有新的进展我们会在第一时间发布公告，\n请耐心等待。\n\n对于暂停公开服务期间给用户带来的不便，\n我们将在服务恢复后统一进行补偿。 ”";
    _content.numberOfLines = 0;
    _content.textAlignment = 1;
    [_alertView addSubview:_content];
    
    _sureBtn = [UIButton new];
    [_sureBtn setTitle:@"确定" forState:0];
    _sureBtn.backgroundColor = HRGB(0x83B4FF);
    _sureBtn.frame = CGRectMake(18, kMaxY(_content.frame)+20, UISCREEN_WIDTH-40-18-18, 34);
    [_sureBtn setTitleColor:[UIColor whiteColor] forState:0];
    _sureBtn.layer.cornerRadius = 3;
    [_sureBtn bk_whenTapped:^{
        [self->_alertView removeFromSuperview];
        [self removeFromSuperview];
        
    }];
    _sureBtn.layer.masksToBounds = YES;
    [_alertView addSubview:_sureBtn];
    
}
-(UIViewController *) getTopVC{
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (1) {
        //顶层控制器 可能是 UITabBarController的跟控制器
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        
        //顶层控制器 可能是 push出来的 或者是跟控制器
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        
        //顶层控制器 可能是 modal出来的
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    
    return vc;
}


@end
