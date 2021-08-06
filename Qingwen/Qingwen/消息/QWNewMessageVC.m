//
//  QWNewMessageVC.m
//  Qingwen
//
//  Created by mumu on 17/3/3.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWNewMessageVC.h"
#import "QWNewMessageCell.h"
#import "NewMessageVO.h"
#import "QWNewMessageLogic.h"
#import "QWNewMessageCell.h"
#import "ExpandVO.h"


static NSString * const messageIdentifer = @"QWNewMessageCell";

@interface QWNewMessageVC ()

@property (strong, nonatomic) IBOutlet QWTableView *tableView;
@property (strong, nonatomic) QWNewMessageLogic *logic;

@property (nonatomic, assign, getter=isLoadingFinshed) BOOL loadingFished;

@property (strong, nonatomic) UIButton *uploadMoreBtn;

@end

@implementation QWNewMessageVC

+ (void)load
{
    QWMappingVO *vo = [QWMappingVO new];
    vo.className = [NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject;
    vo.storyboardName = @"QWMessageCenter";
    vo.storyboardID = @"newmessage";
    
    [[QWRouter sharedInstance] registerRouterVO:vo withKey:@"message"];
}


- (QWNewMessageLogic *)logic {
    if (!_logic) {
        _logic = [QWNewMessageLogic logicWithOperationManager:self.operationManager];
    }
    return _logic;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.tableView.backgroundColor = [UIColor colorF4];
    self.tableView.tableFooterView = [UIView new];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    [self.tableView registerNib:[UINib nibWithNibName:messageIdentifer bundle:nil] forCellReuseIdentifier:messageIdentifer];
    
    if (self.extraData && [self.extraData objectForCaseInsensitiveKey:@"other_id"]) {
        TalkVO *talk = [TalkVO new];
        UserVO *other = [UserVO new];
        other.nid = [self.extraData objectForCaseInsensitiveKey:@"other_id"];
        talk.unread_num = @0;
        talk.other = other;
        self.talkVO = talk;
    }
    
    WEAK_SELF;
    self.tableView.mj_header = [QWRefreshHeader headerWithRefreshingBlock:^{
        STRONG_SELF;
        [self getMoreData];
    }];
    [self getData];

//    [(QWRefreshHeader *)self.tableView.mj_header setTitle:@"最后一条消息" forState:MJRefreshStateNoMoreData];
//    [(QWRefreshHeader *)self.tableView.mj_header setTitle:@"消息拉取中..." forState:MJRefreshStateIdle];

}

- (void)getData {
    if (self.logic.loading) {
        return;
    }
    NSLog(@"取值_%@",[NSDate date]);

    self.logic.loading = true;
    self.tableView.emptyView.showError = false;
    WEAK_SELF;
    [self.logic getSingelMessageListWithTargetId:self.talkVO.other.nid andCompletBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        self.logic.loading = false;
        self.tableView.emptyView.showError = true;
        
        self.title = self.logic.messageList.other.username;
        if (self.talkVO.unread_num.integerValue > self.logic.messageList.count.integerValue) {
            [self showUploadMoreBtn];
        }
        
        [self.tableView reloadData];
        
        [self scrollBottom];
        
        if ([self isLoadingFinshed]) {
            self.tableView.mj_header = nil;
        }
    }];
}

- (void)getMoreData { //倒序

    if (self.logic.loading) {
        return;
    }
    self.logic.loading = true;
    WEAK_SELF;
    [self.logic getSingelMessageListWithTargetId:self.talkVO.other.nid andCompletBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        self.logic.loading = false;
        
        [self.tableView reloadData];
        
        [self scrollBottom];
        [self hideUploadMoreBtn];
        
        [self.tableView.mj_header endRefreshing];
        if ([self isLoadingFinshed]) {
            self.tableView.mj_header = nil;
        }
    }];
}

- (void)getUnreadData {
    if (self.logic.loading) {
        return;
    }
    self.logic.loading = true;
    [self.tableView.mj_header beginRefreshing];
   // self.logic.messageList.message_list = nil;
    WEAK_SELF;
    [self.logic getUnreadMessageListWithStart:(self.logic.messageList.all_count.integerValue - self.talkVO.unread_num.integerValue) end:self.logic.messageList.all_count.integerValue andTargetId:self.talkVO.other.nid andCompletBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        self.logic.loading = false;
        
        [self.tableView reloadData];
        [self hideUploadMoreBtn];
        
        [self.tableView.mj_header endRefreshing];
        if ([self isLoadingFinshed]) {
            self.tableView.mj_header = nil;
        }
    }];
}

- (BOOL)isLoadingFinshed {
    return self.logic.messageList.all_count.integerValue == self.logic.messageList.message_list.count;
}

- (void)showUploadMoreBtn {
    _uploadMoreBtn = [[UIButton alloc] init];
    [self.view addSubview:_uploadMoreBtn];
    
    [_uploadMoreBtn autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view withOffset:0];
    if (ISIPHONEX) {
        [_uploadMoreBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view withOffset:100];
    }
    else{
        [_uploadMoreBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view withOffset:76];
    }
    
    
    
    NSMutableAttributedString *btnAttribute = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%ld条新消息",self.talkVO.unread_num.integerValue - self.logic.messageList.end] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13],NSForegroundColorAttributeName: [UIColor colorQWPinkDark]}];
    
    [_uploadMoreBtn setAttributedTitle:btnAttribute forState:UIControlStateNormal];
    [_uploadMoreBtn setBackgroundImage:[UIImage imageNamed:@"message_new_bg"] forState:UIControlStateNormal];
    [_uploadMoreBtn setImage:[UIImage imageNamed:@"message_new_load"] forState:UIControlStateNormal];
    [_uploadMoreBtn setAdjustsImageWhenHighlighted:false];
    
    _uploadMoreBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
    _uploadMoreBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    
    [_uploadMoreBtn addTarget:self action:@selector(getUnreadData) forControlEvents:UIControlEventTouchUpInside];
}

- (void)hideUploadMoreBtn {
    self.uploadMoreBtn.hidden = YES;
}

- (void)scrollBottom {
    NSIndexPath *indexPath;
    if (self.logic.messageList.end && self.logic.messageList.message_list.count > 0 ) {
        if (self.logic.messageList.message_list.count > self.logic.messageList.end) {
            indexPath = [NSIndexPath indexPathForRow:0 inSection:self.logic.messageList.end];
        }else {
            indexPath = [NSIndexPath indexPathForRow:0 inSection:self.logic.messageList.message_list.count - 1];
        }
    }
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:false];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.logic.messageList) {
        return self.logic.messageList.message_list.count;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QWNewMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:messageIdentifer forIndexPath:indexPath];
    [cell updateCellWithMessageVO:self.logic.messageList.message_list[indexPath.section]];
    [cell updateAvatarImage:self.logic.messageList.other.avatar];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return PX1_LINE;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat height = [QWNewMessageCell heightWithMessage:self.logic.messageList.message_list[indexPath.section]];
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NewMessageVO *vo = self.logic.messageList.message_list[indexPath.section];
    if (vo) {
        if ([vo.expand.links isEmpty]) {
            return;
        }
        NSString *routerString = [NSString getRouterVCUrlStringFromUrlString:vo.expand.links];
        
        [[QWRouter sharedInstance] routerWithUrlString:routerString];
    }
}

@end
