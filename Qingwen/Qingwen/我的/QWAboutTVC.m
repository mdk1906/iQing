//
//  QWAboutTVC.m
//  Qingwen
//
//  Created by Aimy on 7/2/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWAboutTVC.h"

#import <MFMailComposeViewController+BlocksKit.h>
#import <sys/utsname.h>
#import "QWTracker.h"
#import "QWUserDefaults.h"
#import "QWFileManager.h"
#import <GBVersionTracking.h>

@interface QWAboutTVC () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *resources;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIView *tableFooterView;
@property (strong, nonatomic) IBOutlet UIView *tableFooterContentView;

@property (strong, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation QWAboutTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    NSString *head = @"版本";

    if ([QWTracker sharedInstance].isBeta) {
        head = @"Beta版本";
    }
    else {
        head = @"版本";
    }

    self.versionLabel.text = [NSString stringWithFormat:@"%@: %@ (%@)", head, [QWTracker sharedInstance].Build, [QWTracker sharedInstance].BuildVersion];

    NSString *patch = [QWUserDefaults sharedInstance][[QWTracker sharedInstance].Build];
    if (patch) {
        self.versionLabel.text = [NSString stringWithFormat:@"%@: %@.%@ (%@)", head, [QWTracker sharedInstance].Build, patch, [QWTracker sharedInstance].BuildVersion];
    }

    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 58;

    self.resources = @[@[@[@"官方网站", @"http://www.iQing.com"], @[@"官方微博", @"http://weibo.com/iqingin"], @[@"客服QQ", @"QQ:3012575446"]],
  @[@[@"反馈①群", @"QQ:300646916"], @[@"反馈②群", @"QQ:475709984"], @[@"轻文官方①群", @"QQ:414264005"], @[@"轻文官方②群", @"QQ:291944468"]],
  @[@[@"反馈邮箱", @"report@iQing.com"],
  @[@"评价我们", @""]],
  @[@[@"特别声明"], @[@"投稿须知"]]];

    if (IOS_SDK_LESS_THAN(8.0)) {
        CGRect frame = self.tableFooterView.frame;
        frame.size.height = self.tableFooterContentView.frame.origin.y + self.tableFooterContentView.frame.size.height + 20;
        self.tableFooterView.frame = frame;
        self.tableView.tableFooterView = self.tableFooterView;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (IOS_SDK_MORE_THAN_OR_EQUAL(8.0)) {
        CGRect frame = self.tableFooterView.frame;
        frame.size.height = self.tableFooterContentView.frame.origin.y + self.tableFooterContentView.frame.size.height + 20;
        self.tableFooterView.frame = frame;
        self.tableView.tableFooterView = self.tableFooterView;
    }
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"evaluate" forIndexPath:indexPath];
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        NSArray *sectionRes = self.resources[indexPath.section];
        NSArray *res = sectionRes[indexPath.row];
        cell.textLabel.text = res[0];
        cell.detailTextLabel.text = res[1];

        if (cell.detailTextLabel.text == nil || [cell.textLabel.text isEqualToString:@"反馈邮箱"] || [cell.textLabel.text isEqualToString:@"投稿须知"]) {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
        }
        else {
            cell.accessoryView = nil;
        }

        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2 && indexPath.row == 0) {

        struct utsname device_info;
        uname(&device_info);
        NSString *emailBody = [NSString stringWithFormat:@"Model: %s\nSystemVersion: %@\nAppVersion: %@\nPreviousAppVersion: %@\nChannel: %@\nDiskSpace: %@\nBuildVersion: %@", device_info.machine, [QWTracker sharedInstance].Version, [QWTracker sharedInstance].Build, [GBVersionTracking previousVersion], [QWTracker sharedInstance].channel, [QWFileManager usedSpaceAndfreeSpace], [QWTracker sharedInstance].BuildVersion];

        if ([QWGlobalValue sharedInstance].isLogin) {
            emailBody = [emailBody stringByAppendingFormat:@"\nUserId: %@", [QWGlobalValue sharedInstance].nid];
        }

        emailBody = [emailBody stringByAppendingString:@"\n\nTel: \n"];
        emailBody = [emailBody stringByAppendingString:@"QQ: \n"];
        emailBody = [emailBody stringByAppendingString:@"\n反馈意见: \n"];

        if ([MFMailComposeViewController canSendMail]) {
            [self showLoading];

            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];/*MFMailComposeViewController邮件发送选择器*/
            picker.navigationBar.tintColor = HRGB(0x505050);

            [picker setToRecipients:@[@"report@iQing.com"]];
            [picker setSubject:[NSString stringWithFormat:@"意见反馈iOS(%@)", [QWTracker sharedInstance].Build]];
            [picker setMessageBody:emailBody isHTML:NO];

            WEAK_SELF;
            [picker bk_setCompletionBlock:^(MFMailComposeViewController *controller, MFMailComposeResult result, NSError *anError) {
                STRONG_SELF;
                if (result == MFMailComposeResultSent) {
                    [self showToastWithTitle:@"反馈成功" subtitle:nil type:ToastTypeAlert];
                }
                else if (anError || result == MFMailComposeResultFailed) {
                    [self showToastWithTitle:@"反馈失败" subtitle:nil type:ToastTypeAlert];
                }
            }];

            if (picker) {
                [self presentViewController:picker animated:YES completion:^{
                    STRONG_SELF;
                    [self hideLoading];
                }];
            }
        }
        else {
            NSString *email = [NSString stringWithFormat:@"mailto:report@iQing.com?subject=意见反馈iOS(%@)&body=%@", [QWTracker sharedInstance].Build, emailBody];
            email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
        }
    }
    else if (indexPath.section == 2 && indexPath.row == 1) {
        NSString *evaluate = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id%@?mt=8", APP_ID];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:evaluate]];
    }
    else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"info" sender:self];
        }
        else {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[@"title"] = @"投稿须知";
            params[@"localurl"] = [[NSBundle mainBundle] pathForResource:@"submit_notice" ofType:@"html"];
            [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"web" andParams:params]];
        }
    }
}

@end
