//
//  QWAutoSubscriberManager.m
//  Qingwen
//
//  Created by wei lu on 18/11/17.
//  Copyright © 2017 iQing. All rights reserved.
//

#import "QWSettingTVC.h"
#import "QWMyCenterLogic.h"
#import "QWAutoSubscriberManager.h"
#import "QWAutoSubscriberListTVCell.h"

@interface QWAutoSubscriberTVC () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) QWMyCenterLogic *logic;

@property (weak, nonatomic) IBOutlet QWTableView *tableView;
@property (copy, nonatomic) SubscriberBookList *subscriberList;

@end

@implementation QWAutoSubscriberTVC

- (QWMyCenterLogic *)logic
{
    if (!_logic) {
        _logic = [QWMyCenterLogic logicWithOperationManager:self.operationManager];
    }
    
    return _logic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (IOS_SDK_MORE_THAN(8.0)) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([QWGlobalValue sharedInstance].isLogin) {
        [self getData];
    }else{
        [[QWRouter sharedInstance] routerToLogin];
    }
}

- (void)getData
{
    WEAK_SELF;
    self.tableView.emptyView.showError = false;
    [self showLoading];
    [self.logic getSubscriberListCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        self.tableView.emptyView.showError = true;
        self.subscriberList = [SubscriberBookList voWithDict:aResponseObject];
        if(self.subscriberList){
            [self.tableView reloadData];
        }
        [self hideLoading];
    }];
}

- (void)configSubscribeBook:(NSNumber*)book isOn:(BOOL)value cell:(QWAutoSubscriberListTVCell*) cell
{
    WEAK_SELF;
    [self showLoading];
    [self.logic setSubscribedBookCompleteBlock:(NSNumber *)book isSub:(BOOL)value CompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        [self hideLoading];
        [self getData];
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            NSLog(@"result :%@",code);
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"msg"];
                if (message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:@"提交失败" subtitle:nil type:ToastTypeError];
                }
            }else{
                
                [cell.switchView setOn:value animated:true];
            }
        }
        else {
            [cell.switchView setOn:!value];
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.subscriberList.count){
        return self.subscriberList.results.count;
    }
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QWAutoSubscriberListTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell updateWithSuscribeList:self.subscriberList.results[indexPath.row]];
    
    if(cell.switchView){
        [cell.switchView addTarget:self action:@selector(onPressedSubscribeSwitch:) forControlEvents:UIControlEventValueChanged];
        cell.switchView.tag = indexPath.row;
    }
    
    return cell;
}



- (void)onPressedSubscribeSwitch:(UISwitch *)sender
{
    SubscriberBooks *subscribe = self.subscriberList.results[sender.tag];
    BOOL value = ![subscribe.toggle boolValue];
    QWAutoSubscriberListTVCell *cell = (QWAutoSubscriberListTVCell*)sender.superview;
    [sender setOn:!value animated:false];
    [self configSubscribeBook:subscribe.book isOn:value cell:cell];
}
@end
