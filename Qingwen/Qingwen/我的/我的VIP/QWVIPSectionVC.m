//
//  QWVIPSectionVC.m
//  Qingwen
//
//  Created by qingwen on 2018/10/17.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import "QWVIPSectionVC.h"
#import "QWVIPSectionBtn.h"
#import "QWVIPSectionTableViewCell.h"
#import "QWVIPSectionVO.h"
#import "ListVO.h"
#import "BookVO.h"
#import "SDCycleScrollView.h"
#import "QWMyVIPVC.h"

@interface QWVIPSectionVC ()<UITableViewDelegate,UITableViewDataSource,SDCycleScrollViewDelegate>
{
    NSArray *titleArray;
    NSArray *viceTitleArray;
    NSMutableArray *buttonArray;
    NSMutableArray *viceButtonArray;
    NSMutableArray *topButtonArray;
    NSMutableArray *viceTopButtonArray;
    NSMutableArray *dataArr;
    UIView *titleView;
    NSString *state;
    NSString *order_by;
    UILabel *titleLab;
    UIView *headView;
    UIButton *topupBtn;
}
@property (nonatomic,strong) QWTableView *tableView;
@property (nonatomic, strong, nullable) ListVO *BookVO;
@property (nonatomic, strong, nullable) BestVO *bannerVO;
/**
 *  图片数组
 */
@property (nonatomic, strong) NSMutableArray *imageArray;

/**
 *  轮播图
 */
@property (nonatomic, strong) SDCycleScrollView *pageFlowView;


@end

@implementation QWVIPSectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"VIP专区";
    
    self.view.backgroundColor = HRGB(0xf9f9f9);
    self.tableView = [QWTableView new];
    if (ISIPHONEX) {
        self.tableView.frame = CGRectMake(0, 88, UISCREEN_WIDTH, UISCREEN_HEIGHT-88);
    }
    else{
        self.tableView.frame = CGRectMake(0, 64, UISCREEN_WIDTH, UISCREEN_HEIGHT-64);
    }
    self.tableView.backgroundColor = HRGB(0xf9f9f9);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    titleArray = @[@"原创专区",@"文库本"];
    viceTitleArray = @[@"更新",@"信仰",@"战力",@"收藏"];
    buttonArray = [NSMutableArray array];
    topButtonArray = [NSMutableArray array];
    viceTopButtonArray = [NSMutableArray array];
    viceButtonArray = [NSMutableArray array];
    // Do any additional setup after loading the view.
    state = @"10";
    order_by = @"updated_time";
    [self getDataWithLocate:state withorder_by:order_by];
    [self getbanner];
    [self createTitleView];
    WEAK_SELF;
    [self observeNotification:LOGIN_STATE_CHANGED withBlock:^(__weak id self, NSNotification *notification) {
        KVO_STRONG_SELF;
        [weakSelf frashLabs];
    }];
}
-(void)createTitleView{
    
    titleView = [UIView new];
    if (ISIPHONEX) {
        titleView.frame = CGRectMake(0, 88, UISCREEN_WIDTH, 40+42);
    }
    else{
        titleView.frame = CGRectMake(0, 64, UISCREEN_WIDTH, 40+42);
    }
    [self.view addSubview:titleView];
    titleView.backgroundColor = HRGB(0xF9F9F9);
    titleView.hidden = YES;
    for (int i = 0; i<titleArray.count; i++) {
        
        QWVIPSectionBtn *button  = [QWVIPSectionBtn buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(UISCREEN_WIDTH/2*i, 0, UISCREEN_WIDTH/2, 40);
        [button setTitle:titleArray[i] forState:UIControlStateNormal];
        button.layer.borderColor = HRGB(0xf9f9f9).CGColor;
        button.layer.borderWidth = 1;
        button.backgroundColor = HRGB(0xffffff);
        [button addTarget:self action:@selector(topbuttonView:) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:button];
        [button setTintColor:HRGB(0x766D6D)];
        button.tag = 100+i;
        if (i == 0) {
            [button setTintColor:HRGB(0xF98B8F)];
            [UIView animateWithDuration:0.3 animations:^{
                button.transform = CGAffineTransformMakeScale(1, 1);
            }];
            
        }else{
            [button setTintColor:HRGB(0x766D6D)];
        }
        [topButtonArray addObject:button];
        button.titleLabel.font = FONT(16);
    }
    
    UIView * bottomBtnView = [UIView new];
    bottomBtnView.frame = CGRectMake(0, 40, UISCREEN_WIDTH, 42);
    bottomBtnView.backgroundColor  = HRGB(0xf9f9f9);
    [titleView addSubview:bottomBtnView];
    
    for (int i = 0; i<viceTitleArray.count; i++) {
        QWVIPSectionBtn *button  = [QWVIPSectionBtn buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(10+60*i+10*i, 10, 60, 22);
        [button setTitle:viceTitleArray[i] forState:UIControlStateNormal];
        button.layer.cornerRadius = 10;
        button.layer.masksToBounds = YES;
        button.backgroundColor = HRGB(0xffffff);
        [button addTarget:self action:@selector(vicetopbuttonView:) forControlEvents:UIControlEventTouchUpInside];
        [bottomBtnView addSubview:button];
        [button setTintColor:HRGB(0x766D6D)];
        button.tag = 10000+i;
        if (i == 0) {
            [button setTintColor:HRGB(0xF98B8F)];
            [UIView animateWithDuration:0.3 animations:^{
                button.transform = CGAffineTransformMakeScale(1, 1);
            }];
            
        }else{
            [button setTintColor:HRGB(0x766D6D)];
        }
        [viceTopButtonArray addObject:button];
        button.titleLabel.font = FONT(12);
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self configNavigationBar];
}
#define HEIGHT_LENGTH 82
- (void)configNavigationBar
{
    if (self.tableView.contentOffset.y > 274) {
        self.tableView.tableHeaderView.hidden = YES;
        titleView.hidden = NO;
        
    }
    //    else if (self.tableView.contentOffset.y > HEIGHT_LENGTH) {
    //        NSLog(@"隐藏");
    //    }
    else {
        self.tableView.tableHeaderView.hidden = NO;
        titleView.hidden = YES;
        
    }
    
    
}
-(void)frashLabs{
    
    if ([[QWGlobalValue sharedInstance].user.vip_date isEqualToString:@""]) {
        
            titleLab.frame = CGRectMake(10, 10.7, [QWSize autoWidth:[NSString stringWithFormat:@"%@（您不是VIP用户，请充值成为VIP）",[QWGlobalValue sharedInstance].username] width:500 height:12 num:12], 12);
            titleLab.text = [NSString stringWithFormat:@"%@（您不是VIP用户，请充值成为VIP）",[QWGlobalValue sharedInstance].username];
            
            
            [topupBtn setTitle:@"充值" forState:0];
            topupBtn.frame = CGRectMake(kMaxX(titleLab.frame), 10.7, [QWSize autoWidth:@"充值" width:500 height:12 num:12]+10, 12);
            topupBtn.titleLabel.font = FONT(12);
            [topupBtn setTitleColor:[UIColor colorQWPink] forState:0];
        
        
        


    }
    else{
        
            titleLab.text = [NSString stringWithFormat:@"%@（您是VIP用户，可免费阅读专区作品）",[QWGlobalValue sharedInstance].username];
            titleLab.frame = CGRectMake(10, 10.7, [QWSize autoWidth:[NSString stringWithFormat:@"%@（您是VIP用户，可免费阅读专区作品）",[QWGlobalValue sharedInstance].username] width:500 height:12 num:12], 12);
            
            [topupBtn setTitle:@"续费" forState:0];
            topupBtn.frame = CGRectMake(kMaxX(titleLab.frame), 10.7, 50, 12);
            topupBtn.titleLabel.font = FONT(12);
            [topupBtn setTitleColor:[UIColor colorQWPink] forState:0];
        
        
        
    }
    
}
-(void)createHeadView{
    headView = [UIView new];
    
    
    headView.backgroundColor = [UIColor whiteColor];
    
    titleLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 10.7, UISCREEN_WIDTH, 12)];
    titleLab.textColor = HRGB(0x766D6D);
    titleLab.font = [UIFont systemFontOfSize:12];
    
    
    
    
    topupBtn = [UIButton new];
    [topupBtn addTarget:self action:@selector(topupBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    if ([QWGlobalValue sharedInstance].isLogin == NO) {
        
        
            titleLab.text = @"请登录后开通VIP免费阅读专区作品";
            
            titleLab.frame = CGRectMake(10, 10.7, [QWSize autoWidth:@"请登录后开通VIP免费阅读专区作品" width:500 height:12 num:12], 12);
            
            [topupBtn setTitle:@"登录" forState:0];
            topupBtn.frame = CGRectMake(kMaxX(titleLab.frame), 10.7, [QWSize autoWidth:@"登录" width:500 height:12 num:12]+10, 12);
            topupBtn.titleLabel.font = FONT(12);
            [topupBtn setTitleColor:[UIColor colorQWPink] forState:0];
            
            [headView addSubview:topupBtn];
        
        
    }else{
        
        if ([[QWGlobalValue sharedInstance].user.vip_date isEqualToString:@""]) {
            
                titleLab.frame = CGRectMake(10, 10.7, [QWSize autoWidth:[NSString stringWithFormat:@"%@（您不是VIP用户，请充值成为VIP）",[QWGlobalValue sharedInstance].username] width:500 height:12 num:12], 12);
                titleLab.text = [NSString stringWithFormat:@"%@（您不是VIP用户，请充值成为VIP）",[QWGlobalValue sharedInstance].username];
                
                
                [topupBtn setTitle:@"充值" forState:0];
                topupBtn.frame = CGRectMake(kMaxX(titleLab.frame), 10.7, [QWSize autoWidth:@"充值" width:500 height:12 num:12]+10, 12);
                topupBtn.titleLabel.font = FONT(12);
                [topupBtn setTitleColor:[UIColor colorQWPink] forState:0];
                
                [headView addSubview:topupBtn];
            
            
            
        }
        else{
            
                titleLab.text = [NSString stringWithFormat:@"%@（您是VIP用户，可免费阅读专区作品）",[QWGlobalValue sharedInstance].username];
                titleLab.frame = CGRectMake(10, 10.7, [QWSize autoWidth:[NSString stringWithFormat:@"%@（您是VIP用户，可免费阅读专区作品）",[QWGlobalValue sharedInstance].username] width:500 height:12 num:12], 12);
                
                [topupBtn setTitle:@"续费" forState:0];
                topupBtn.frame = CGRectMake(kMaxX(titleLab.frame), 10.7, [QWSize autoWidth:@"续费" width:500 height:12 num:12]+10, 12);
                topupBtn.titleLabel.font = FONT(12);
                [topupBtn setTitleColor:[UIColor colorQWPink] forState:0];
                
                [headView addSubview:topupBtn];
            
            
        }
    }
    [headView addSubview:titleLab];
    
    UIView *bannerView = [UIView new];
    bannerView.frame = CGRectMake(10, kMaxY(titleLab.frame)+10, UISCREEN_WIDTH-20, (UISCREEN_WIDTH-20)/2);
    bannerView.backgroundColor = [UIColor clearColor];
    [headView addSubview:bannerView];
    
    //轮播
    
    _pageFlowView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, UISCREEN_WIDTH-20, (UISCREEN_WIDTH-20)/2) delegate:self placeholderImage:[UIImage imageNamed:@"placeholder"]];
    _pageFlowView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    _pageFlowView.currentPageDotColor = HRGB(0xF98B8F); // 自定义分页控件小圆标颜色
    
    //         --- 模拟加载延迟
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_pageFlowView.imageURLStringsGroup = self->_imageArray;
    });
    
    [bannerView addSubview:_pageFlowView];
    

    
    UIView *vibut = [[UIView alloc] initWithFrame:CGRectMake(0, kMaxY(bannerView.frame)+11, UISCREEN_WIDTH, 40)];
    [headView addSubview:vibut];
    vibut.backgroundColor = HRGB(0xffffff);
    
    for (int i = 0; i<titleArray.count; i++) {
        QWVIPSectionBtn *button  = [QWVIPSectionBtn buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(UISCREEN_WIDTH/2*i, 0, UISCREEN_WIDTH/2, 40);
        [button setTitle:titleArray[i] forState:UIControlStateNormal];
        button.layer.borderColor = HRGB(0xf9f9f9).CGColor;
        button.layer.borderWidth = 1;
        button.backgroundColor = HRGB(0xffffff);
        [button addTarget:self action:@selector(buttonView:) forControlEvents:UIControlEventTouchUpInside];
        [vibut addSubview:button];
        [button setTintColor:HRGB(0x766D6D)];
        button.tag = 10+i;
        if (i == 0) {
            [button setTintColor:HRGB(0xF98B8F)];
            [UIView animateWithDuration:0.3 animations:^{
                button.transform = CGAffineTransformMakeScale(1, 1);
            }];
            
        }else{
            [button setTintColor:HRGB(0x766D6D)];
        }
        [buttonArray addObject:button];
        button.titleLabel.font = FONT(14);
    }
    
    UIView * bottomBtnView = [UIView new];
    bottomBtnView.frame = CGRectMake(0, kMaxY(vibut.frame), UISCREEN_WIDTH, 42);
    bottomBtnView.backgroundColor  = HRGB(0xf9f9f9);
    [headView addSubview:bottomBtnView];
    
    for (int i = 0; i<viceTitleArray.count; i++) {
        QWVIPSectionBtn *button  = [QWVIPSectionBtn buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(10+60*i+10*i, 10, 60, 22);
        [button setTitle:viceTitleArray[i] forState:UIControlStateNormal];
        button.layer.cornerRadius = 10;
        button.layer.masksToBounds = YES;
        button.backgroundColor = HRGB(0xffffff);
        [button addTarget:self action:@selector(vicebuttonView:) forControlEvents:UIControlEventTouchUpInside];
        [bottomBtnView addSubview:button];
        [button setTintColor:HRGB(0x766D6D)];
        button.tag = 1000+i;
        if (i == 0) {
            [button setTintColor:HRGB(0xF98B8F)];
            [UIView animateWithDuration:0.3 animations:^{
                button.transform = CGAffineTransformMakeScale(1, 1);
            }];
            
        }else{
            [button setTintColor:HRGB(0x766D6D)];
        }
        [viceButtonArray addObject:button];
        button.titleLabel.font = FONT(12);
    }
    headView.frame = CGRectMake(0, 0, UISCREEN_WIDTH, kMaxY(bottomBtnView.frame));
    self.tableView.tableHeaderView = headView;
}
-(void)topbuttonView:(QWVIPSectionBtn *)but
{
    [UIView animateWithDuration:0.3 animations:^{
        but.transform = CGAffineTransformMakeScale(1, 1);
    }];
    [but setTintColor:HRGB(0xF98B8F)];
    for (int i = 0; i< topButtonArray.count; i++) {
        if (i!=but.tag-100) {
            
            [UIView animateWithDuration:0.3 animations:^{
                ((QWVIPSectionBtn *)self->topButtonArray[i]).transform = CGAffineTransformMakeScale(1, 1);
            }];
            [((QWVIPSectionBtn *)topButtonArray[i]) setTintColor:HRGB(0x766D6D)];
        }
    }
    for (int i = 0; i< buttonArray.count; i++) {
        if (i!=but.tag-100) {
            
            [UIView animateWithDuration:0.3 animations:^{
                ((QWVIPSectionBtn *)self->buttonArray[i]).transform = CGAffineTransformMakeScale(1, 1);
            }];
            [((QWVIPSectionBtn *)buttonArray[i]) setTintColor:HRGB(0x766D6D)];
        }
        else{
            [((QWVIPSectionBtn *)buttonArray[i]) setTintColor:HRGB(0xF98B8F)];
        }
    }
    if (but.tag == 100) {
        state = @"10";
        //更新 updated_time、信仰 belief、战力 combat、收藏follow_count
        [self getDataWithLocate:state withorder_by:order_by];
    }else{
        state = @"14";
        [self getDataWithLocate:state withorder_by:order_by];
    }
    
}
-(void)buttonView:(QWVIPSectionBtn *)but
{
    [UIView animateWithDuration:0.3 animations:^{
        but.transform = CGAffineTransformMakeScale(1, 1);
    }];
    [but setTintColor:HRGB(0xF98B8F)];
    for (int i = 0; i< buttonArray.count; i++) {
        if (i!=but.tag-10) {
            
            [UIView animateWithDuration:0.3 animations:^{
                ((QWVIPSectionBtn *)self->buttonArray[i]).transform = CGAffineTransformMakeScale(1, 1);
            }];
            [((QWVIPSectionBtn *)buttonArray[i]) setTintColor:HRGB(0x766D6D)];
        }
    }
    for (int i = 0; i< topButtonArray.count; i++) {
        if (i!=but.tag-10) {
            
            [UIView animateWithDuration:0.3 animations:^{
                ((QWVIPSectionBtn *)self->topButtonArray[i]).transform = CGAffineTransformMakeScale(1, 1);
            }];
            [((QWVIPSectionBtn *)topButtonArray[i]) setTintColor:HRGB(0x766D6D)];
        }
        else{
            [((QWVIPSectionBtn *)topButtonArray[i]) setTintColor:HRGB(0xF98B8F)];
        }
    }
    if (but.tag == 10) {
        state = @"10";
        [self getDataWithLocate:state withorder_by:order_by];
    }else{
        state = @"14";
        [self getDataWithLocate:state withorder_by:order_by];
    }
    
}
-(void)vicebuttonView:(QWVIPSectionBtn *)but{
    [UIView animateWithDuration:0.3 animations:^{
        but.transform = CGAffineTransformMakeScale(1, 1);
    }];
    [but setTintColor:HRGB(0xF98B8F)];
    for (int i = 0; i< viceButtonArray.count; i++) {
        if (i!=but.tag-1000) {
            
            [UIView animateWithDuration:0.3 animations:^{
                ((QWVIPSectionBtn *)self->viceButtonArray[i]).transform = CGAffineTransformMakeScale(1, 1);
            }];
            [((QWVIPSectionBtn *)viceButtonArray[i]) setTintColor:HRGB(0x766D6D)];
        }
    }
    for (int i = 0; i< viceTopButtonArray.count; i++) {
        if (i!=but.tag-1000) {
            
            [UIView animateWithDuration:0.3 animations:^{
                ((QWVIPSectionBtn *)self->viceTopButtonArray[i]).transform = CGAffineTransformMakeScale(1, 1);
            }];
            [((QWVIPSectionBtn *)viceTopButtonArray[i]) setTintColor:HRGB(0x766D6D)];
        }
        else{
            [((QWVIPSectionBtn *)viceTopButtonArray[i]) setTintColor:HRGB(0xF98B8F)];
        }
    }
    if (but.tag == 1000) {
        order_by = @"updated_time";
        [self getDataWithLocate:state withorder_by:order_by];
    }else if (but.tag == 1001){
        order_by = @"belief";
        [self getDataWithLocate:state withorder_by:order_by];
    }
    else if (but.tag == 1002){
        order_by = @"combat";
        [self getDataWithLocate:state withorder_by:order_by];
    }
    else if (but.tag == 1003){
        order_by = @"follow_count";
        [self getDataWithLocate:state withorder_by:order_by];
    }
}
-(void)vicetopbuttonView:(QWVIPSectionBtn *)but{
    [UIView animateWithDuration:0.3 animations:^{
        but.transform = CGAffineTransformMakeScale(1, 1);
    }];
    [but setTintColor:HRGB(0xF98B8F)];
    for (int i = 0; i< viceTopButtonArray.count; i++) {
        if (i!=but.tag-10000) {
            
            [UIView animateWithDuration:0.3 animations:^{
                ((QWVIPSectionBtn *)self->viceTopButtonArray[i]).transform = CGAffineTransformMakeScale(1, 1);
            }];
            [((QWVIPSectionBtn *)viceTopButtonArray[i]) setTintColor:HRGB(0x766D6D)];
        }
    }
    for (int i = 0; i< viceButtonArray.count; i++) {
        if (i!=but.tag-10000) {
            
            [UIView animateWithDuration:0.3 animations:^{
                ((QWVIPSectionBtn *)self->viceButtonArray[i]).transform = CGAffineTransformMakeScale(1, 1);
            }];
            [((QWVIPSectionBtn *)viceButtonArray[i]) setTintColor:HRGB(0x766D6D)];
        }
        else{
            [((QWVIPSectionBtn *)viceButtonArray[i]) setTintColor:HRGB(0xF98B8F)];
        }
    }
    if (but.tag == 10000) {
        order_by = @"updated_time";
        [self getDataWithLocate:state withorder_by:order_by];
    }else if (but.tag == 10001){
        order_by = @"belief";
        [self getDataWithLocate:state withorder_by:order_by];
    }
    else if (but.tag == 10002){
        order_by = @"combat";
        [self getDataWithLocate:state withorder_by:order_by];
    }
    else if (but.tag == 10003){
        order_by = @"follow_count";
        [self getDataWithLocate:state withorder_by:order_by];
    }
}
-(void)topupBtnClick:(UIButton *)btn{
    if ([btn.titleLabel.text isEqualToString:@"充值"] || [btn.titleLabel.text isEqualToString:@"续费"] ) {
        
            QWMyVIPVC *vc = [[QWMyVIPVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        
        
    }
    else{
        [[QWRouter sharedInstance] routerToLogin];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.BookVO.results.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}
//cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QWVIPSectionTableViewCell *cell = [tableView
                                       dequeueReusableCellWithIdentifier:@"QWVIPSectionTableViewCell"];
    if (cell == nil) {
        UINib *nibCell = [UINib nibWithNibName:NSStringFromClass([QWVIPSectionTableViewCell class]) bundle:nil];
        [tableView registerNib:nibCell forCellReuseIdentifier:@"QWVIPSectionTableViewCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"QWVIPSectionTableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    cell.contentView.backgroundColor = HRGB(0xf9f9f9);
    BookVO *model = _BookVO.results[indexPath.row];
    cell.model = model;
    
    return cell;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
        [self configNavigationBar];
    
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BookVO *model = _BookVO.results[indexPath.row];
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"id"] = [model.nid stringValue];
    params[@"book_url"] = model.url;
    [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"book" andParams:params]];
    
}
-(void)getDataWithLocate:(NSString *)locate withorder_by:(NSString*)order_by{
    self.BookVO = [ListVO new];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [self showLoading];
    NSString *url = [NSString stringWithFormat:@"%@/vipbook/?locate=%@&order_by=%@",[QWOperationParam currentDomain],locate,order_by];
    //        NSString *url = @"http://apidoc.iqing.com/mock/19/levels/";
    QWOperationParam *pm = [QWInterface getWithUrl:url params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        [self hideLoading];
        if (aResponseObject && !anError) {
            ListVO *vo = [ListVO voWithDict:aResponseObject];
            if (self.BookVO.results.count) {
                [self.BookVO addResultsWithNewPage:vo];
            }
            else {
                self.BookVO = vo;
            }
            [self.tableView reloadData];
            
        }
        else {
            
        }
    }];
    [self.operationManager requestWithParam:pm];
    
}
-(void)getbanner{
    self.imageArray = [NSMutableArray new];
    self.bannerVO = [BestVO new];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [self showLoading];
    NSString *url = [NSString stringWithFormat:@"%@/recommend/?type=13&channel=1",[QWOperationParam currentDomain]];
    QWOperationParam *pm = [QWInterface getWithUrl:url params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        [self hideLoading];
        if (aResponseObject && !anError) {
            BestVO *vo = [BestVO voWithDict:aResponseObject];
            if (self.bannerVO.results.count) {
                [self.bannerVO addResultsWithNewPage:vo];
            }
            else {
                self.bannerVO = vo;
            }
            
            for (BestItemVO *book in self.bannerVO.results) {
                
                [self->_imageArray addObject:book.cover];
            }
            [self createHeadView];
        }
        else {
            
        }
    }];
    [self.operationManager requestWithParam:pm];
    
}
#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"---点击了第%ld张图片", (long)index);
    BestItemVO *model = self.bannerVO.results[index];
    
    if (model.href != nil) {
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:model.href]];
    }
    else{
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[@"id"] = [model.nid stringValue];
        params[@"book_url"] = model.url;
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"book" andParams:params]];
    }
    

}

#pragma mark --懒加载
- (NSMutableArray *)imageArray
{
    if (_imageArray == nil) {
        _imageArray = [NSMutableArray array];
    }
    return _imageArray;
}

@end
