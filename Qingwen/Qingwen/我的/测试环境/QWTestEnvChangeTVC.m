//
//  QWTestEnvChangeTVC.m
//  Qingwen
//
//  Created by Aimy on 7/3/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWTestEnvChangeTVC.h"

#import "QWOperationParam.h"
#import "QWUserDefaultsDefine.h"


static const NSString * APITestHost = @"https://api-gate.iqing.in";
static const NSString * PencilTestHost = @"https://pencil-gate.iqing.com";
static const NSString * BfTestHost = @"https://bf-gate.iqing.com";
static const NSString * PayTestHost = @"https://pay-gate.iqing.com";

//static const NSString * APITestHost = @"https://api-staging.iqing.in";
//static const NSString * PencilTestHost = @"https://pencil-staging.iqing.in";
//static const NSString * BfTestHost = @"https://bf-staging.iqing.in";
//static const NSString * PayTestHost = @"https://pay-staging.iqing.in";


static const NSString * APIHost = @"https://api.iqing.in";
static const NSString * BfHost = @"https://bf.iqing.com";
static const NSString * PencilHost = @"https://pencil.iqing.com";
static const NSString * PayHost = @"https://pay.iqing.com";






static const NSString * FavBooksTestHost = @"https://index-gate.iqing.com";
static const NSString * FavBooksHost = @"https://index.iqing.com";

@interface QWTestEnvChangeTVC ()

@property (nonatomic, strong) NSArray *envs;

@end

@implementation QWTestEnvChangeTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.tableView.tintColor = QWPINK;

    self.title = @"选择环境";

    self.envs = @[@[@"测试环境", APITestHost], @[@"正式环境", APIHost]];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"重启" style:UIBarButtonItemStylePlain handler:^(id sender) {
        UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"提醒" message:@"是否重启App？"];
        [alertView bk_addButtonWithTitle:@"重启" handler:^{
            exit(0);
        }];
        [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [alertView show];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.envs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    NSArray *env = self.envs[indexPath.row];
    cell.textLabel.text = env[0];
    cell.detailTextLabel.text = env[1];

    if ([cell.detailTextLabel.text isEqualToString:[QWOperationParam currentDomain]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [[NSUserDefaults standardUserDefaults] setValue:cell.detailTextLabel.text forKey:API_ADDRESS];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [tableView reloadData];
    if (indexPath.row == 0) { //测试环境
        [[NSUserDefaults standardUserDefaults] setValue:APITestHost forKey:API_ADDRESS];
        [[NSUserDefaults standardUserDefaults] setValue:BfTestHost forKey:BF_API_ADDRESS];
        [[NSUserDefaults standardUserDefaults] setValue:PencilTestHost forKey:PENCIL_API_ADDRESS];
        [[NSUserDefaults standardUserDefaults] setValue:PayTestHost forKey:PAY_API_ADDRESS];
        [[NSUserDefaults standardUserDefaults] setValue:FavBooksTestHost forKey:FAVBOOKS_API_ADDRESS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if (indexPath.row == 1) {
        [[NSUserDefaults standardUserDefaults] setValue:APIHost forKey:API_ADDRESS];
        [[NSUserDefaults standardUserDefaults] setValue:BfHost forKey:BF_API_ADDRESS];
        [[NSUserDefaults standardUserDefaults] setValue:PencilHost forKey:PENCIL_API_ADDRESS];
        [[NSUserDefaults standardUserDefaults] setValue:PayHost forKey:PAY_API_ADDRESS];
        [[NSUserDefaults standardUserDefaults] setValue:FavBooksHost forKey:FAVBOOKS_API_ADDRESS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
