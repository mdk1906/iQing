//
//  QWNewMessageListVC.m
//  Qingwen
//
//  Created by mumu on 17/3/3.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWNewMessageListVC.h"
#import "QWNewMessageLogic.h"
#import "QWNewMessageCenterCell.h"
#import "QWNewMessageVC.h"

@interface QWNewMessageListVC () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet QWTableView *tableView;

@property (strong, nonatomic) QWNewMessageLogic *logic;
@end

@implementation QWNewMessageListVC

+ (void)load
{
    QWMappingVO *vo = [QWMappingVO new];
    vo.className = [NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject;
    vo.storyboardName = @"QWMessageCenter";
    
    [[QWRouter sharedInstance] registerRouterVO:vo withKey:@"myMessage"];
}


- (QWNewMessageLogic *)logic {
    if (!_logic) {
        _logic = [QWNewMessageLogic logicWithOperationManager:self.operationManager];
    }
    
    return _logic;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.tableView.tableFooterView = [UIView new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.scrollEnabled = false;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getData];
}

- (void)getData {
    if (self.logic.loading) {
        return;
    }
    WEAK_SELF;
    self.logic.loading = false;
    self.tableView.emptyView.showError = false;
    [self.logic getTalkListWithCompletBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        self.tableView.emptyView.showError = true;
        [self.tableView reloadData];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"singleMessage"] && [sender isKindOfClass:[TalkVO class]]) {
        QWNewMessageVC *vc = segue.destinationViewController;
        TalkVO *vo = (TalkVO *)sender;
        vc.title = vo.other.username;
        vc.talkVO = vo;
        NSLog(@"传值_%@",[NSDate date]);
    }
}

#pragma mark - UITableViewDelegate, UITableViewDatasoure

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.logic.talkList.talk_list) {
        return self.logic.talkList.talk_list.count;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return PX1_LINE * 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QWNewMessageCenterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageCenter" forIndexPath:indexPath];
    [cell updateCellWithMessageCenterVO:self.logic.talkList.talk_list[indexPath.section]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TalkVO *vo = self.logic.talkList.talk_list[indexPath.section];
    [self performSegueWithIdentifier:@"singleMessage" sender:vo];

}
@end
