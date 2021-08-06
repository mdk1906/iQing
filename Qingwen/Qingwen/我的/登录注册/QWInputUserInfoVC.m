//
//  QWInputUserInfoVC.m
//  Qingwen
//
//  Created by Aimy on 7/14/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWInputUserInfoVC.h"

#import "QWMyCenterLogic.h"

#import <ActionSheetPicker-3.0/ActionSheetPicker.h>

@interface QWInputUserInfoVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) QWMyCenterLogic *logic;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSInteger sex;
@property (nonatomic) NSDate *date;

@end

@implementation QWInputUserInfoVC

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 40;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.date = [NSDate date];
}

- (void)leftBtnClicked:(id)sender
{
    [self cancelAllOperations];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onPressedImageView:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] bk_initWithTitle:@"设置头像"];

    WEAK_SELF;
    [actionSheet bk_addButtonWithTitle:@"拍照" handler:^{
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            STRONG_SELF;
            [self showToastWithTitle:@"该设备没有照相功能" subtitle:nil type:ToastTypeAlert];
            return;
        }

        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = @[(NSString *)kUTTypeImage];
        picker.allowsEditing = YES;//设置可编辑
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [picker setBk_didCancelBlock:^(UIImagePickerController *imagePickerController) {
            [imagePickerController dismissViewControllerAnimated:YES completion:^{
                STRONG_SELF;
                [self setNeedsStatusBarAppearanceUpdate];
            }];
        }];
        [picker setBk_didFinishPickingMediaBlock:^(UIImagePickerController *imagePickerController, NSDictionary *info) {
            STRONG_SELF;
            [self setNeedsStatusBarAppearanceUpdate];
            UIImage *chosenImage = [info objectForKey:UIImagePickerControllerEditedImage];
            [self uploadUserImage:chosenImage];
            [imagePickerController dismissViewControllerAnimated:YES completion:^{
                STRONG_SELF;
                [self setNeedsStatusBarAppearanceUpdate];
            }];
        }];
        [self presentViewController:picker animated:YES completion:nil];
    }];

    [actionSheet bk_addButtonWithTitle:@"从相册选择" handler:^{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = @[(NSString *)kUTTypeImage];
        picker.allowsEditing = YES;//设置可编辑
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [picker setBk_didCancelBlock:^(UIImagePickerController *imagePickerController) {
            [imagePickerController dismissViewControllerAnimated:YES completion:^{
                STRONG_SELF;
                [self setNeedsStatusBarAppearanceUpdate];
            }];
        }];
        [picker setBk_didFinishPickingMediaBlock:^(UIImagePickerController *imagePickerController, NSDictionary *info) {
            STRONG_SELF;
            [self setNeedsStatusBarAppearanceUpdate];
            UIImage *chosenImage = [info objectForKey:UIImagePickerControllerEditedImage];
            [self uploadUserImage:chosenImage];
            [imagePickerController dismissViewControllerAnimated:YES completion:^{
                STRONG_SELF;
                [self setNeedsStatusBarAppearanceUpdate];
            }];
        }];
        [self presentViewController:picker animated:YES completion:nil];
    }];

    [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:^{

    }];

    [actionSheet showInView:self.view];
}

- (void)uploadUserImage:(UIImage *)image
{
    [self showLoading];
    WEAK_SELF;
    [self.logic uploadAvatar:image andCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        [self getData];
        [self hideLoading];
        [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_STATE_CHANGED object:nil];
    }];
}

- (void)getData
{
    WEAK_SELF;
    [self showLoading];
    [self.logic getUserInfoWithCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"data"];
                if (message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:@"获取信息失败" subtitle:nil type:ToastTypeError];
                }
            }
            else {
                self.date = [QWGlobalValue sharedInstance].user.birth_day;
                self.sex = [QWGlobalValue sharedInstance].user.sex.integerValue == 1 ? 1 : 0;
                [self.imageView qw_setImageUrlString:[QWGlobalValue sharedInstance].user.avatar placeholder:[UIImage imageNamed:@"mycenter_logo2"] animation:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_STATE_CHANGED object:nil];
                [self.tableView reloadData];
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }

        [self hideLoading];
    }];
}

- (IBAction)onPressedDoneBtn:(id)sender {
    NSInteger sex = self.sex == 1 ?  1 : 2;
    WEAK_SELF;
    [self showLoading];
    [self.logic updateUserWithSex:sex birthday:self.date andCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"data"];
                if (message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:@"获取信息失败" subtitle:nil type:ToastTypeError];
                }
            }
            else {
                [self leftBtnClicked:sender];
                [self.tableView reloadData];
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }
        
        [self hideLoading];
    }];
}

- (QWMyCenterLogic *)logic
{
    if (!_logic) {
        _logic = [QWMyCenterLogic logicWithOperationManager:self.operationManager];
    }

    return _logic;
}

#pragma mark - tv delegate datasource

- (NSInteger)numberOfSectionsInTableView:(nonnull UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.textLabel.text = @"昵称";
        cell.detailTextLabel.text = [QWGlobalValue sharedInstance].username;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.textLabel.text = @"性别";
        if (self.sex == 0) {
            cell.detailTextLabel.text = @"女";
        }
        else {
            cell.detailTextLabel.text = @"男";
        }

        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.textLabel.text = @"生日";
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
        cell.detailTextLabel.text = [dateFormatter stringFromDate:self.date];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 1 && indexPath.row == 0) {
        WEAK_SELF;
        NSInteger index = self.sex == 1 ?  1 : 2;
        ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"性别" rows:@[@"女", @"男"] initialSelection:index doneBlock:^(ActionSheetStringPicker *stringPicker, NSInteger selectedIndex, id selectedValue) {
            STRONG_SELF;
            self.sex = selectedIndex;
            [self.tableView reloadData];
        } cancelBlock:^(ActionSheetStringPicker *stringPicker) {
            NSLog(@"cancel");
        } origin:cell];
        picker.tapDismissAction = TapActionCancel;
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:nil action:nil];
        cancelBtn.tintColor = QWPINK;
        [picker setCancelButton:cancelBtn];
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStyleDone target:nil action:nil];
        doneBtn.tintColor = QWPINK;
        [picker setDoneButton:doneBtn];
        [picker showActionSheetPicker];
    }
    else if (indexPath.section == 2 && indexPath.row == 0) {
        WEAK_SELF;
        ActionSheetDatePicker *picker = [[ActionSheetDatePicker alloc] initWithTitle:@"生日" datePickerMode:UIDatePickerModeDate selectedDate:self.date doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
            STRONG_SELF;
            self.date = selectedDate;
            [self.tableView reloadData];
        } cancelBlock:^(ActionSheetDatePicker *picker) {
            NSLog(@"cancel");
        } origin:cell];
        picker.tapDismissAction = TapActionCancel;
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:nil action:nil];
        cancelBtn.tintColor = QWPINK;
        [picker setCancelButton:cancelBtn];
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStyleDone target:nil action:nil];
        doneBtn.tintColor = QWPINK;
        [picker setDoneButton:doneBtn];
        [picker showActionSheetPicker];
    }
}

@end
