//
//  QWVIPView.m
//  Qingwen
//
//  Created by qingwen on 2018/10/15.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import "QWVIPView.h"
@interface QWVIPView()
@property (nonatomic, assign) id target;//让谁去执行方法
@property (nonatomic, assign) SEL action;//执行的方法
@end
@implementation QWVIPView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        self.backImg = [UIImageView new];
        self.backImg.backgroundColor = [UIColor whiteColor];
        self.backImg.frame = CGRectMake(12, 0, UISCREEN_WIDTH-24, 58);
        self.backImg.layer.cornerRadius = 3;
        self.backImg.layer.masksToBounds = YES;
        self.backImg.layer.borderColor = HRGB(0xe9e9e9).CGColor;
        self.backImg.layer.borderWidth = 1;
        [self addSubview:self.backImg];
        
        
    }
    
    return self;
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //让目标实现(点击)执行的方法
    [self.target performSelector:self.action withObject:self];
}

-(void)addTarget:(id)target selector:(SEL)selector
{
    self.action =selector;
    self.target =target;
}

-(void)setTitle:(NSString *)title give:(NSString*)give money:(NSString *)money deleteMoney:(NSString*)deleteMoney{
    _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(11+12, 0, 60, 58)];
    _titleLab.text = title;
    _titleLab.textColor = HRGB(0x6F6F6F);
    _titleLab.font = [UIFont systemFontOfSize:16];
    [self addSubview:_titleLab];
    
    _givingLab = [[UILabel alloc] initWithFrame:CGRectMake(kMaxX(_titleLab.frame)+5, 0, [QWSize autoWidth:give width:200 height:58 num:16], 58)];
    _givingLab.textColor = HRGB(0xF77590);
    _givingLab.font = [UIFont systemFontOfSize:16];
    _givingLab.text = give;
    [self addSubview:_givingLab];
    
    _recommendedImg  = [[UIImageView alloc] initWithFrame:CGRectMake(kMaxX(_givingLab.frame)+8, 21, 40, 17)];
    _recommendedImg.image = [UIImage imageNamed:@"推荐"];
    _recommendedImg.hidden = YES;
    [self addSubview:_recommendedImg];
    
    _moneyLab = [[UILabel alloc] initWithFrame:CGRectMake(UISCREEN_WIDTH-12-[QWSize autoWidth:money width:200 height:58 num:16]-13, 0, [QWSize autoWidth:money width:200 height:58 num:16], 58)];
    _moneyLab.textColor = HRGB(0xF77590);
    _moneyLab.text = money;
    _moneyLab.font = [UIFont systemFontOfSize:16];
    _moneyLab.textAlignment = 2;
    [self addSubview:_moneyLab];
    
    _deleteMoneyLab = [[UILabel alloc] initWithFrame:CGRectMake(UISCREEN_WIDTH-76-[QWSize autoWidth:deleteMoney width:200 height:58 num:10], 0, [QWSize autoWidth:deleteMoney width:200 height:58 num:10], 58)];
    _deleteMoneyLab.textColor = HRGB(0xB3B1B1);
    _deleteMoneyLab.text = deleteMoney;
    _deleteMoneyLab.font = [UIFont systemFontOfSize:10];
    _deleteMoneyLab.textAlignment = 1;
    [self addSubview:_deleteMoneyLab];
    
    _hui = [UIView new];
    _hui.frame = CGRectMake(UISCREEN_WIDTH-76-[QWSize autoWidth:deleteMoney width:200 height:58 num:10], 28, [QWSize autoWidth:deleteMoney width:200 height:58 num:10], 1);
    _hui.backgroundColor = HRGB(0xB3B1B1);
    
    [self addSubview:_hui];
    if ([deleteMoney isEqualToString:@"¥"]) {
        _deleteMoneyLab.hidden = YES;
        _hui.hidden = YES;
    }
}
@end
