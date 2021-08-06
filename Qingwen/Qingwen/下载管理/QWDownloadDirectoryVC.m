//
//  QWDownloadDirectoryVC.m
//  Qingwen
//
//  Created by Aimy on 9/29/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWDownloadDirectoryVC.h"

#import "BookCD.h"
#import "VolumeCD.h"
#import "QWFileManager.h"
#import "QWTableView.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "QWReadingManager.h"
#import "QWDownloadDirectoryVolumeTVCell.h"
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#import "QWDetailLogic.h"
#import "VolumeList.h"

@interface QWDownloadDirectoryVC () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet QWTableView *tableView;

@property (nonatomic, strong) QWDetailLogic *logic;

@property (strong, nonatomic) UIBarButtonItem *backBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *allSelectedBtn;

@property (nonatomic, strong) BookCD *book;
@property (nonatomic, strong) BookVO *bookVO;
@property (nonatomic, copy) NSArray<VolumeVO *> *volumes;
@property (nonatomic, strong) VolumeVO *lastVolume;
@property (nonatomic, strong) VolumeCD *lastVolumeCD;
@property (nonatomic, strong) ChapterVO *lastChapter;

@property (strong, nonatomic) NSArray *indexPathsForSelectedRows;

@end

@implementation QWDownloadDirectoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.backBtn = self.navigationItem.leftBarButtonItem;
    self.navigationController.toolbar.tintColor = HRGB(0x848484);
    self.navigationController.toolbar.barTintColor = [UIColor whiteColor];

    WEAK_SELF;
    [self observeProperty:@"indexPathsForSelectedRows" withBlock:^(__weak id self, id old, id newVal) {
        KVO_STRONG_SELF;

        kvoSelf.deleteBtn.enabled = (kvoSelf.indexPathsForSelectedRows.count > 0);

        if (kvoSelf.indexPathsForSelectedRows.count > 0 && kvoSelf.indexPathsForSelectedRows.count == kvoSelf.volumes.count) {
            kvoSelf.allSelectedBtn.title = @"全不选";
        }
        else {
            kvoSelf.allSelectedBtn.title = @"全选";
        }
    }];
}

- (QWDetailLogic *)logic
{
    if ( ! _logic) {
        _logic = [QWDetailLogic logicWithOperationManager:self.operationManager];
    }

    return _logic;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self getData];
}

- (void)getData
{
    WEAK_SELF;
    [self performInThreadBlock:^{
        STRONG_SELF;

        self.book = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == NO", self.bookId] inContext:[QWFileManager qwContext]];
        self.bookVO = [self.book toBookVO];
        self.title = self.book.title;
        NSArray<VolumeCD *> *volumeCDs = [VolumeCD MR_findAllSortedBy:@"order" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"bookId == %@ AND download == YES", self.book.nid] inContext:[QWFileManager qwContext]];

        VolumeCD *lastVolumeCD = [VolumeCD findLastReadingVolumeWithBookId:self.book.nid];
        self.lastVolumeCD = lastVolumeCD;
        self.lastVolume = nil;
        self.lastChapter = nil;

        if (self.lastVolumeCD) {
            self.lastVolume = [VolumeVO voWithJson:[QWFileManager loadVolumeWithBookId:self.lastVolumeCD.bookId.stringValue volumeId:self.lastVolumeCD.nid.stringValue]];;
        }

        NSMutableArray<VolumeVO *> *volumes = [NSMutableArray array];
        WEAK_SELF;
        [volumeCDs enumerateObjectsUsingBlock:^(VolumeCD *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            STRONG_SELF;
            VolumeVO *volume = [VolumeVO voWithJson:[QWFileManager loadVolumeWithBookId:obj.bookId.stringValue volumeId:obj.nid.stringValue]];
            NSString *json = [QWFileManager loadChapterWithBookId:obj.bookId.stringValue volumeId:obj.nid.stringValue];
            NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding] ?: [NSData data];
            NSArray *chapter = [ChapterVO arrayOfModelsFromData:data error:NULL];
            volume.chapter = (id)chapter;
            if (volume) {
                [volumes addObject:volume];
            }

        }];

        if (self.lastVolume) {
            NSString *json = [QWFileManager loadChapterWithBookId:self.lastVolumeCD.bookId.stringValue volumeId:self.lastVolumeCD.nid.stringValue];
            NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding] ?: [NSData data];
            NSArray *chapter = [ChapterVO arrayOfModelsFromData:data error:NULL];
            ChapterVO *lastChapter = chapter[self.lastVolumeCD.chapterIndex.integerValue];
            self.lastChapter = lastChapter;
            if (lastChapter) {
                self.lastVolume.chapter = (id)@[lastChapter];
            }
            [volumes insertObject:self.lastVolume atIndex:0];
        }

        self.volumes = volumes;

        [self performInMainThreadBlock:^{
            STRONG_SELF;
            [self.tableView reloadData];
            self.tableView.emptyView.showError = YES;

            [self.logic getDirectoryWithUrl:self.bookVO.chapter_url andCompleteBlock:^(id aResponseObject, NSError *anError) {
                STRONG_SELF;
                [self.tableView reloadData];
            }];
        }];
    }];
}

- (IBAction)onPressedEditBtn:(id)sender {
    self.deleteBtn.enabled = NO;
    self.allSelectedBtn.enabled = YES;
    self.navigationItem.leftBarButtonItem = self.cancelBtn;
    self.navigationItem.rightBarButtonItem = self.deleteBtn;
    [self.tableView setEditing:NO animated:NO];
    [self.tableView setEditing:YES animated:YES];

    [self.navigationController setToolbarHidden:NO animated:YES];

    self.fd_interactivePopDisabled = YES;

    [self onPressedSelectedAllBtn:sender];
}

- (IBAction)onPressedSelectedAllBtn:(id)sender {
    if (self.indexPathsForSelectedRows.count > 0 && self.indexPathsForSelectedRows.count == self.volumes.count) {
        for (int i = 0 ; i < self.volumes.count; i++) {
            [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i] animated:NO];
        }
    }
    else {
        for (int i = 0 ; i < self.volumes.count; i++) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    self.indexPathsForSelectedRows = self.tableView.indexPathsForSelectedRows;
}

- (IBAction)onPressedCancelBtn:(id)sender {
    self.navigationItem.leftBarButtonItem = self.backBtn;
    self.navigationItem.rightBarButtonItem = self.editBtn;
    [self.tableView setEditing:NO animated:YES];

    [self.navigationController setToolbarHidden:YES animated:YES];

    self.fd_interactivePopDisabled = NO;
    self.indexPathsForSelectedRows = nil;
}

- (IBAction)onPressedDeleteBtn:(id)sender
{
    WEAK_SELF;
    UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"提示" message:@"是否删除选择的下载？"];
    [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];
    [alertView bk_addButtonWithTitle:@"删除" handler:^{
        STRONG_SELF;
        [self.tabBarController.view showLoading];
        for (NSIndexPath *indexPath in self.indexPathsForSelectedRows) {
            VolumeVO *volumeVO = self.volumes[indexPath.section];
            VolumeCD *volumeCD = [VolumeCD MR_findFirstByAttribute:@"nid" withValue:volumeVO.nid inContext:[QWFileManager qwContext]];
            [QWFileManager deleteVolumeWithBookId:volumeCD.bookId.stringValue volumeId:volumeCD.nid.stringValue write:NO];
        }

        [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];
        self.indexPathsForSelectedRows = nil;
        [self onPressedCancelBtn:self.cancelBtn];
        [self getData];
        [self.tableView reloadEmptyDataSet];
        [self.tabBarController.view hideLoading];
    }];
    [alertView show];
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.volumes.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    VolumeVO *volume = self.volumes[section];
    if (volume == self.lastVolume) {
        return volume.chapter.count;
    }
    else {
        return volume.chapter.count + 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 50;
    }
    else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.lastVolume && section == 0) {
        return 10;
    }

    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.lastVolume && indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"lastreading" forIndexPath:indexPath];
        VolumeVO *volume = self.volumes[indexPath.section];
        ChapterVO *chapter = volume.chapter[indexPath.row];
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:@"[继续阅读]" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: QWPINK}];
        if (chapter.title) {
            [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:chapter.title attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: HRGB(0x505050)}]];
        }
        cell.textLabel.attributedText = attributedText;

        return cell;
    }
    else {
        if (indexPath.row == 0) {
            QWDownloadDirectoryVolumeTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"volume" forIndexPath:indexPath];
            VolumeVO *volume = self.volumes[indexPath.section];
            VolumeVO *originVolume = [self.logic.volumeList.results filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"nid == %@", volume.nid]].firstObject;
            [cell updateWithBookVO:self.bookVO volume:volume originVolume:originVolume];
            return cell;
        }
        else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            VolumeVO *volume = self.volumes[indexPath.section];
            ChapterVO *chapter = volume.chapter[indexPath.row - 1];
            VolumeCD *volumeCD = self.lastVolumeCD;
            if ([volumeCD.nid isEqualToNumber:volume.nid] && [self.lastChapter.nid isEqualToNumber:chapter.nid]) {
                NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:@"[继续阅读]" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: QWPINK}];
                [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:chapter.title attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: HRGB(0x505050)}]];
                cell.textLabel.attributedText = attributedText;

            }
            else {
                if (![QWFileManager isChapterExitWithBookId:self.book.nid.stringValue volumeId:volume.nid.stringValue chapterId:chapter.nid.stringValue]) {
                    cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@(下载失败)",chapter.title] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: [UIColor redColor]}];
                } else {
                    cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:chapter.title attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: HRGB(0x505050)}];
                }
            }
            
            return cell;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.isEditing) {
        return UITableViewCellEditingStyleNone;
    }
    else {
        if (indexPath.row == 0) {
            return UITableViewCellEditingStyleDelete;
        }
        else {
            return UITableViewCellEditingStyleNone;
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        WEAK_SELF;
        UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"提示" message:@"是否删除下载？"];
        [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [alertView bk_addButtonWithTitle:@"删除" handler:^{
            STRONG_SELF;
            [self.tabBarController.view showLoading];
            VolumeVO *volumeVO = self.volumes[indexPath.section];
            VolumeCD *volumeCD = [VolumeCD MR_findFirstByAttribute:@"nid" withValue:volumeVO.nid inContext:[QWFileManager qwContext]];
            [QWFileManager deleteVolumeWithBookId:volumeCD.bookId.stringValue volumeId:volumeCD.nid.stringValue write:NO];

            [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];
            self.indexPathsForSelectedRows = nil;
            [self onPressedCancelBtn:self.cancelBtn];
            [self getData];
            [self.tableView reloadEmptyDataSet];
            [self.tabBarController.view hideLoading];
        }];
        [alertView show];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.isEditing) {
        if (indexPath.row > 0) {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
        else {
            self.indexPathsForSelectedRows = self.tableView.indexPathsForSelectedRows;
        }
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        BookCD *bookCD = self.book;

        if (self.lastVolume && indexPath.section == 0) {
            VolumeList *volumes = [VolumeList new];
            volumes.results = (id)self.volumes;

            VolumeVO *volumeVO = self.volumes[indexPath.section];
            VolumeCD *volumeCD = [VolumeCD MR_findFirstByAttribute:@"nid" withValue:volumeVO.nid inContext:[QWFileManager qwContext]];
            BookVO *bookVO = [BookVO voWithJson:[QWFileManager loadBookWithBookId:bookCD.nid.stringValue volumeId:volumeCD.nid.stringValue]];

            if (bookVO && volumeVO) {
                //设置阅读进度
                {
                    BookCD *bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == NO", bookVO.nid] inContext:[QWFileManager qwContext]];
                    if (!bookCD) {//如果没有阅读过，则创建一个
                        bookCD = [BookCD MR_createEntityInContext:[QWFileManager qwContext]];
                        [bookCD updateWithBookVO:bookVO];
                    }

                    VolumeCD *volumeCD = [VolumeCD MR_findFirstByAttribute:@"nid" withValue:volumeVO.nid inContext:[QWFileManager qwContext]];
                    if (!volumeCD) {
                        volumeCD = [VolumeCD MR_createEntityInContext:[QWFileManager qwContext]];
                        [volumeCD updateWithVolumeVO:volumeVO bookId:bookVO.nid];
                        volumeCD.chapterIndex = @0;
                        volumeCD.location = @0;
                    }

                    [volumeCD setReading];

                    [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];
                }

                //开始阅读
                [[QWReadingManager sharedInstance] startOfflineReadingWithBookId:bookVO.nid volumes:volumes];
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"QWReading" bundle:nil];
                UIViewController *vc = [sb instantiateInitialViewController];
                [self.navigationController pushViewController:vc animated:YES];
            }
            return;
        }

        if (indexPath.row == 0) {
            //没有卷界面
            return ;
        }
        else {
            VolumeList *volumes = [VolumeList new];
            volumes.results = (id)self.volumes;

            VolumeVO *volumeVO = self.volumes[indexPath.section];
            VolumeCD *volumeCD = [VolumeCD MR_findFirstByAttribute:@"nid" withValue:volumeVO.nid inContext:[QWFileManager qwContext]];
            BookVO *bookVO = [BookVO voWithJson:[QWFileManager loadBookWithBookId:bookCD.nid.stringValue volumeId:volumeCD.nid.stringValue]];

            if (bookVO && volumeVO) {
                //设置阅读进度
                {
                    BookCD *bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == NO", bookVO.nid] inContext:[QWFileManager qwContext]];
                    if (!bookCD) {//如果没有阅读过，则创建一个
                        bookCD = [BookCD MR_createEntityInContext:[QWFileManager qwContext]];
                        [bookCD updateWithBookVO:bookVO];
                    }

                    VolumeCD *volumeCD = [VolumeCD MR_findFirstByAttribute:@"nid" withValue:volumeVO.nid inContext:[QWFileManager qwContext]];
                    if (!volumeCD) {
                        volumeCD = [VolumeCD MR_createEntityInContext:[QWFileManager qwContext]];
                        [volumeCD updateWithVolumeVO:volumeVO bookId:bookVO.nid];
                        volumeCD.chapterIndex = @0;
                        volumeCD.location = @0;
                    }

                    VolumeCD *lastReadingVolumeCD = [VolumeCD findLastReadingVolumeWithBookId:bookVO.nid];
                    if (![lastReadingVolumeCD.nid isEqualToNumber:volumeCD.nid]) {
                        volumeCD.chapterIndex = @0;
                        volumeCD.location = @0;
                    }

                    if (lastReadingVolumeCD.chapterIndex.integerValue != indexPath.row - 1) {
                        volumeCD.chapterIndex = @(indexPath.row - 1);
                        volumeCD.location = @0;
                    }

                    [volumeCD setReading];

                    [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];
                }

                //开始阅读
                [[QWReadingManager sharedInstance] startOfflineReadingWithBookId:bookVO.nid volumes:volumes];
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"QWReading" bundle:nil];
                UIViewController *vc = [sb instantiateInitialViewController];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.isEditing) {
        self.indexPathsForSelectedRows = self.tableView.indexPathsForSelectedRows;
    }
}

@end
