//
//  QWChangeStateTVC.m
//  Qingwen
//
//  Created by Aimy on 8/17/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWChangeStateTVC.h"

@interface QWChangeStateTVC () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSArray *resources;
@end

@implementation QWChangeStateTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden = false;

    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"state" ofType:@"plist"];
    self.resources = [NSArray arrayWithContentsOfFile:plistPath];

    self.tableView.tableFooterView = [UIView new];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.resources.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *resource = self.resources[section];
    NSArray *states = resource[@"states"];
    return states.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_WIDTH, 30)];
    label.font = [UIFont systemFontOfSize:12];
    if (section == 0) {
        label.layer.borderColor = HRGB(0xdcdcdc).CGColor;
        label.layer.borderWidth = PX1_LINE;
    }
    label.textColor = HRGB(0xaeaeae);

    NSDictionary *resource = self.resources[section];
    label.text = [NSString stringWithFormat:@"    %@", resource[@"name"]];

    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return PX1_LINE;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *resource = self.resources[indexPath.section];
    NSArray *states = resource[@"states"];
    NSDictionary *state = states[indexPath.row];
    cell.textLabel.text = state[@"name"];
    cell.detailTextLabel.text = state[@"code"];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    NSDictionary *resource = self.resources[indexPath.section];
    NSArray *states = resource[@"states"];
    NSDictionary *state = states[indexPath.row];
    self.selectedState = state[@"code"];
    self.selectedName = state[@"name"];
}

@end
