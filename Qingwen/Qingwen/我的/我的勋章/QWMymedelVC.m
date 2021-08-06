//
//  QWMymedelVC.m
//  Qingwen
//
//  Created by qingwen on 2018/9/6.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import "QWMymedelVC.h"
#import "MyMissionVO.h"
#import "QWQWMymedelTableViewCell.h"
#import "QWMymedelVO.h"
@interface QWMymedelVC ()<UITableViewDelegate,UITableViewDataSource>
{
    UIView *backView;
    UIView *beforeView;
}
@property (nonatomic,strong) QWTableView *tableView;
@property (nonatomic,strong) NSMutableArray *user_medalsArr;
@property (nonatomic,strong) NSMutableArray *user_ungetArr;
@property (nonatomic ,strong) NSString *wearMadelId;
@end

@implementation QWMymedelVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"了解更多" style:UIBarButtonItemStylePlain target:self action:@selector(rightClick)];
    _wearMadelId = @"";
    self.navigationItem.rightBarButtonItem.tintColor = HRGB(0xffffff);
    self.tableView = [QWTableView new];
    if (ISIPHONEX) {
        self.tableView.frame = CGRectMake(0, -88, UISCREEN_WIDTH, UISCREEN_HEIGHT+88);
    }
    else{
        self.tableView.frame = CGRectMake(0, -64, UISCREEN_WIDTH, UISCREEN_HEIGHT+64);
    }
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [self createHeadView];
    [self getData];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(createMedelView:) name:@"imgBtnClick" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    //    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self configNavigationBar];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}
- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)getData{
    self.user_medalsArr = [NSMutableArray new];
    self.user_ungetArr = [NSMutableArray new];
    _wearMadelId = @"";
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    [self showLoading];
        NSString *url = [NSString stringWithFormat:@"%@/medal/",[QWOperationParam currentDomain]];
//    NSString *url = @"http://apidoc.iqing.com/mock/19/task/medal/";
    QWOperationParam *pm = [QWInterface postWithUrl:url params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (aResponseObject != nil) {
            NSDictionary *data = aResponseObject;
            self->_wearMadelId = [NSString stringWithFormat:@"%@",data[@"user_adorn_medal"]];
            //已获得勋章数据整理
            NSArray *arr = data[@"user_medals"];
            NSMutableArray *arrayM = [[NSMutableArray alloc] init];
            NSMutableArray *arrayMItem = [[NSMutableArray alloc] init];
            for (int i = 0; i < arr.count; i++) {
                NSDictionary *dict = arr[i];
                [arrayMItem addObject:dict];
                if (i%3 == 2 && i != 0) {
                    NSMutableArray *arrayItemItem = [[NSMutableArray alloc] init];
                    for (int j =0; j < arrayMItem.count; j++) {
                        [arrayItemItem addObject:arrayMItem[j]];
                    }
                    [arrayM addObject:arrayItemItem];
                    
                    [arrayMItem removeAllObjects];
                }
            }
            [arrayM addObject:arrayMItem];
            for (int i = 0; i<arrayM.count; i++) {
                NSArray *dataArr = arrayM[i];
                if (dataArr.count == 0) {
                    
                }
                else{
                    NSDictionary *dic = @{@"dataArr":arrayM[i]};
                    QWMymedelVO *model = [QWMymedelVO voWithDict:dic];
                    [self.user_medalsArr addObject:model];
                }
                
            }
            //未获得勋章数据整理
            NSArray *arr2 = data[@"user_unget"];
            NSMutableArray *arrayM2 = [[NSMutableArray alloc] init];
            NSMutableArray *arrayMItem2 = [[NSMutableArray alloc] init];
            for (int i = 0; i < arr2.count; i++) {
                NSDictionary *dict = arr2[i];
                [arrayMItem2 addObject:dict];
                if (i%3 == 2 && i != 0) {
                    NSMutableArray *arrayItemItem2 = [[NSMutableArray alloc] init];
                    for (int j =0; j < arrayMItem2.count; j++) {
                        [arrayItemItem2 addObject:arrayMItem2[j]];
                    }
                    [arrayM2 addObject:arrayItemItem2];

                    [arrayMItem2 removeAllObjects];
                }
            }
            [arrayM2 addObject:arrayMItem2];
            
            for (int i = 0; i<arrayM2.count; i++) {
                NSArray *dataArr = arrayM2[i];
                if (dataArr.count == 0) {
                    
                }
                else{
                NSDictionary *dic = @{@"dataArr":arrayM2[i]};
                QWMymedelVO *model = [QWMymedelVO voWithDict:dic];
                [self.user_ungetArr addObject:model];
                }
            }
            [self.tableView reloadData];
            [self hideLoading];
        }
        else{
            [self hideLoading];
        }
    }];
    [self.operationManager requestWithParam:pm];
    
}
#define HEIGHT_LENGTH 36
- (void)configNavigationBar
{
    if (self.tableView.contentOffset.y > HEIGHT_LENGTH + 64) {
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:nil];
        self.navigationItem.leftBarButtonItem.tintColor = HRGB(0x505050);
        self.navigationItem.rightBarButtonItem.tintColor = HRGB(0x505050);
        self.title = @"我的勋章";
        [self setNeedsStatusBarAppearanceUpdate];
    }
    else if (self.tableView.contentOffset.y > HEIGHT_LENGTH) {
        CGFloat alpha = (self.tableView.contentOffset.y - HEIGHT_LENGTH) / 64;
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[HRGB(0xF8F8F8) colorWithAlphaComponent:alpha]] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[UIImage imageWithColor:[HRGB(0xF8F8F8) colorWithAlphaComponent:alpha]]];
        self.navigationItem.leftBarButtonItem.tintColor = HRGB(0x505050);
        self.navigationItem.rightBarButtonItem.tintColor = HRGB(0x505050);
        self.title = nil;
    }
    else {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
        self.navigationItem.leftBarButtonItem.tintColor = HRGB(0xF8F8F8);
        self.navigationItem.rightBarButtonItem.tintColor = HRGB(0xF8F8F8);
        self.title = nil;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    
}
-(void)createHeadView{
    UIView *headView = [UIView new];
    headView.backgroundColor = [UIColor clearColor];
    headView.frame = CGRectMake(0, 0, UISCREEN_WIDTH, UISCREEN_WIDTH*0.4106);
    self.tableView.tableHeaderView = headView;
    
    UIImageView *img = [UIImageView new];
    img.frame = CGRectMake(0, 0, UISCREEN_WIDTH, UISCREEN_WIDTH*0.4106);
    img.image = [UIImage imageNamed:@"元宵轻文娘"];
    [headView addSubview:img];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(14, UISCREEN_WIDTH*0.192+5, UISCREEN_WIDTH, 20)];
    titleLab.textColor = HRGB(0xffffff);
    titleLab.font = [UIFont systemFontOfSize:20];
    titleLab.text = @"My Medal";
    [img addSubview:titleLab];
    
    UILabel *missionLab = [[UILabel alloc] initWithFrame:CGRectMake(12, kMaxY(titleLab.frame) + 5, UISCREEN_WIDTH, 42)];
    missionLab.textColor = HRGB(0xffffff);
    missionLab.font = [UIFont systemFontOfSize:42];
    missionLab.text = @"我的勋章";
    [img addSubview:missionLab];
    
}
#pragma mark tableView数据源方法
//组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.user_medalsArr.count;
    }
    else{
        return self.user_ungetArr.count;
    }
    
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView *view = [UIView new];
        view.backgroundColor = HRGB(0xf9f9f9);
        view.frame = CGRectMake(0, 0, UISCREEN_WIDTH, 28);
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, UISCREEN_WIDTH, 28)];
        titleLab.textColor = HRGB(0x7c7c7c);
        titleLab.font = [UIFont systemFontOfSize:16];
        titleLab.text = @"已获得";
        [view addSubview:titleLab];
        
        return view;
    }
    else{
        UIView *view = [UIView new];
        view.backgroundColor = HRGB(0xf9f9f9);
        view.frame = CGRectMake(0, 0, UISCREEN_WIDTH, 28);
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, UISCREEN_WIDTH, 28)];
        titleLab.textColor = HRGB(0x7c7c7c);
        titleLab.font = [UIFont systemFontOfSize:16];
        titleLab.text = @"未获得";
        [view addSubview:titleLab];
        
        return view;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 28;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 75;
    }
    else{
       return 75;
    }
    
}
//cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    QWQWMymedelTableViewCell *cell = [tableView
                                      dequeueReusableCellWithIdentifier:@"QWQWMymedelTableViewCell"];
    if (cell == nil) {
        UINib *nibCell = [UINib nibWithNibName:NSStringFromClass([QWQWMymedelTableViewCell class]) bundle:nil];
        [tableView registerNib:nibCell forCellReuseIdentifier:@"QWQWMymedelTableViewCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"QWQWMymedelTableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        QWMymedelVO *model = self.user_medalsArr[indexPath.row];
        model.obtain = [NSNumber numberWithInt:1];
        model.waerMedalId = self.wearMadelId;
        model.avatar = self.avater;
        cell.model = model;
    }
    else{
        QWMymedelVO *model = self.user_ungetArr[indexPath.row];
        model.obtain = [NSNumber numberWithInt:2];
        model.waerMedalId = self.wearMadelId;
        model.avatar = self.avater;
        cell.model = model;
    }
    
    
    return cell;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self configNavigationBar];
}

#pragma mark - medel显示
-(void)createMedelView:(NSNotification *)noc{
    NSLog(@"dict = %@",noc.object);
    NSDictionary *dict = noc.object;
    backView = [UIView new];
    backView.backgroundColor = HRGB(0x000000);
    backView.alpha = 0.8;
    backView.frame = CGRectMake(0, 0, UISCREEN_WIDTH, UISCREEN_HEIGHT);
    [self.view addSubview:backView];
    
    beforeView = [UIView new];
    beforeView.frame = CGRectMake(0, 0, UISCREEN_WIDTH, UISCREEN_HEIGHT);
    [self.view addSubview:beforeView];
    
    UIImageView *headImg = [UIImageView new];
    headImg.frame = CGRectMake((UISCREEN_WIDTH-120)/2, UISCREEN_HEIGHT*0.25, 120, 120);
    headImg.userInteractionEnabled = YES;
    headImg.layer.cornerRadius = 60;
    headImg.layer.masksToBounds = YES;
    [headImg qw_setImageUrlString:[QWConvertImageString convertPicURL:[QWGlobalValue sharedInstance].user.avatar imageSizeType:QWImageSizeTypeCover] placeholder:[UIImage imageNamed:@"mycenter_logo2"] animation:YES];
    [beforeView addSubview:headImg];
    
    UIImageView *medalImg = [UIImageView new];
    medalImg.frame = CGRectMake(kMaxX(headImg.frame)-120, UISCREEN_HEIGHT*0.25+120-120*0.308, 120, 120*0.308);
//    medalImg.backgroundColor = [UIColor redColor];
    [medalImg qw_setImageUrlString:dict[@"medal_icon"] placeholder:[UIImage imageNamed:@"mycenter_logo2"] animation:nil];
    [beforeView addSubview:medalImg];
    
    UILabel *medal_nameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, kMaxY(headImg.frame)+10, UISCREEN_WIDTH, 18)];
    medal_nameLab.textColor = HRGB(0xffffff);
    medal_nameLab.font = [UIFont systemFontOfSize:18];
    medal_nameLab.text = dict[@"medal_name"];
    medal_nameLab.textAlignment = 1;
    [beforeView addSubview:medal_nameLab];
    
    UILabel *medal_instructionLab = [[UILabel alloc] initWithFrame:CGRectMake(0, kMaxY(medal_nameLab.frame)+20, UISCREEN_WIDTH, 16)];
    medal_instructionLab.textColor = HRGB(0xffffff);
    medal_instructionLab.font = [UIFont systemFontOfSize:16];
    medal_instructionLab.text = dict[@"medal_instruction"];
    medal_instructionLab.textAlignment = 1;
    [beforeView addSubview:medal_instructionLab];
    
    UILabel *updated_timeLab = [[UILabel alloc] initWithFrame:CGRectMake(0, kMaxY(medal_instructionLab.frame)+20, UISCREEN_WIDTH, 14)];
    updated_timeLab.textColor = HRGB(0xffffff);
    updated_timeLab.font = [UIFont systemFontOfSize:14];
    updated_timeLab.text = dict[@"updated_time"];
    updated_timeLab.textAlignment = 1;
    [beforeView addSubview:updated_timeLab];
    
    UILabel *medal_remarkLab = [[UILabel alloc] initWithFrame:CGRectMake(0, kMaxY(updated_timeLab.frame)+20, UISCREEN_WIDTH, 35)];
    medal_remarkLab.textColor = HRGB(0xffffff);
    medal_remarkLab.font = [UIFont systemFontOfSize:12];
    medal_remarkLab.text = dict[@"medal_remark"];
    medal_remarkLab.textAlignment = 1;
    medal_remarkLab.numberOfLines = 0;
    [beforeView addSubview:medal_remarkLab];
    
    UIButton *wearBtn = [UIButton new];
    wearBtn.frame = CGRectMake((UISCREEN_WIDTH-140)/2, kMaxY(medal_remarkLab.frame)+20, 140, 46);
    
    wearBtn.layer.masksToBounds = YES;
    wearBtn.layer.cornerRadius = 5;
    wearBtn.tag = [dict[@"medal_id"] intValue];
    if ([[NSString stringWithFormat:@"%ld",(long)wearBtn.tag] isEqualToString:_wearMadelId]) {
        [wearBtn addTarget:self action:@selector(RemoveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [wearBtn setTintColor:HRGB(0xffffff)];
        wearBtn.backgroundColor = HRGB(0xa4a4a4);
        [wearBtn setTitle:@"卸下勋章" forState:0];
        [beforeView addSubview:wearBtn];
    }
    else{
        [wearBtn addTarget:self action:@selector(wearBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [wearBtn setTintColor:HRGB(0xffffff)];
        wearBtn.backgroundColor = HRGB(0xFA8E9B);
        [wearBtn setTitle:@"佩戴勋章" forState:0];
        [beforeView addSubview:wearBtn];
    }
    
    UIView *bottomView = [UIView new];
    bottomView.frame = CGRectMake(0, UISCREEN_HEIGHT-50, UISCREEN_WIDTH, 50);
    bottomView.backgroundColor = HRGB(0x000000);
    [beforeView addSubview:bottomView];
    
    UIImageView *cancelImg = [UIImageView new];
    cancelImg.image = [UIImage imageNamed:@"叉叉"];
    cancelImg.frame = CGRectMake((UISCREEN_WIDTH-20)/2, 15, 20, 20);
    [bottomView addSubview:cancelImg];
    
    UIButton *cancelBtn = [UIButton new];
    cancelBtn.frame = CGRectMake(0, 0, UISCREEN_WIDTH, 50);
    [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:cancelBtn];
    
}
-(void)cancelBtnClick{
    [backView removeFromSuperview];
    [beforeView removeFromSuperview];
}
-(void)wearBtnClick:(UIButton *)btn{
    NSLog(@"medal_id = %ld",(long)btn.tag);
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"method"] = @"ADORN";
    params[@"medal"] = [NSString stringWithFormat:@"%ld",(long)btn.tag];
    NSString *url = [NSString stringWithFormat:@"%@/medal/adorn/",[QWOperationParam currentDomain]];
    QWOperationParam *pm = [QWInterface postWithUrl:url params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        NSDictionary *dict = aResponseObject;
        if ([dict[@"code"] intValue] == 0) {
            [self showToastWithTitle:dict[@"msg"] subtitle:nil type:ToastTypeError];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [self showToastWithTitle:dict[@"msg"] subtitle:nil type:ToastTypeError];
            [self cancelBtnClick];
        }
    }];
    pm.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:pm];
}
-(void)RemoveBtnClick:(UIButton *)btn{
    NSLog(@"medal_id = %ld",(long)btn.tag);
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"method"] = @"UNADORN";
    params[@"medal"] = [NSString stringWithFormat:@"%ld",(long)btn.tag];
    NSString *url = [NSString stringWithFormat:@"%@/medal/adorn/",[QWOperationParam currentDomain]];
    QWOperationParam *pm = [QWInterface postWithUrl:url params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        NSDictionary *dict = aResponseObject;
        if ([dict[@"code"] intValue] == 0) {
            [self showToastWithTitle:dict[@"msg"] subtitle:nil type:ToastTypeError];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [self showToastWithTitle:dict[@"msg"] subtitle:nil type:ToastTypeError];
            [self cancelBtnClick];
        }
    }];
    pm.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:pm];
}
-(void)rightClick{
    [[QWRouter sharedInstance] routerWithUrl:[NSURL URLWithString:@"https://www.iqing.com/info/#/medal"]];
}
@end
