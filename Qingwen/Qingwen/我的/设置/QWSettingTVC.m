//
//  QWSettingTVC.m
//  Qingwen
//
//  Created by Aimy on 7/29/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWSettingTVC.h"

#import "QWReadingConfig.h"

#import <SDWebImage/SDWebImageManager.h>

#import <ActionSheetPicker-3.0/ActionSheetPicker.h>

#import "QWUserDefaults.h"
#import "QWMyCenterLogic.h"

@interface QWSettingTVC ()

@property (strong, nonatomic) QWMyCenterLogic *logic;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *resources;

@end

@implementation QWSettingTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.tableView.separatorInset = UIEdgeInsetsZero;
    if (IOS_SDK_MORE_THAN(8.0)) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }

    self.resources = @[
                       @[@[@"字体大小"], @[@"繁体输出"], @[@"屏幕常亮"],
                         ],
                       @[@[@"管理自动购买作品"],
                         ],
                       @[@[@"作品更新通知"], @[@"讨论区通知"], @[@"黑名单管理"]
                         ],
                       @[@[@"清除缓存空间"],
                         ],
                       @[@[@"隐私权政策"],@[@"用户注册协议"],@[@"关于我们"],
                         ],
                       ];

    if ([QWUserDefaults sharedInstance][@"bookpush"] == nil) {
        [QWUserDefaults sharedInstance][@"bookpush"] = @1;
    }

    if ([QWUserDefaults sharedInstance][@"discusspush"] == nil) {
        [QWUserDefaults sharedInstance][@"discusspush"] = @1;
    }
}

- (QWMyCenterLogic *)logic
{
    if (!_logic) {
        _logic = [QWMyCenterLogic logicWithOperationManager:self.operationManager];
    }

    return _logic;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([QWGlobalValue sharedInstance].isLogin) {
        [self getData];
    }
}

- (void)getData
{
    [self showLoading];
    WEAK_SELF;
    [self.logic getPushSettingCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        [self hideLoading];
        [self.tableView reloadData];
    }];
}

- (void)leftBtnClicked:(id)sender
{
    [[QWReadingConfig sharedInstance] saveData];
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.resources.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionRes = self.resources[section];
    return sectionRes.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return PX1_LINE;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_WIDTH, 30)];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = HRGB(0x848484);
    if (section == 0) {
        label.text = @"    阅读设置";
    }
    else if (section == 1) {
        label.text = @"    订阅设置";
    }
    else if (section == 2) {
        if ([[QWGlobalValue sharedInstance] isAllowdNotification]) {
            label.text = @"    推送设置";
        }
        else {
            label.text = @"请到iOS设置->通知->打开轻文轻小说的推送开关";
        }
    }

    else if (section == 3) {
        label.text = @"    系统优化";
    }
    else if (section == 4) {
        label.text = @"    帮助支持";
    }
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    if (IOS_SDK_MORE_THAN(8.0)) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }

    NSArray *sectionRes = self.resources[indexPath.section];
    NSArray *res = sectionRes[indexPath.row];
    cell.textLabel.text = res[0];
    cell.detailTextLabel.text = nil;

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
            cell.detailTextLabel.text = @([QWReadingConfig sharedInstance].fontSize).stringValue;
        }
        else if (indexPath.row == 1) {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            
//            UISwitch *traditionalSwitch = [UISwitch new];
//            [traditionalSwitch addTarget:self action:@selector(onPressedTraditionalSwitch:) forControlEvents:UIControlEventValueChanged];
//            traditionalSwitch.on = [QWReadingConfig sharedInstance].traditional;
            if([QWReadingConfig sharedInstance].originalFont == YES){
                cell.detailTextLabel.text = @"原文";
            }else{
                cell.detailTextLabel.text = ([QWReadingConfig sharedInstance].traditional == YES) ? @"繁体" : @"简体";
            }
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
        }
        else if (indexPath.row == 2) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *alwaysBrightnessSwitch = [UISwitch new];
            [alwaysBrightnessSwitch addTarget:self action:@selector(onPressedAlwaysBrightnessSwitch:) forControlEvents:UIControlEventValueChanged];
            alwaysBrightnessSwitch.on = [QWReadingConfig sharedInstance].alwaysBrightness;
            cell.accessoryView = alwaysBrightnessSwitch;
        }

    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
            //cell.detailTextLabel.text = @"";
        }
        
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *pushSwitch = [UISwitch new];
            [pushSwitch addTarget:self action:@selector(onPressedBookPushSwitch:) forControlEvents:UIControlEventValueChanged];
            pushSwitch.on = [[QWUserDefaults sharedInstance][@"bookpush"] boolValue];
            pushSwitch.enabled = [[QWGlobalValue sharedInstance] isAllowdNotification];
            cell.accessoryView = pushSwitch;
        }
        else if (indexPath.row == 1) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *pushSwitch = [UISwitch new];
            [pushSwitch addTarget:self action:@selector(onPressedDiscussPushSwitch:) forControlEvents:UIControlEventValueChanged];
            pushSwitch.on = [[QWUserDefaults sharedInstance][@"discusspush"] boolValue];
            pushSwitch.enabled = [[QWGlobalValue sharedInstance] isAllowdNotification];
            cell.accessoryView = pushSwitch;
        } else if (indexPath.row == 2) {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
        }
    }
    
    else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.01fMB",[SDImageCache sharedImageCache].getSize / 1024.0 / 1024.0];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (indexPath.row == 0) {
            WEAK_SELF;
            NSInteger index = [[QWReadingConfig sharedInstance].fontSzieString indexOfObject:@([QWReadingConfig sharedInstance].fontSize).stringValue];
            ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"字体大小" rows:[QWReadingConfig sharedInstance].fontSzieString initialSelection:index doneBlock:^(ActionSheetStringPicker *stringPicker, NSInteger selectedIndex, id selectedValue) {
                STRONG_SELF;
                NSString *value = selectedValue;
                [[QWReadingConfig sharedInstance] changeFontToSize:value];
                [self.tableView reloadData];
            } cancelBlock:^(ActionSheetStringPicker *stringPicker) {
                NSLog(@"cancel");
            } origin:cell];
            picker.tapDismissAction = TapActionCancel;
            UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:nil action:nil];
            cancelBtn.tintColor = QWPINK;
            [picker setCancelButton:cancelBtn];
            UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStyleDone target:nil action:nil];
            doneBtn.tintColor = QWPINK;
            [picker setDoneButton:doneBtn];
            [picker showActionSheetPicker];
        }
        if(indexPath.row == 1){
            UIActionSheet *actionSheet = [[UIActionSheet alloc] bk_initWithTitle:nil];
            WEAK_SELF;
            [actionSheet bk_addButtonWithTitle:@"原文" handler:^{
                STRONG_SELF;
                [QWReadingConfig sharedInstance].originalFont = YES;
                [self.tableView reloadData];
            }];
            
            [actionSheet bk_addButtonWithTitle:@"简体" handler:^{
                STRONG_SELF;
                [QWReadingConfig sharedInstance].originalFont = NO;
                [QWReadingConfig sharedInstance].traditional = NO;
                [self.tableView reloadData];
            }];
            [actionSheet bk_addButtonWithTitle:@"繁体" handler:^{
                STRONG_SELF;
                [QWReadingConfig sharedInstance].originalFont = NO;
                [QWReadingConfig sharedInstance].traditional = YES;
                [self.tableView reloadData];
            }];
            [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:^{
                [self.tableView reloadData];
            }];
            [actionSheet showInView:self.view];
        }
    }
    else if (indexPath.section == 1) {
        [self performSegueWithIdentifier:@"autoSubscribe" sender:nil];
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 2) {
            [self performSegueWithIdentifier:@"blacklist" sender:nil];
        }
    }

    else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            WEAK_SELF;
            UIAlertView *alert = [[UIAlertView alloc] bk_initWithTitle:@"提示" message:@"是否清除缓存？"];
            [alert bk_setCancelButtonWithTitle:@"取消" handler:^{

            }];

            [alert bk_addButtonWithTitle:@"是" handler:^{
                STRONG_SELF;

                [self.view.window showLoading];

                [QWUserDefaults sharedInstance][@"wbAttention"] = nil;//清除微博登录
                [QWUserDefaults sharedInstance][@"showChannel2.0.0"] = nil;//清除分区选择
                [QWUserDefaults sharedInstance][@"channel"] = nil;//清除分区选择

                [[NSURLCache sharedURLCache] removeAllCachedResponses];//清除网络缓存

                [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{//清除图片缓存
                    STRONG_SELF;
                    [self.tableView reloadData];
                    [self.view.window hideLoading];
                }];
            }];
            [alert show];
        }
    }
    else if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            //隐私权政策
            [[QWRouter sharedInstance] routerWithUrl:[NSURL URLWithString:@"https://www.iqing.com/info/#/privacy"]];
        }
        if (indexPath.row == 1) {
            //用户注册协议
            [[QWRouter sharedInstance] routerWithUrl:[NSURL URLWithString:@"https://www.iqing.com/info/#/registration"]];
            
        }
        if (indexPath.row == 2) {
            //关于我们
            [self performSegueWithIdentifier:@"about" sender:self];
        }
    }
}

#pragma mark - action

- (void)onPressedTraditionalSwitch:(UISwitch *)sender
{
    [QWReadingConfig sharedInstance].traditional = sender.on;
}

- (void)onPressedAlwaysBrightnessSwitch:(UISwitch *)sender
{
    [QWReadingConfig sharedInstance].alwaysBrightness = sender.on;
    [UIApplication sharedApplication].idleTimerDisabled = [QWReadingConfig sharedInstance].alwaysBrightness;
}

- (void)onPressedBookPushSwitch:(UISwitch *)sender
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        return ;
    }

    [self showLoading];
    WEAK_SELF;
    [self.logic setPushSettingWithType:0 open:sender.on andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"data"];
                if (message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:@"提交失败" subtitle:nil type:ToastTypeError];
                }
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }

        [self.tableView reloadData];
        [self hideLoading];
    }];
}

- (void)onPressedDiscussPushSwitch:(UISwitch *)sender
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        return ;
    }

    [self showLoading];
    WEAK_SELF;
    [self.logic setPushSettingWithType:1 open:sender.on andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"data"];
                if (message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:@"提交失败" subtitle:nil type:ToastTypeError];
                }
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }

        [self.tableView reloadData];
        [self hideLoading];
    }];
}

@end
