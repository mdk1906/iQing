//
//  QWUserDetailVC.m
//  Qingwen
//
//  Created by Aimy on 7/2/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWUserVC.h"

#import "QWMyCenterLogic.h"
#import <ActionSheetPicker-3.0/ActionSheetPicker.h>
#import "UITableView+FDTemplateLayoutCell.h"
#import "FavoriteBooksVO.h"
#import "QWOtherMedelVC.h"
@interface QWUserDetailVC ()

@property (nonatomic, strong) QWUserLogic *logic;
@property (nonatomic, strong) QWFavoriteBooksLogic *favoriteLogic;


@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet QWTableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageTop;

@property (strong, nonatomic) IBOutlet UIButton *attentionBtn;

@property (nonatomic, strong) NSString *profile_url;
@property (nonatomic, strong) NSString *username;

@property (nonatomic, strong) IBOutlet UIView *footerView;

@end

@implementation QWUserDetailVC

+ (void)load
{
    QWMappingVO *vo = [QWMappingVO new];
    vo.className = [NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject;
    vo.storyboardName = @"QWUser";
    vo.storyboardID = @"user";

    [[QWRouter sharedInstance] registerRouterVO:vo withKey:@"user"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.tableView.emptyView.errorImage = [UIImage imageNamed:@"empty_5_none"];
    self.tableView.emptyView.errorMsg = @"没有找到这个用户~";

    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = [QWSize getLengthWithSizeType:QWSizeType4_0 andLength:55];
    self.imageTop.constant = [QWSize getLengthWithSizeType:QWSizeType4_0 andLength:15];
    self.imageWidth.constant = [QWSize getLengthWithSizeType:QWSizeType4_0 andLength:110];
    CGRect frame = self.headerView.frame;
    frame.size.height = [QWSize getLengthWithSizeType:QWSizeType4_0 andLength:130];
    self.headerView.frame = frame;
    if ([self.extraData objectForCaseInsensitiveKey:@"profile_url"]) {
        self.profile_url = [self.extraData objectForCaseInsensitiveKey:@"profile_url"];
    }
    if ([self.extraData objectForCaseInsensitiveKey:@"username"]) {
        self.username = [self.extraData objectForCaseInsensitiveKey:@"username"];
    }

    [self getData];
}

- (QWUserLogic *)logic
{
    if (!_logic) {
        _logic = [QWUserLogic logicWithOperationManager:self.operationManager];
    }

    return _logic;
}

- (QWFavoriteBooksLogic *)favoriteLogic
{
    if (!_favoriteLogic) {
        _favoriteLogic = [QWFavoriteBooksLogic logicWithOperationManager:self.operationManager];
    }
    
    return _favoriteLogic;
}

- (void)getData
{
    WEAK_SELF;

    if (self.profile_url.length) {
        [self.logic getUserWithUrl:self.profile_url completeBlock:^(id aResponseObject, NSError *anError) {
            if (!anError) {
                STRONG_SELF;
                self.footerView.hidden = NO;
                self.title = self.logic.userVO.nid.stringValue;
                [self.tableView reloadData];
                [self getRelation];
                [self getUserFavoriteBooks];
//                [self getCount];
            }
            else {
                self.tableView.emptyView.showError = YES;
            }
        }];
    }
    else if (self.username.length) {
        [self.logic getUserWithUserName:self.username completeBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            if (!anError) {
                STRONG_SELF;
                self.footerView.hidden = NO;
                self.title = self.logic.userVO.nid.stringValue;
                [self.tableView reloadData];
                [self getRelation];
                [self getUserFavoriteBooks];
//                [self getCount];
            }
            else {
                self.tableView.emptyView.showError = YES;
            }
        }];
    }
}

- (void)getUserFavoriteBooks
{
    
    WEAK_SELF;
    [self.favoriteLogic getFavoriteBooksWithCompleteBlockWithListId:self.logic.userVO.nid isOwn:@1 :^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        [self.tableView reloadData];
    }];
    
}

- (void)getRelation
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        return;
    }

    WEAK_SELF;
    [self.logic getUserRelationWithUrl:self.logic.userVO.relationship_url completeBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        [self updateAttentionBtn];
    }];
}

- (void)updateAttentionBtn
{
    if (self.logic.follow.boolValue) {
        [self.attentionBtn setTitle:@"取消关注" forState:UIControlStateNormal];
    }
    else {
        [self.attentionBtn setTitle:@"关注" forState:UIControlStateNormal];
    }

    if ([QWGlobalValue sharedInstance].isLogin) {
        self.attentionBtn.enabled = !self.logic.myself.boolValue && self.logic.follow;
    }
}

- (void)getCount {
    WEAK_SELF;
    [self.logic getWithUrl:self.logic.userVO.friend_url completeBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        self.logic.friendCount = [aResponseObject[@"count"] integerValue];
        [self.tableView reloadData];
    }];

    [self.logic getWithUrl:self.logic.userVO.fan_url completeBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        self.logic.fanCount = [aResponseObject[@"count"] integerValue];
        [self.tableView reloadData];
    }];

    [self.logic getWithUrl:self.logic.userVO.work_url useOrigin:YES andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        self.logic.workCount = [aResponseObject[@"count"] integerValue];
        [self.tableView reloadData];
    }];
}

- (IBAction)onPressedAttentionBtn:(id)sender
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        return;
    }

    [self showLoading];

    WEAK_SELF;
    [self.logic doFriendAttentionWithCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        [self updateAttentionBtn];
        [self hideLoading];
    }];
}

#pragma mark - tv delegate datasource

- (NSInteger)numberOfSectionsInTableView:(nonnull UITableView *)tableView
{
    if (self.logic.userVO) {
        return 4;
    }
    else {
        return 0;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return 2;
    }else if(section == 2){
        return 2;
    }else if(section == 3){
        return 2;
    }

    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_WIDTH, 20)];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = HRGB(0xaeaeae);
    if (section == 1) {
        label.text = @"   评论信息";
    }
    else if (section == 2) {
        label.text = @"   关注信息";
    }
    else if (section == 3) {
        label.text = @"   投稿信息";
    }
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        WEAK_SELF;
        return [tableView fd_heightForCellWithIdentifier:@"head" cacheByIndexPath:indexPath configuration:^(id cell) {
            STRONG_SELF;
            QWUserDetailHeadTVCell *tempCell = cell;
            [tempCell updateWithUserVO:self.logic.userVO];
        }];
    }

    return 44;
}

- (UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        QWUserDetailHeadTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"head" forIndexPath:indexPath];
        [cell updateWithUserVO:self.logic.userVO];
        return cell;
    }
    else if (indexPath.section == 1) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"TA的评论";
            if (self.logic.userVO.comments) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", cell.textLabel.text, self.logic.userVO.comments];
            }
        
            return cell;
        }
        else{
            cell.textLabel.text = @"TA的勋章";
            if (self.logic.userVO.medals) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", cell.textLabel.text, self.logic.userVO.medals];
            }
            
            return cell;
        }
        
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.textLabel.text = @"TA的关注";
            if (self.logic.userVO.follow_count) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", cell.textLabel.text, self.logic.userVO.follow_count];
            }
            return cell;
        }
        else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.textLabel.text = @"关注TA的";
            if (self.logic.userVO.fans_count) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", cell.textLabel.text, self.logic.userVO.fans_count];
            }
            return cell;
        }
    }
    else if (indexPath.section == 3) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        if(indexPath.row == 0){
            cell.textLabel.text = @"TA的投稿";
            if (self.logic.userVO.work_count) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", cell.textLabel.text, self.logic.userVO.work_count];
            }
        }
        else if(indexPath.row == 1){
            cell.textLabel.text = @"TA的书单";
            FavoriteBooksListVO *fav = self.favoriteLogic.myFavoritelistVO;
            if(fav){
                if (fav.count) {
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", cell.textLabel.text, fav.count.stringValue];
                }else{
                     cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", cell.textLabel.text, @0];
                }
            }
        }
        
        return cell;
    }
    else {
        UITableViewCell *cell = [UITableViewCell new];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MyComments" bundle:nil];
        QWMyCommentsPageVC *vc = (id)[sb instantiateViewControllerWithIdentifier:@"MyCommentsPage"];
        vc.uid = self.logic.userVO.nid.stringValue;
        vc.inId = @"1";
        [self.navigationController pushViewController:vc animated:YES];
        }
        else{
            QWOtherMedelVC *vc = [QWOtherMedelVC new];
            vc.uid = self.logic.userVO.nid.stringValue;
            vc.avater = self.logic.userVO.avatar;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
    if (indexPath.section == 2) {
        if ( ! [QWGlobalValue sharedInstance].isLogin) {
            [[QWRouter sharedInstance] routerToLogin];
            return;
        }

        if (indexPath.row == 0) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"QWUser" bundle:nil];
            QWFriendVC *vc = (id)[sb instantiateViewControllerWithIdentifier:@"attention"];
            vc.url = self.logic.userVO.friend_url;
            vc.title = @"TA的关注";
            [self.navigationController pushViewController:vc animated:YES];
        }
        else {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"QWUser" bundle:nil];
            QWFriendVC *vc = (id)[sb instantiateViewControllerWithIdentifier:@"attention"];
            vc.url = self.logic.userVO.fan_url;
            vc.title = @"关注TA的";
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if (indexPath.section == 3) {
        NSMutableDictionary *params = @{}.mutableCopy;
        if(indexPath.row == 0){
            params[@"book_url"] = self.logic.userVO.work_url;
            params[@"title"] = self.logic.userVO.username;
            params[@"hidefilter"] = @1;
            [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"list" andParams:params]];
        }else if (indexPath.row == 1){
            NSNumber *uid = self.logic.userVO.nid;
            if(uid){
                params[@"type"] = @1;
                params[@"user_id"] = uid;
                [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"relative_favorite" andParams:params]];
            }
            
        }
       
    }
}

@end
