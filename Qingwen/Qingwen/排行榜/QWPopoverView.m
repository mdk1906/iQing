//
//  QWPopoverView.m
//  Qingwen
//
//  Created by mumu on 16/9/20.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import "QWPopoverView.h"
#import "QWColor.h"

#define kArrowHeight 10.f
#define kArrowCurvature 6.f
#define SPACE 2.f
#define ROW_HEIGHT 30.f
#define TITLE_FONT [UIFont systemFontOfSize:14]

@interface QWPopoverView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (assign) CGSize size;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic) CGPoint showPoint;
@property (nonatomic, copy)NSString *currentTitle;

@property (nonatomic, strong) UIButton *handerView;

@end

@implementation QWPopoverView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.borderColor = RGB(200, 199, 204);
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

-(id)initWithPoint:(CGPoint)point titles:(NSArray *)titles currentSelected:(NSString *)selectedTitle images:(NSArray *)images
{
    self = [super init];
    if (self) {
        self.showPoint = point;
        self.titleArray = titles;
        self.imageArray = images;
        self.currentTitle = selectedTitle;
        self.size = [UIScreen mainScreen].bounds.size;
        self.frame = [self getViewFrame];
        
        [self addSubview:self.tableView];
        
    }
    return self;
}
- (instancetype)initWithPoint:(CGPoint)point titles:(NSArray *)titles size:(CGSize)size {
    self = [super init];
    if (self) {
        self.showPoint = point;
        self.titleArray = titles;
        self.size = size;
        self.style = UITableViewCellStyleValue1;
        self.frame = [self getViewFrame];
        [self addSubview:self.tableView];
    }
    return self;
}

- (instancetype)initWithPoint:(CGPoint)point titles:(NSArray *)titles size:(CGSize)size stype:(UITableViewCellStyle)style{
    self = [super init];
    if (self) {
        self.showPoint = point;
        self.titleArray = titles;
        self.size = size;
        self.frame = [self getViewFrame];
        self.style = style;
        [self addSubview:self.tableView];
    }
    return self;
}
-(CGRect)getViewFrame
{
    CGRect frame = CGRectZero;
    
    frame.size.width = self.size.width;
    frame.size.height = [self.titleArray count] * ROW_HEIGHT + SPACE + kArrowHeight;
    
    if (frame.size.height > self.size.height ) {
        frame.size.height = self.size.height;
    }
    
    if ([self.titleArray count] == [self.imageArray count]) {
        frame.size.width = 10 + 25 + 10 + frame.size.width + 40;
    }else{
        frame.size.width = frame.size.width;
    }
    
    frame.origin.x = self.showPoint.x - frame.size.width / 2;
    frame.origin.y = self.showPoint.y;
    
    return frame;
}


-(void)show
{
    self.handerView = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [_handerView setFrame:[UIScreen mainScreen].bounds];
    [_handerView setFrame:[UIScreen mainScreen].bounds];
    [_handerView setBackgroundColor:[UIColor clearColor]];
    [_handerView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_handerView addSubview:self];
    
    [[UIApplication sharedApplication].keyWindow addSubview:_handerView];
    
    self.alpha = 0.f;
    self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionTransitionFlipFromTop animations:^{
        self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.08f delay:0.f options:UIViewAnimationOptionTransitionFlipFromTop animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

-(void)dismiss
{
    [self dismiss:YES];
}

-(void)dismiss:(BOOL)animate
{
    if (!animate) {
        [_handerView removeFromSuperview];
        return;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        self.alpha = 0.f;
        self.handerView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self.handerView removeFromSuperview];
    }];
    
}

#pragma mark - UITableView

-(UITableView *)tableView
{
    if (_tableView != nil) {
        return _tableView;
    }
    
    CGRect rect = self.frame;
    rect.origin.y = 0;
    rect.origin.x = 0;
    
    rect.size.height = self.frame.size.height - 12;
    
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.alwaysBounceHorizontal = NO;
    _tableView.alwaysBounceVertical = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.scrollEnabled = YES;
    _tableView.backgroundColor = [UIColor colorF8];
    //    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    return _tableView;
}

#pragma mark - UITableView DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_titleArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        if (_style) {
            cell = [[UITableViewCell alloc] initWithStyle:_style reuseIdentifier:identifier];
        }
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    cell.backgroundView = [[UIView alloc] init];
    cell.backgroundView.backgroundColor = [UIColor whiteColor];
    
    if ([_imageArray count] == [_titleArray count]) {
        cell.imageView.image = [UIImage imageNamed:[_imageArray objectAtIndex:indexPath.row]];
    }
    cell.textLabel.font = TITLE_FONT;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    
    
    NSDictionary *dic = [_titleArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [dic objectForKey:@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"code"]];
    
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.selectRowAtIndex) {
        self.selectRowAtIndex(indexPath.row);
    }
    [self dismiss:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}

- (void)drawRect:(CGRect)rect
{
    //    [self.borderColor set]; //设置线条颜色
    //
    //    CGRect frame = CGRectMake(0, 10, self.bounds.size.width, self.bounds.size.height - kArrowHeight);
    //
    //    float xMin = CGRectGetMinX(frame);
    //    float yMin = CGRectGetMinY(frame);
    //
    //    float xMax = CGRectGetMaxX(frame);
    //    float yMax = CGRectGetMaxY(frame);
    //
    //    CGPoint arrowPoint = [self convertPoint:self.showPoint fromView:_handerView];
    //
    //    UIBezierPath *popoverPath = [UIBezierPath bezierPath];
    //    [popoverPath moveToPoint:CGPointMake(xMin, yMin)];//左上角
    //
    //    /********************向上的箭头**********************/
    //    [popoverPath addLineToPoint:CGPointMake(arrowPoint.x - kArrowHeight, yMin)];//  left side 左边点
    //
    //
    //    [popoverPath addCurveToPoint:arrowPoint
    //                   controlPoint1:CGPointMake(arrowPoint.x - kArrowHeight + kArrowCurvature, yMin)
    //                   controlPoint2:arrowPoint];//actual arrow point
    //
    //    [popoverPath addCurveToPoint:CGPointMake(arrowPoint.x + kArrowHeight, yMin)
    //                   controlPoint1:arrowPoint
    //                   controlPoint2:CGPointMake(arrowPoint.x + kArrowHeight - kArrowCurvature, yMin)];//right side
    //
    //    /********************向上的箭头**********************/
    //
    //
    //    [popoverPath addLineToPoint:CGPointMake(xMax, yMin)];//右上角
    //
    //    [popoverPath addLineToPoint:CGPointMake(xMax, yMax)];//右下角
    //
    //    [popoverPath addLineToPoint:CGPointMake(xMin, yMax)];//左下角
    //
    //    //填充颜色
    //    [RGB(245, 245, 245) setFill];
    //    [popoverPath fill];
    //
    //    [popoverPath closePath];
    //    [popoverPath stroke];
}


@end
