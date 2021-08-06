//
//  QWReadingDirectoryVC.m
//  Qingwen
//
//  Created by Aimy on 9/23/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWReadingDirectoryVC.h"
#import "QWSubscriberLogic.h"
#import "VolumeCD.h"
#import "QWDetailDirectoryVolumeTVCell.h"
#import "QWDetailDirectoryChapterTVCell.h"
#import "QWTableView.h"
#import "BookContinueReadingCD.h"
#import "QWReadingManager.h"
@interface QWReadingDirectoryVC () <UITableViewDelegate, UITableViewDataSource,QWDetailDirectoryVolumeTVCellDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIView *headView;

@property (nonatomic, strong) BookCD *book;
@property (nonatomic, strong) VolumeVO *volume;
@property (nonatomic, strong) BookVO *bookvo;

@property (nonatomic, strong) QWDetailLogic *logic;

@property (nonatomic, strong) QWSubscriberLogic *subscriberLogic;
@property (strong, nonatomic) NSMutableArray *subscriberList;
@property (nonatomic, strong) VolumeList *volumeList;

@end

@implementation QWReadingDirectoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.navigationController.
    if(!ISIPHONEX){
        
        self.tableView.frame = CGRectMake(0, 100, UISCREEN_WIDTH-50, UISCREEN_HEIGHT-100);
    }
}

- (void)updateWithBook:(BookCD *)book volume:(VolumeVO *)volume volumeList:(VolumeList *)list;
{
    self.book = book;
    self.bookvo = [book toBookVO];
    self.volume = volume;
    self.volumeList = list;
    self.titleLabel.text = self.book.title;
    self.infoLabel.text = [NSString stringWithFormat:@"更新时间：%@", [QWHelper shortDate2ToString:book.updated_time]];
//    [self getSubscriberList];
    [self foldVolume];
//    [self configReadingHistory];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    NSLog(@"self.volumeList.count.integerValue = %@",self.volumeList);
    switch ([QWReadingConfig sharedInstance].readingBG) {
        case QWReadingBGDefault:
            self.tableView.backgroundColor = HRGB(0xF6F6F6);
            self.headView.backgroundColor = HRGB(0xF6F6F6);
            break;
        case QWReadingBGBlack:
            self.tableView.backgroundColor = HRGB(0x1b1b1b);
            self.headView.backgroundColor = HRGB(0x1b1b1b);
            break;
        case QWReadingBGGreen:
            self.tableView.backgroundColor = HRGB(0xceefce);
            self.headView.backgroundColor = HRGB(0xceefce);
            break;
        case QWReadingBGPink:
            self.tableView.backgroundColor = HRGB(0xfcdfe7);
            self.headView.backgroundColor = HRGB(0xfcdfe7);
            break;
        default:
            break;
    }
    
    [self.tableView reloadData];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (QWDetailLogic *)logic
{
    if (!_logic) {
        _logic = [QWDetailLogic logicWithOperationManager:self.operationManager];
    }
    
    return _logic;
}

- (QWSubscriberLogic *)subscriberLogic {
    if ((!_subscriberLogic)) {
        _subscriberLogic = [QWSubscriberLogic logicWithOperationManager:self.operationManager];
    }
    return _subscriberLogic;
}

- (void)configReadingHistory
{
    BookContinueReadingCD *readingCD = [BookContinueReadingCD MR_findFirstByAttribute:@"bookId" withValue:self.bookvo.nid inContext:[QWFileManager qwContext]];
    if (readingCD) {
        VolumeVO *volumeVO = self.logic.volumeList.results[readingCD.volumeIndex.integerValue];
        VolumeCD *volumeCD = [VolumeCD MR_findFirstByAttribute:@"nid" withValue:volumeVO.nid inContext:[QWFileManager qwContext]];
        if (!volumeCD) {
            volumeCD = [VolumeCD MR_createEntityInContext:[QWFileManager qwContext]];
            [volumeCD updateWithVolumeVO:volumeVO bookId:self.bookvo.nid];
        }
        
        volumeCD.chapterIndex = readingCD.chapterIndex;
        volumeCD.location = readingCD.location;
        [volumeCD setReading];
        
        [readingCD MR_deleteEntityInContext:[QWFileManager qwContext]];
        [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];
    }
}
- (void)getSubscriberList{
    _subscriberList = [NSMutableArray array];
    WEAK_SELF;
    if ([QWGlobalValue sharedInstance].isLogin) {
        self.subscriberList = @[].mutableCopy;
        [self.subscriberLogic getSubscriberChaptersWithBookId:self.bookvo.nid andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            STRONG_SELF;
            [self.subscriberLogic.subscriberList.results enumerateObjectsUsingBlock:^(SubscriberVO*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.subscriberList addObject:obj.chapter];
            }];
            [self.tableView reloadData];
        }];
    }
}

- (void)foldVolume {
    WEAK_SELF;
    [self.logic.volumeList.results enumerateObjectsUsingBlock:^(VolumeVO * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        STRONG_SELF;
        if (idx == 0) {
            obj.isFlod = false;
        }
        else {
            obj.isFlod = true;
        }
        [self.tableView reloadData];
    }];
    //}
}
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return self.volume.chapter.count;
////    VolumeVO *volume = self.volume;
////    if (volume.isFlod && self.tableView.isEditing == false) {
////        return 1;
////    }
////    else {
////        //        if(volume.isFlod && self.tableView.isEditing == true){
////        //            return 1;
////        //        }
////        return volume.chapter.count + 1;
////    }
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
//    ChapterVO *chapter = self.volume.chapter[indexPath.row];
//    cell.textLabel.text = chapter.title;
//
//    VolumeCD *volumeCD = [VolumeCD MR_findFirstByAttribute:@"nid" withValue:self.volume.nid inContext:[QWFileManager qwContext]];
//
//    if (volumeCD.read && volumeCD.chapterIndex.integerValue == indexPath.row) {
//        cell.textLabel.textColor = QWPINK;
//    }
//    else {
//        cell.textLabel.textColor = [UIColor color50];
//    }
//
//    return cell;
//}
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [self.delegate directoryVC:self didClickChapterAtIndex:indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        //没有卷界面
        VolumeVO *volume = self.volumeList.results[indexPath.section];
        volume.isFlod = !volume.isFlod;
        volume.collection = self.bookvo.collection;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    }else {
        [self.delegate directoryVC:self didClickChapterAtIndex:indexPath volumes:self.volumeList Book:self.bookvo];
    }
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([QWReadingManager sharedInstance].offline == true) {
        return self.volumeList.results.count;
    }else{
       return self.volumeList.count.integerValue;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    VolumeVO *volume = self.volumeList.results[section];
    if (volume.isFlod && self.tableView.isEditing == false) {
        return 1;
    }
    else {
        //        if(volume.isFlod && self.tableView.isEditing == true){
        //            return 1;
        //        }
        return volume.chapter.count + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        QWDetailDirectoryVolumeTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"readvolume" forIndexPath:indexPath];
        cell.delegate = self;
        VolumeVO *volume = self.volumeList.results[indexPath.section];
        
        [cell updateWithBookVO:self.bookvo volume:volume];
        switch ([QWReadingConfig sharedInstance].readingBG) {
            case QWReadingBGDefault:
                cell.titleLabhh.textColor = HRGB(0x989898);
                cell.contentView.backgroundColor = HRGB(0xf6f6f6);
                break;
            case QWReadingBGBlack:
                cell.titleLabhh.textColor = HRGB(0x989898);
                cell.contentView.backgroundColor = HRGB(0x1b1b1b);
                break;
            case QWReadingBGGreen:
                cell.titleLabhh.textColor = HRGB(0x989898);
                cell.contentView.backgroundColor = HRGB(0xceefce);
                break;
            case QWReadingBGPink:
                cell.titleLabhh.textColor = HRGB(0x989898);
                cell.contentView.backgroundColor = HRGB(0xfbdee6);
                break;
            default:
                break;
        }
        return cell;
    }
    else {
        
        QWDetailDirectoryChapterTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"readcell" forIndexPath:indexPath];
        VolumeVO *volume = self.volumeList.results[indexPath.section];
        ChapterVO *chapter = volume.chapter[indexPath.row - 1];
//        chapter.type = 0;
        chapter.collection = self.bookvo.collection;
//        chapter.subscriber = [_subscriberList containsObject:chapter.nid];
//        cell.lockStateBtn.isHidden = YES;
        VolumeCD *volumeCD = [VolumeCD findLastReadingVolumeWithBookId:self.bookvo.nid];
        [cell updateBookVO:self.bookvo volumeId:volume.nid.stringValue];
        if ([volumeCD.nid isEqualToNumber:volume.nid] && volumeCD.chapterIndex.integerValue == indexPath.row - 1) {
            [cell updateChapterVO:chapter isContinueReading:true];
        }
        else {
            [cell updateChapterVO:chapter isContinueReading:false];
        }
        
        switch ([QWReadingConfig sharedInstance].readingBG) {
            case QWReadingBGDefault:
                cell.titleLabhh.textColor = HRGB(0x353535);
                cell.contentView.backgroundColor = HRGB(0xffffff);
                break;
            case QWReadingBGBlack:
                cell.titleLabhh.textColor = HRGB(0x353535);
                cell.contentView.backgroundColor = HRGB(0x272626);
                break;
            case QWReadingBGGreen:
                cell.titleLabhh.textColor = HRGB(0x008200);
                cell.contentView.backgroundColor = HRGB(0xe6fae6);
                break;
            case QWReadingBGPink:
                cell.titleLabhh.textColor = HRGB(0xff8e9b);
                cell.contentView.backgroundColor = HRGB(0xfff0f4);
                break;
            default:
                break;
        }
        return cell;
    }
}

- (IBAction)onPressedBg:(id)sender {
    [self.delegate hideDirectoryVC:self];
}
#pragma mark QWDetailDirectoryVolumeTVCellDelegate

- (void)volumeCell:(QWDetailDirectoryVolumeTVCell *)cell didClickedFoldBtn:(UIButton *)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    VolumeVO *volume = self.volumeList.results[indexPath.section];
    volume.isFlod = sender.isSelected;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
}
@end
