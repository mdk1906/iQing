//
//  QWMyLevelVC.m
//  Qingwen
//
//  Created by qingwen on 2018/10/15.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import "QWMyLevelVC.h"
#import "QWQWMyLevelTableViewCell.h"
#import "QWMyLevelVO.h"
@interface QWMyLevelVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) QWTableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic,strong) QWMyLevelVO *MyLevelVO;
@end

@implementation QWMyLevelVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    
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
    [self getData];
    [self configNavigationBar];
    
    
    
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

#define HEIGHT_LENGTH 36
- (void)configNavigationBar
{
    if (self.tableView.contentOffset.y > HEIGHT_LENGTH + 64) {
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:nil];
        self.navigationItem.leftBarButtonItem.tintColor = HRGB(0x505050);
        self.navigationItem.rightBarButtonItem.tintColor = HRGB(0x505050);
        self.title = @"我的等级";
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
    CGFloat viewHeight = UISCREEN_WIDTH*0.5706;
    UIView *tableHeadView = [UIView new];
    tableHeadView.backgroundColor = [UIColor whiteColor];
    tableHeadView.frame = CGRectMake(0, 0, UISCREEN_WIDTH, viewHeight + 10 +34);
    self.tableView.tableHeaderView = tableHeadView;
    
    
    UIView *headView = [UIView new];
    headView.backgroundColor = HRGB(0x394458);
    headView.frame = CGRectMake(0, 0, UISCREEN_WIDTH, viewHeight);
    [tableHeadView addSubview:headView];
    UILabel *navtitleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 33, UISCREEN_WIDTH, 24)];
    navtitleLab.textColor = HRGB(0xffffff);
    navtitleLab.font = [UIFont systemFontOfSize:16];
    navtitleLab.text = @"我的等级";
    navtitleLab.textAlignment = 1;
    [headView addSubview:navtitleLab];
    
    UIImageView *img = [UIImageView new];
    img.frame = CGRectMake((UISCREEN_WIDTH-UISCREEN_WIDTH*0.5706)/2, 0, viewHeight, viewHeight);
    img.image = [UIImage imageNamed:@"星星"];
    [headView addSubview:img];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, viewHeight*0.42, viewHeight, 25)];
    titleLab.textColor = HRGB(0x34363a);
    titleLab.font = [UIFont systemFontOfSize:25];
    titleLab.textAlignment = 1;
    titleLab.text = _MyLevelVO.user_level;
    [img addSubview:titleLab];
    
    UILabel *contentLab = [[UILabel alloc] initWithFrame:CGRectMake(0, viewHeight*0.74, UISCREEN_WIDTH, 17)];
    contentLab.textColor = HRGB(0xffffff);
    contentLab.font = [UIFont systemFontOfSize:12];
    contentLab.textAlignment = 1;
    int exp = [_MyLevelVO.level_exp intValue] - [_MyLevelVO.user_exp intValue] ;
    contentLab.text = [NSString stringWithFormat:@"我的经验：%@，距离升级还差%d",_MyLevelVO.user_exp,exp];
    
    [headView addSubview:contentLab];
    
    UILabel *nowLevelLab = [[UILabel alloc] initWithFrame:CGRectMake(11, kMaxY(contentLab.frame)+10, 30, 12)];
    nowLevelLab.textColor = HRGB(0xffffff);
    nowLevelLab.font = [UIFont systemFontOfSize:11];
    nowLevelLab.textAlignment = 0;
    nowLevelLab.text = _MyLevelVO.user_level;
    [headView addSubview:nowLevelLab];
    
    UILabel *nextLevelLab = [[UILabel alloc] initWithFrame:CGRectMake(UISCREEN_WIDTH-30-11, kMaxY(contentLab.frame)+10, 30, 12)];
    nextLevelLab.textColor = HRGB(0xffffff);
    nextLevelLab.font = [UIFont systemFontOfSize:11];
    nextLevelLab.textAlignment = 2;
    nextLevelLab.text = _MyLevelVO.user_next_level;
    [headView addSubview:nextLevelLab];
    
    UIImageView *bottomProgressImg = [UIImageView new];
    bottomProgressImg.frame = CGRectMake(kMaxX(nowLevelLab.frame)+15, kMaxY(contentLab.frame)+14, UISCREEN_WIDTH-(kMaxX(nowLevelLab.frame)+15)*2, 4);
    bottomProgressImg.image = [UIImage imageNamed:@"底框"];
    [headView addSubview:bottomProgressImg];
    
    float progress = [_MyLevelVO.user_exp doubleValue] / [_MyLevelVO.level_exp doubleValue];
    UIImageView *ProgressImg = [UIImageView new];
    ProgressImg.frame = CGRectMake(0, 0, (UISCREEN_WIDTH-(kMaxX(nowLevelLab.frame)+15)*2)*progress, 4);
    ProgressImg.image = [UIImage imageNamed:@"进度条"];
    [bottomProgressImg addSubview:ProgressImg];
    
    UIView *hui = [UIView new];
    hui.frame = CGRectMake(0, kMaxY(headView.frame), UISCREEN_WIDTH, 10);
    hui.backgroundColor = HRGB(0xE9E9E9);
    [tableHeadView addSubview:hui];
    
    UILabel *levelLab = [[UILabel alloc] initWithFrame:CGRectMake(12, kMaxY(hui.frame), UISCREEN_WIDTH , 34)];
    levelLab.textColor = HRGB(0x6f6f6f);
    levelLab.font = [UIFont systemFontOfSize:16];
    levelLab.textAlignment = 0;
    levelLab.text = @"等级权限";
    [tableHeadView addSubview:levelLab];
}

-(void)getData{
    self.dataArr = [NSMutableArray new];
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    [self showLoading];
    NSString *url = [NSString stringWithFormat:@"%@/levels/",[QWOperationParam currentDomain]];
//        NSString *url = @"http://apidoc.iqing.com/mock/19/levels/";
    QWOperationParam *pm = [QWInterface postWithUrl:url params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        [self hideLoading];
        if (aResponseObject != nil) {
            NSDictionary *data = aResponseObject;
            self.MyLevelVO = [QWMyLevelVO voWithDict:data];
            NSArray *arr = data[@"levels"];
            for (NSDictionary *dict in arr) {
                QWMyLevelVO *model = [QWMyLevelVO voWithDict:dict];
                [self.dataArr addObject:model];
            }
            [self createHeadView];
            [self.tableView reloadData];
            [self createFootView];
        }
    }];
    [self.operationManager requestWithParam:pm];
}
-(void)createFootView{
    UIView *footView = [UIView new];
    footView.backgroundColor = [UIColor whiteColor];
    
    
    UIView *hui = [UIView new];
    hui.frame = CGRectMake(0, 0, UISCREEN_WIDTH, 10);
    hui.backgroundColor = HRGB(0xE9E9E9);
    [footView addSubview:hui];
    
    UILabel *levelLab = [[UILabel alloc] initWithFrame:CGRectMake(12, kMaxY(hui.frame), UISCREEN_WIDTH , 34)];
    levelLab.textColor = HRGB(0x6f6f6f);
    levelLab.font = [UIFont systemFontOfSize:16];
    levelLab.textAlignment = 0;
    levelLab.text = @"等级说明";
    [footView addSubview:levelLab];
    NSString *contentStr = @"";
    
        contentStr = @"您可以通过完成每日任务或成就任务，获得经验值进行升级。\n等级提升后会获得专属等级勋章并开启更多功能权限。\n开通VIP可以获得经验值加成，加速等级提升。 ";
    
    
    NSMutableParagraphStyle  *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle  setLineSpacing:6];
    NSMutableAttributedString  *setString = [[NSMutableAttributedString alloc] initWithString:contentStr];
    [setString  addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [contentStr length])];
    
    UILabel *contentLab = [[UILabel alloc] initWithFrame:CGRectMake(12, kMaxY(levelLab.frame), UISCREEN_WIDTH-24 , 55)];
    contentLab.textColor = HRGB(0xaaaaaa);
    contentLab.numberOfLines = 0;
    contentLab.font = [UIFont systemFontOfSize:12];
    contentLab.textAlignment = 0;
    
    
    [contentLab  setAttributedText:setString];
    [footView addSubview:contentLab];
    
    footView.frame = CGRectMake(0, 0, UISCREEN_WIDTH, kMaxY(contentLab.frame)+13);
    self.tableView.tableFooterView = footView;
}
#pragma mark tableView数据源方法
//组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
//cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QWQWMyLevelTableViewCell *cell = [tableView
                                      dequeueReusableCellWithIdentifier:@"QWQWMyLevelTableViewCell"];
    if (cell == nil) {
        UINib *nibCell = [UINib nibWithNibName:NSStringFromClass([QWQWMyLevelTableViewCell class]) bundle:nil];
        [tableView registerNib:nibCell forCellReuseIdentifier:@"QWQWMyLevelTableViewCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"QWQWMyLevelTableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    QWMyLevelVO *model = self.dataArr[indexPath.row];
    cell.model = model;
    
    return cell;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self configNavigationBar];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
