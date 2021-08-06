//
//  QWUserDetailVC.m
//  Qingwen
//
//  Created by Aimy on 7/2/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWUserVC.h"

#import "QWMyCenterLogic.h"
#import <NYXImagesKit.h>
#import <ActionSheetPicker-3.0/ActionSheetPicker.h>
#import "QWShareManager.h"
#import "QWAuthenticationView.h"
#import "QWMyLevelVC.h"
#import "QWMymedelVC.h"
@interface QWUserVC () <PECropViewControllerDelegate,QWQQLoginDelegate, QWWXLoginDelegate, QWWBLoginDelegate>

@property (nonatomic, strong) QWMyCenterLogic *logic;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *medalImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageTop;

@property (strong, nonatomic) IBOutlet UIButton *logoutBtn;

@property (nonatomic) NSInteger sex;
@property (nonatomic) NSDate *date;

@property (strong,nonatomic) UIImageView *XheadView;
@property (strong,nonatomic) UIImageView *XmedalImageView;
@end

@implementation QWUserVC

+ (void)load
{
    QWMappingVO *vo = [QWMappingVO new];
    vo.className = [NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject;
    vo.storyboardName = @"QWUser";
    [[QWRouter sharedInstance] registerRouterVO:vo withKey:@"myself"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [QWGlobalValue sharedInstance].nid.stringValue;

    self.imageView.layer.masksToBounds = YES;

    self.imageView.layer.cornerRadius = [QWSize getLengthWithSizeType:QWSizeType4_0 andLength:50];
    self.imageTop.constant = [QWSize getLengthWithSizeType:QWSizeType4_0 andLength:30];
    self.imageWidth.constant = [QWSize getLengthWithSizeType:QWSizeType4_0 andLength:100];
    
    if (ISIPHONEX) {
        UIView *headview = [UIView new];
        headview.frame = CGRectMake(0, 0, UISCREEN_WIDTH, 170);
        headview.backgroundColor = UIColor.clearColor;
        self.tableView.tableHeaderView = headview;
        
        _XheadView = [UIImageView new];
        _XheadView.frame = CGRectMake((UISCREEN_WIDTH-100)/2, 20, 100, 100);
        _XheadView.userInteractionEnabled = YES;
        _XheadView.layer.masksToBounds = YES;
        _XheadView.layer.cornerRadius = 50;
        [headview addSubview:_XheadView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPressedImageView:)];
        [_XheadView addGestureRecognizer:tap];
        
        _XmedalImageView = [UIImageView new];
        _XmedalImageView.frame = CGRectMake((UISCREEN_WIDTH-100)/2, 20+100-31, 100, 31);
        [headview addSubview:_XmedalImageView];
    }
    else{
        CGRect frame = self.headerView.frame;
        frame.size.height = [QWSize getLengthWithSizeType:QWSizeType4_0 andLength:170];
        self.headerView.frame = frame;
    }
    
    self.date = [QWGlobalValue sharedInstance].user.birth_day;
    self.sex = [QWGlobalValue sharedInstance].user.sex.integerValue == 1 ? 1 : 0;

    if (IS_IPAD_DEVICE) {
        [self.imageView qw_setImageUrlString:[QWConvertImageString convertPicURL:[QWGlobalValue sharedInstance].user.avatar imageSizeType:QWImageSizeTypeCover] placeholder:[UIImage imageNamed:@"mycenter_logo2"] animation:YES];
        [self.XheadView qw_setImageUrlString:[QWConvertImageString convertPicURL:[QWGlobalValue sharedInstance].user.avatar imageSizeType:QWImageSizeTypeCover] placeholder:[UIImage imageNamed:@"mycenter_logo2"] animation:YES];
        [self.medalImageView qw_setImageUrlString:[QWGlobalValue sharedInstance].user.adorn_medal placeholder:nil animation:nil];
        [self.XmedalImageView qw_setImageUrlString:[QWGlobalValue sharedInstance].user.adorn_medal placeholder:nil animation:nil];
    }
    else {
        [self.imageView qw_setImageUrlString:[QWConvertImageString convertPicURL:[QWGlobalValue sharedInstance].user.avatar imageSizeType:QWImageSizeTypeAvatar] placeholder:[UIImage imageNamed:@"mycenter_logo2"] animation:YES];
        [self.XheadView qw_setImageUrlString:[QWConvertImageString convertPicURL:[QWGlobalValue sharedInstance].user.avatar imageSizeType:QWImageSizeTypeAvatar] placeholder:[UIImage imageNamed:@"mycenter_logo2"] animation:YES];
        [self.medalImageView qw_setImageUrlString:[QWGlobalValue sharedInstance].user.adorn_medal placeholder:nil animation:nil];
        [self.XmedalImageView qw_setImageUrlString:[QWGlobalValue sharedInstance].user.adorn_medal placeholder:nil animation:nil];
    }
    
    if (self.extraData) {
        if ([self.extraData objectForKey:@"bind_phone"]) {
           [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"bindphone" andParams:nil]];
        }
    }
    WEAK_SELF;
    [self observeNotification:BINDING_CHANGED withBlock:^(id self, NSNotification *notification) {
        if (!notification) {
            return ;
        }
        
        KVO_STRONG_SELF;
        [kvoSelf.tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (QWMyCenterLogic *)logic
{
    if (!_logic) {
        _logic = [QWMyCenterLogic logicWithOperationManager:self.operationManager];
    }

    return _logic;
}

- (void)getData:(BOOL)force
{
    //预防没有获取到url导致无法获取到信息的问题
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWGlobalValue sharedInstance] clear];
        [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_STATE_CHANGED object:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return ;
    }

    if (!force && [QWGlobalValue sharedInstance].user.sex) {
        return;
    }

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
                
                if (ISIPHONEX) {
                    [self.XheadView qw_setImageUrlString:[QWGlobalValue sharedInstance].user.avatar placeholder:[UIImage imageNamed:@"mycenter_logo2"] animation:YES];
                }
                else{
                    [self.imageView qw_setImageUrlString:[QWGlobalValue sharedInstance].user.avatar placeholder:[UIImage imageNamed:@"mycenter_logo2"] animation:YES];
                }
                [self.tableView reloadData];
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }
        
        [self hideLoading];
    }];
    [self.logic getAchievementInfoWithCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        
    }];
}

- (void)getBindList {
    if (![QWGlobalValue sharedInstance].isLogin) {
        [[QWGlobalValue sharedInstance] clear];
        return;
    }
    [[QWBindingValue sharedInstance] update];
}
-(void)XheadTouch{
    
}
- (IBAction)onPressedImageView:(UITapGestureRecognizer *)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] bk_initWithTitle:@"设置头像"];

    WEAK_SELF;
    [actionSheet bk_addButtonWithTitle:@"拍照" handler:^{
        STRONG_SELF;
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [self showToastWithTitle:@"该设备没有照相功能" subtitle:nil type:ToastTypeAlert];
            return;
        }

        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = @[(NSString *)kUTTypeImage];
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
            UIImage *chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
            [imagePickerController dismissViewControllerAnimated:YES completion:^{
                STRONG_SELF;
                [self setNeedsStatusBarAppearanceUpdate];
                [self editUserImage:chosenImage];
            }];
        }];

        [self performInMainThreadBlock:^{
            STRONG_SELF;
            [self presentViewController:picker animated:YES completion:nil];
        } afterSecond:.1f];
    }];

    [actionSheet bk_addButtonWithTitle:@"从相册选择" handler:^{
        STRONG_SELF;
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = @[(NSString *)kUTTypeImage];
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
            UIImage *chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
            [imagePickerController dismissViewControllerAnimated:YES completion:^{
                STRONG_SELF;
                [self setNeedsStatusBarAppearanceUpdate];
                [self editUserImage:chosenImage];
            }];
        }];

        [self performInMainThreadBlock:^{
            STRONG_SELF;
            [self presentViewController:picker animated:YES completion:nil];
        } afterSecond:.1f];
    }];

    [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:^{

    }];

    [actionSheet showInView:sender.view];
}

- (void)editUserImage:(UIImage *)image {
    PECropViewController *vc = [PECropViewController new];
    vc.delegate = self;
    vc.image = image;
    vc.toolbarHidden = YES;
    vc.cropAspectRatio = 1;
    vc.keepingCropAspectRatio = YES;

    QWBaseNC *nc = [[QWBaseNC alloc] initWithRootViewController:vc];
    [self presentViewController:nc animated:YES completion:nil];
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self uploadUserImage:croppedImage];
}

- (void)uploadUserImage:(UIImage *)image
{
    [self showLoading];
    WEAK_SELF;
    [self performInThreadBlock:^{
        UIImage *scaleImage = [image scaleToSize:CGSizeMake(384, 384)];
        STRONG_SELF;
        [self performInMainThreadBlock:^{
            STRONG_SELF;
            [self.logic uploadAvatar:scaleImage andCompleteBlock:^(id aResponseObject, NSError *anError) {
                STRONG_SELF;
                if (!anError) {
                    NSNumber *code = aResponseObject[@"code"];
                    if (code && ! [code isEqualToNumber:@0]) {//有错误
                        NSString *message = aResponseObject[@"data"];
                        if (message.length) {
                            [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                        }
                        else {
                            [self showToastWithTitle:@"上传图片失败" subtitle:nil type:ToastTypeError];
                        }
                    }
                    else {
                        [QWGlobalValue sharedInstance].user.avatar = aResponseObject[@"avatar"];
                        [[QWGlobalValue sharedInstance] save];
                        [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_STATE_CHANGED object:nil];
                        [self showToastWithTitle:@"修改成功" subtitle:nil type:ToastTypeError];
                        [self getData:YES];
                    }
                }
                else {
                    [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
                }
                
                [self hideLoading];
            }];
        }];
    }];
}

- (IBAction)onPressedLogoutBtn:(id)sender
{
    [self.logic logout];

    [[QWGlobalValue sharedInstance] clear];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_STATE_CHANGED object:nil];
    
    
}

- (IBAction)birthdayChange:(UIDatePicker *)sender {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    cell.detailTextLabel.text = [dateFormatter stringFromDate:sender.date];
    self.date = sender.date;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - tv delegate datasource

- (NSInteger)numberOfSectionsInTableView:(nonnull UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 5;
    }
    else if (section == 1) {
        return 3;
    }
    else {
        return 3;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_WIDTH, 20)];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = HRGB(0x505050);
    if (section == 0) {
        label.text = @"   个人信息";
    }
    else if (section == 1) {
        label.text = @"   账户绑定";
    }
    else if (section == 2) {
        label.text = @"   实名登记";
    }
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 3) {
        return 66;
    }
    return 44;
}

- (UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2" forIndexPath:indexPath];
            cell.textLabel.text = @"昵称";
            cell.detailTextLabel.text = [QWGlobalValue sharedInstance].username;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
            return cell;
        }
        else if (indexPath.row == 1) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2" forIndexPath:indexPath];
            cell.textLabel.text = @"等级";
            cell.detailTextLabel.text = [QWGlobalValue sharedInstance].user.level;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
            return cell;
        }
        else if (indexPath.row == 2) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_down"]];
            cell.textLabel.text = @"性别";
            if (self.sex == 1) {
                cell.detailTextLabel.text = @"男";
            }
            else {
                cell.detailTextLabel.text = @"女";
            }

            return cell;
        }
        else if (indexPath.row == 3) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_down"]];
            cell.textLabel.text = @"生日";
            if (self.date) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
                cell.detailTextLabel.text = [dateFormatter stringFromDate:self.date];
            }
            else {
                cell.detailTextLabel.text = @"";
            }

            return cell;
        }
        else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
            cell.textLabel.text = @"签名";
            [cell.textLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:cell.contentView withOffset:15];
            [cell.textLabel autoSetDimension:ALDimensionHeight toSize:66];
            cell.detailTextLabel.numberOfLines = 2;
            cell.detailTextLabel.text = [QWGlobalValue sharedInstance].user.signature;

            return cell;
        }
    }
    else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2" forIndexPath:indexPath];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];

        if (indexPath.row == 0) {
            cell.textLabel.text = @"QQ";
            cell.detailTextLabel.text = @"";
            if ([QWBindingValue sharedInstance].qq.binding.boolValue) {
                cell.detailTextLabel.text = @"已绑定";
                cell.detailTextLabel.textColor = [UIColor colorQWPinkDark];
            }else {
                cell.detailTextLabel.text = @"未绑定";
                cell.detailTextLabel.textColor = [UIColor color84];
            }
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"微信";
            if ([QWBindingValue sharedInstance].wx.binding.boolValue) {
                cell.detailTextLabel.text = @"已绑定";
                cell.detailTextLabel.textColor = [UIColor colorQWPinkDark];
            }else {
                cell.detailTextLabel.text = @"未绑定";
                cell.detailTextLabel.textColor = [UIColor color84];
            }
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = @"微博";
            if ([QWBindingValue sharedInstance].sina.binding.boolValue) {
                cell.detailTextLabel.text = @"已绑定";
                cell.detailTextLabel.textColor = [UIColor colorQWPinkDark];
            }else {
                cell.detailTextLabel.text = @"未绑定";
                cell.detailTextLabel.textColor = [UIColor color84];
            }        }
        return cell;
    }
    else if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2" forIndexPath:indexPath];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"手机号码";
            if ([QWBindingValue sharedInstance].bindPhone.binding.boolValue) {
                cell.detailTextLabel.text = [QWBindingValue sharedInstance].bindPhone.nickname;
                cell.detailTextLabel.textColor = [UIColor colorQWPinkDark];
            }else {
                cell.detailTextLabel.text = @"未绑定";
                cell.detailTextLabel.textColor = [UIColor color84];
            }
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"实名信息";
            if ([QWBindingValue sharedInstance].autor.binding.boolValue) {
                cell.detailTextLabel.text = @"已绑定";
                cell.detailTextLabel.textColor = [UIColor colorQWPinkDark];
            }else {
                cell.detailTextLabel.text = @"";
                cell.detailTextLabel.textColor = [UIColor color84];
            }
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = @"密码修改";
            cell.detailTextLabel.text = @"";
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
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            if ([[QWGlobalValue sharedInstance].update_username isEqualToNumber:[NSNumber numberWithInt:1]]) {
                [self performSegueWithIdentifier:@"nName" sender:self];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您已不能修改昵称" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                [alert show];
                
                //添加延迟时间为1.0秒 然后执行dismiss:方法
                [self performSelector:@selector(dismiss:) withObject:alert afterDelay:3.0];
            }
            
        }
        if (indexPath.row == 1) {
            QWMyLevelVC *vc = [[QWMyLevelVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];

        }
        if (indexPath.row == 2) {
            WEAK_SELF;
            NSInteger index = self.sex == 1 ?  1 : 2;
            ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"性别" rows:@[@"女", @"男"] initialSelection:index doneBlock:^(ActionSheetStringPicker *stringPicker, NSInteger selectedIndex, id selectedValue) {
                STRONG_SELF;
                [self showLoading];
                self.sex = selectedIndex;
                [self.tableView reloadData];
                NSInteger sex = self.sex == 1 ?  1 : 2;
                [self.logic updateUserWithSex:sex birthday:self.date andCompleteBlock:^(id aResponseObject, NSError *anError) {
                    STRONG_SELF;
                    if (!anError) {
                        NSNumber *code = aResponseObject[@"code"];
                        if (code) {//有错误
                            if ([code isEqualToNumber:@-1]) {
                                [self showToastWithTitle:@"发送失败" subtitle:nil type:ToastTypeError];
                            }
                            else {
                                NSString *message = aResponseObject[@"data"];
                                if (message.length) {
                                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                                }
                                else {
                                    [self showToastWithTitle:@"发送失败" subtitle:nil type:ToastTypeError];
                                }
                            }
                        }
                        else {
                            UserVO *user = [UserVO voWithDict:aResponseObject];
                            [QWGlobalValue sharedInstance].user = user;
                            [[QWGlobalValue sharedInstance] save];
                            [self showToastWithTitle:@"修改成功" subtitle:nil type:ToastTypeError];
                            [self.tableView reloadData];
                        }
                    }
                    else {
                        [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
                    }
                    
                    [self hideLoading];
                }];
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
        else if (indexPath.row == 3) {
            WEAK_SELF;
            ActionSheetDatePicker *picker = [[ActionSheetDatePicker alloc] initWithTitle:@"生日" datePickerMode:UIDatePickerModeDate selectedDate:self.date doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
                STRONG_SELF;
                self.date = selectedDate;
                [self.tableView reloadData];
                [self showLoading];
                NSInteger sex = self.sex == 1 ?  1 : 2;
                [self.logic updateUserWithSex:sex birthday:self.date andCompleteBlock:^(id aResponseObject, NSError *anError) {
                    STRONG_SELF;
                    if (!anError) {
                        NSNumber *code = aResponseObject[@"code"];
                        if (code) {//有错误
                            if ([code isEqualToNumber:@-1]) {
                                [self showToastWithTitle:@"发送失败" subtitle:nil type:ToastTypeError];
                            }
                            else {
                                NSString *message = aResponseObject[@"data"];
                                if (message.length) {
                                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                                }
                                else {
                                    [self showToastWithTitle:@"发送失败" subtitle:nil type:ToastTypeError];
                                }
                            }
                        }
                        else {
                            UserVO *user = [UserVO voWithDict:aResponseObject];
                            [QWGlobalValue sharedInstance].user = user;
                            [[QWGlobalValue sharedInstance] save];
                            [self showToastWithTitle:@"修改成功" subtitle:nil type:ToastTypeError];
                            [self.tableView reloadData];
                        }
                    }
                    else {
                        [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
                    }
                    
                    [self hideLoading];
                }];
            } cancelBlock:^(ActionSheetDatePicker *picker) {
                NSLog(@"cancel");
            } origin:cell];
            picker.tapDismissAction = TapActionCancel;
            UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:nil action:nil];
            cancelBtn.tintColor = QWPINK;
            [picker setCancelButton:cancelBtn];
            UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStyleDone target:nil action:nil];
            doneBtn.tintColor = QWPINK;
            picker.minimumDate = [NSDate dateWithTimeIntervalSince1970:0];
            picker.maximumDate = [NSDate date];
            [picker setDoneButton:doneBtn];
            [picker showActionSheetPicker];
        }
        else if (indexPath.row == 4) {
            [self performSegueWithIdentifier:@"signature" sender:self];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) { // QQ
            BindingVO *vo = [QWBindingValue sharedInstance].qq;
            if (vo.binding.boolValue) {
                [self cancelBoundThirdWithState:vo.channel name:vo.name];
            }
            else {
                [[QWShareManager sharedInstance] qqLogin];
                [QWShareManager sharedInstance].qqLoginDelegate = self;
            }
        }
        else if (indexPath.row == 1) {
            BindingVO *vo = [QWBindingValue sharedInstance].wx;
            if (vo.binding.boolValue) {
                [self cancelBoundThirdWithState:vo.channel name:vo.name];
            }
            else {
                [[QWShareManager sharedInstance] wxLogin];
                [QWShareManager sharedInstance].wxLoginDelegate = self;
            }
        }
        else if (indexPath.row == 2) {
            BindingVO *vo = [QWBindingValue sharedInstance].sina;
            if (vo.binding.boolValue) {
                [self cancelBoundThirdWithState:vo.channel name: vo.name];
            }
            else {
                [[QWShareManager sharedInstance] wbLogin];
                [QWShareManager sharedInstance].wbLoginDelegate = self;
            }
        }
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            BindingVO *vo = [QWBindingValue sharedInstance].bindPhone;
            if (vo && vo.binding.boolValue) {
                UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"" message:@"要换绑手机账号吗？"];
                [alert bk_addButtonWithTitle:@"取消" handler:^{
                    
                }];
                [alert bk_addButtonWithTitle:@"确定" handler:^{
                    [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"replacebind" andParams:nil]];
                }];
                [alert show];
            }
            else {
                [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"bindphone" andParams:nil]];
            }
        }
        else if (indexPath.row == 1) {
            if ([QWBindingValue sharedInstance].isAuthentication) {
                UITabBarController *tbc = (id)[[UIApplication sharedApplication].delegate window].rootViewController;
                QWAuthenticationView *authenView = [QWAuthenticationView createWithNib];
                [tbc.view addSubview:authenView];
                [authenView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:tbc.view];
                [authenView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:tbc.view];
                [authenView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:tbc.view];
                [authenView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:tbc.view];
                [authenView showWithAuthor:self.logic.authorVO];
            }
            else {
                [self showToastWithTitle:@"你还未签约呢=-=" subtitle:nil type:ToastTypeError];
            }
        }
        else if (indexPath.row == 2) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"QWLogin" bundle:nil];
            UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"password"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)cancelBoundThirdWithState:(NSString *)state name:(NSString *)name {
    UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:nil message:@"是否解除绑定"];
    [alert bk_addButtonWithTitle:@"取消" handler:^{
        
    }];
    WEAK_SELF;
    [alert bk_addButtonWithTitle:@"确定" handler:^{
        STRONG_SELF;
        [self showLoading];
        [self.logic cancelBoundWithThirdState:state andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            STRONG_SELF;
            if (!anError) {
                NSNumber *code = aResponseObject[@"code"];
                if (code && ! [code isEqualToNumber:@0]) {//有错误
                    NSString *message = aResponseObject[@"msg"];
                    if (message.length) {
                        [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                    }
                    else {
                        [self showToastWithTitle:@"解绑失败" subtitle:nil type:ToastTypeError];
                    }
                }
                else {
                    [self getBindList];
                }
            }
            else {
                [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
            }
            
            [self hideLoading];
        }];
    }];
    [alert show];
}

#pragma mark - 第三方绑定
- (void)loginQQSuccessWithJsonResponse:(NSDictionary *)jsonResponse {
    
    void (^boundQQ)(NSDictionary *jsonResponse) = ^(NSDictionary *dic){
        [self showLoading];
        [self.logic boundWithQQJsonResponse:dic check:false andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            if (!anError) {
                NSNumber *code = aResponseObject[@"code"];
                if (code && ! [code isEqualToNumber:@0]) {//有错误
                    NSString *message = aResponseObject[@"msg"];
                    if (message.length) {
                        [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                    }
                    else {
                        [self showToastWithTitle:@"绑定QQ失败" subtitle:nil type:ToastTypeError];
                    }
                }
                else {
                    [self getBindList];
                }
            }
            else {
                [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
            }
            [self hideLoading];
        }];
    };
    
    [self showLoading];
    WEAK_SELF;
    [self.logic boundWithQQJsonResponse:jsonResponse check:true andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"msg"];
                if ([code isEqualToNumber:@(-1)]) {
                    UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"" message:message];
                    [alert bk_addButtonWithTitle:@"取消" handler:^{
                        
                    }];
                    [alert bk_addButtonWithTitle:@"确定" handler:^{
                        STRONG_SELF;
                        boundQQ(jsonResponse);
                    }];
                    [alert show];
                }
                else {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
            }
            else {
                boundQQ(jsonResponse);
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }
        
        [self hideLoading];
    }];
    

}

- (void)loginWXSuccessWithCode:(NSString *)code {
    
    [self showLoading];
    WEAK_SELF;
    [self.logic boundWithWXCode:code check:false andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (!anError) {
            NSNumber *codeNum = aResponseObject[@"code"];
            if (codeNum && ! [codeNum isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"msg"];
                if (message.length) {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
                else {
                    [self showToastWithTitle:@"绑定失败" subtitle:nil type:ToastTypeError];
                }
            }
            else {
                [self getBindList];
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }
        
        [self hideLoading];
    }];
    
}

- (void)loginWBSuccessWithJsonResponse:(NSDictionary *)jsonResponse {
    
    void (^boundWB)(NSDictionary *jsonResponse) = [^(NSDictionary * jsonResponse){
        [self showLoading];
        [self.logic boundWithWbJsonResponse:jsonResponse check:false andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            if (!anError) {
                NSNumber *code = aResponseObject[@"code"];
                if (code && ! [code isEqualToNumber:@0]) {//有错误
                    NSString *message = aResponseObject[@"msg"];
                    if (message.length) {
                        [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                    }
                    else {
                        [self showToastWithTitle:@"绑定微博失败" subtitle:nil type:ToastTypeError];
                    }
                }
                else {
                    [self getBindList];
                }
            }
            else {
                [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
            }
            [self hideLoading];
        }];
    } copy];
    
    [self showLoading];
    WEAK_SELF;
    [self.logic boundWithWbJsonResponse:jsonResponse check:true andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        STRONG_SELF;
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                NSString *message = aResponseObject[@"msg"];
                if ([code isEqualToNumber:@(-1)]) {
                    NSString *message = aResponseObject[@"msg"];
                    UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"" message:message];
                    [alert bk_addButtonWithTitle:@"取消" handler:^{
                    }];
                    [alert bk_addButtonWithTitle:@"确定" handler:^{
                        STRONG_SELF;
                        boundWB(jsonResponse);
                    }];
                    [alert show];
                }
                else {
                    [self showToastWithTitle:message subtitle:nil type:ToastTypeError];
                }
            }
            else {
                boundWB(jsonResponse);
            }
        }
        else {
            [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
        }
        
        [self hideLoading];
    }];
}
#pragma mark - 系统弹框自动消失
- (void)dismiss:(UIAlertView *)alert
{
    //此处相当于3秒之后自动点了cancel按钮
    [alert dismissWithClickedButtonIndex:[alert cancelButtonIndex] animated:YES];
}
@end
