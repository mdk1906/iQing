//
//  QWContributionCategoryVC.m
//  Qingwen
//
//  Created by Aimy on 9/17/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWContributionCategoryVC.h"

#import "QWContributionLogic.h"
#import "QWTableView.h"

@interface QWContributionCategoryVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) QWContributionLogic *logic;
@property (strong, nonatomic) IBOutlet QWTableView *tableView;

@end

@implementation QWContributionCategoryVC

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
    [self.logic getCategoryWithCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        [self.tableView reloadData];
        [self.logic.categoryVO.results.copy enumerateObjectsUsingBlock:^(__kindof CategoryItemVO * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            STRONG_SELF;
            CategoryItemVO *item = obj;
            NSUInteger index= idx;
            [self.categorys enumerateObjectsUsingBlock:^(__kindof CategoryItemVO * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CategoryItemVO *selectedItem = obj;
                if ([selectedItem isEqual:item]) {
                    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
            }];
        }];
        self.tableView.emptyView.showError = YES;
    }];
}

- (IBAction)onPressedDoneBtn:(id)sender
{
    if (self.tableView.indexPathsForSelectedRows.count < 2) {
        [self showToastWithTitle:@"至少选择2个分类" subtitle:nil type:ToastTypeAlert];
        return;
    }

    if (self.tableView.indexPathsForSelectedRows.count > 5) {
        [self showToastWithTitle:@"选择的分类不能超过5个" subtitle:nil type:ToastTypeAlert];
        return;
    }

    NSMutableArray *array = @[].mutableCopy;
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        CategoryItemVO *item = self.logic.categoryVO.results[indexPath.row];
        [array addObject:item];
    }

    self.categorys = array;
    [self performSegueWithIdentifier:@"category" sender:array];
}

#pragma mark - tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.logic.categoryVO.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    CategoryItemVO *itemVO = self.logic.categoryVO.results[indexPath.row];
    cell.textLabel.text = itemVO.name;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.indexPathsForSelectedRows.count > 5) {
        [self showToastWithTitle:@"选择的分类不能超过5个" subtitle:nil type:ToastTypeAlert];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
}

@end
