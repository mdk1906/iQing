//
//  QWContributionActivityVC.m
//  Qingwen
//
//  Created by mumu on 2017/5/4.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWContributionActivityVC.h"

@interface QWContributionActivityVC ()

@property (nonatomic, strong) QWContributionLogic *logic;
@property (strong, nonatomic) IBOutlet QWTableView *tableView;

@end

@implementation QWContributionActivityVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.editing = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    [self getData];
}

- (QWContributionLogic *)logic
{
    if (!_logic) {
        _logic = [QWContributionLogic logicWithOperationManager:self.operationManager];
    }
    
    return _logic;
}

- (void)getData
{
    self.tableView.emptyView.showError = NO;
    WEAK_SELF;
    [self.logic getActivitListWithCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        [self.tableView reloadData];
        [self.logic.activityList.results.copy enumerateObjectsUsingBlock:^(__kindof ActivityVO * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            STRONG_SELF;
            ActivityVO *item = obj;
            NSUInteger index= idx;
            [self.activitys enumerateObjectsUsingBlock:^(__kindof ActivityVO * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ActivityVO *selectedItem = obj;
                if ([selectedItem.title isEqualToString:item.title]) {
                    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
            }];
        }];
    }];
}

- (IBAction)onPressedDoneBtn:(id)sender
{
    NSMutableArray *array = @[].mutableCopy;
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        ActivityVO *vo = self.logic.activityList.results[indexPath.row];
        [array addObject:vo];
    }
    self.activitys = array;
    [self performSegueWithIdentifier:@"activity" sender:array];
}
- (IBAction)onPressedActivityDetailBtn:(UIButton *)sender forEvent:(UIEvent *)event {
    UITouch *touch = event.allTouches.anyObject;
    CGPoint point = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    ActivityVO *activityVO = self.logic.activityList.results[indexPath.row];
    
    QWActivityPageVC *vc = [QWActivityPageVC createFromStoryboardWithStoryboardID:@"activitypage" storyboardName:@"QWActivity" bundleName:nil];
    vc.activityVO = activityVO;
    vc.inId = @"1";
    [self.navigationController pushViewController:vc animated:true];
}

#pragma mark - tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.logic.activityList.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    ActivityVO *activityVO = self.logic.activityList.results[indexPath.row];
    
    UILabel *titleLabel = [cell viewWithTag:98];
    titleLabel.text = activityVO.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WEAK_SELF;
    [self.tableView.indexPathsForSelectedRows enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        STRONG_SELF;
        if (![obj isEqual:indexPath]) {
            [self.tableView deselectRowAtIndexPath:obj animated:false];
        }
    }];
}

@end
