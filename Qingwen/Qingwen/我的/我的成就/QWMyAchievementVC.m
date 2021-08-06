//
//  QWMyAchievementVC.m
//  Qingwen
//
//  Created by qingwen on 2018/9/7.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import "QWMyAchievementVC.h"
#import "QWMymedelVO.h"
#import "QWQWMymedelTableViewCell.h"
#import "MyMissionVO.h"
#import "QWMyMissionTableViewCell.h"
#import "QWAchievementBounced.h"
@interface QWMyAchievementVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) QWTableView *tableView;
@property (nonatomic,strong) NSMutableArray *user_medalsArr;
@property (nonatomic,strong) NSMutableArray *user_ungetArr;

@end

@implementation QWMyAchievementVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"了解更多" style:UIBarButtonItemStylePlain target:self action:@selector(rightClick)];
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    //    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self configNavigationBar];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)getData{
    self.user_medalsArr = [NSMutableArray new];
    self.user_ungetArr = [NSMutableArray new];
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"task_type"] = @"1";
    [self showLoading];
    NSString *url = [NSString stringWithFormat:@"%@/task/task_list/",[QWOperationParam currentDomain]];
    QWOperationParam *pm = [QWInterface postWithUrl:url params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (aResponseObject != nil) {
            NSDictionary *data = aResponseObject;
            NSDictionary *dict = data[@"data"];
            NSArray *arr = dict[@"undone"];
            for (int i = 0; i < arr.count; i++) {
                MyMissionVO *model = [MyMissionVO voWithDict:arr[i]];
                [self.user_medalsArr addObject:model];
            }
            NSArray *arr2 = dict[@"done"];
            for (int i = 0; i < arr2.count; i++) {
                MyMissionVO *model = [MyMissionVO voWithDict:arr2[i]];
                [self.user_ungetArr addObject:model];
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
        self.title = @"光辉成就";
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
    img.image = [UIImage imageNamed:@"元宵轻文娘-1"];
    [headView addSubview:img];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(14, UISCREEN_WIDTH*0.192+5, UISCREEN_WIDTH, 20)];
    titleLab.textColor = HRGB(0xffffff);
    titleLab.font = [UIFont systemFontOfSize:20];
    titleLab.text = @"Achievement";
    [img addSubview:titleLab];
    
    UILabel *missionLab = [[UILabel alloc] initWithFrame:CGRectMake(12, kMaxY(titleLab.frame) + 5, UISCREEN_WIDTH, 42)];
    missionLab.textColor = HRGB(0xffffff);
    missionLab.font = [UIFont systemFontOfSize:42];
    missionLab.text = @"光辉成就";
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
        titleLab.text = @"进行中";
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
        titleLab.text = @"已完成";
        [view addSubview:titleLab];
        
        return view;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 28;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 110;
    }
    else{
        return 110;
    }
    
}
//cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    QWMyMissionTableViewCell *cell = [tableView
                                      dequeueReusableCellWithIdentifier:@"QWMyMissionTableViewCell"];
    if (cell == nil) {
        UINib *nibCell = [UINib nibWithNibName:NSStringFromClass([QWMyMissionTableViewCell class]) bundle:nil];
        [tableView registerNib:nibCell forCellReuseIdentifier:@"QWMyMissionTableViewCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"QWMyMissionTableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        MyMissionVO *model = self.user_medalsArr[indexPath.row];
        cell.model = model;
    }
    else{
        MyMissionVO *model = self.user_ungetArr[indexPath.row];
        cell.model = model;
    }
    
    
    return cell;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self configNavigationBar];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    QWAchievementBounced *alert = [[QWAchievementBounced alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_WIDTH, UISCREEN_HEIGHT) dict:@{@"task_name":@"12314",@"task_conrats":@"12314",@"task_instruction":@"12314",}];
//    [self.view addSubview:alert];
}

-(void)rightClick{
    [[QWRouter sharedInstance] routerWithUrl:[NSURL URLWithString:@"https://www.iqing.com/info/#/achievement"]];
}
@end
