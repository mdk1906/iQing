//
//  QWBlackListVC.m
//  Qingwen
//
//  Created by mumu on 2017/9/29.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWBlackListVC.h"
#import "QWBlacListManager.h"
#import "QWBlickListTVCell.h"

@interface QWBlackListVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) QWMyCenterLogic *logic;
@property (strong, nonatomic) IBOutlet QWTableView *tableView;

@end

@implementation QWBlackListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 80;
    // Do any additional setup after loading the view.
}

- (IBAction)onPressedCancelBlackBtn:(id)sender forEvent:(UIEvent *)event {
    UITouch *touch = event.allTouches.anyObject;
    CGPoint point = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    UserVO *user = [[QWBlacListManager sharedInstance] blackValues][indexPath.row];
    [[QWBlacListManager sharedInstance] removeFromBlackListWithUser:user];
    [self.tableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([QWBlacListManager sharedInstance].blackValues) {
        return [QWBlacListManager sharedInstance].blackValues.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QWBlickListTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell updateWithUserVO:[QWBlacListManager sharedInstance].blackValues[indexPath.row]];
    return cell;
}

@end
