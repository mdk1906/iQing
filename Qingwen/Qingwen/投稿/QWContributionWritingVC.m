//
//  QWContributionWritingVC.m
//  Qingwen
//
//  Created by Aimy on 8/5/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWContributionWritingVC.h"

#import "QWContributionLogic.h"
#import "QWContributionInputAccessoryView.h"
#import "QWPictureVC.h"
#import <YYText.h>
#import "QWContributionImageView.h"
#import "QWHelper.h"
#import "QWContributionSubmitView.h"

@interface QWContributionWritingVC () <UITextFieldDelegate, YYTextViewDelegate, QWContributionInputAccessoryViewDelegate, QWContributionSubmitViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UITextField *chapterTF;
@property (strong, nonatomic) IBOutlet YYTextView *contentTV;
@property (weak, nonatomic) IBOutlet UITextField *authorWordTF;

@property (nonatomic, strong) QWContributionLogic *logic;

@property (nonatomic, strong) QWContributionInputAccessoryView *myInputAccessoryView;
@property (nonatomic, strong) QWContributionSubmitView *mySubmitView;

@property (nonatomic) BOOL modifiedTitle;
@property (nonatomic) BOOL modifiedContent;

@property (nonatomic, strong) KeyboardMan *keyboardMan;

@property (nonatomic) NSRange range;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBtn;

@property (nonatomic, assign) BOOL isCopying; //副本
@property (nonatomic, strong) ChapterVO *orginChapter;

//@property (nonatomic, assign) BOOL isSaved; //已经保存过 为了防止发布或新章节发布以后返回来修改
@end

@implementation QWContributionWritingVC


- (void)awakeFromNib
{
    [super awakeFromNib];

    self.contentTV.delegate = self;
    self.contentTV.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
    self.contentTV.font = [UIFont systemFontOfSize:15.f];
    self.contentTV.placeholderText = @"开始脑洞吧！٩(๑òωó๑)۶";
    self.contentTV.placeholderTextColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0980392 alpha:0.22];
    self.keyboardMan = [KeyboardMan new];

//    WEAK_SELF;
//    [self.keyboardMan setAnimateWhenKeyboardAppear:^(NSInteger appearPostIndex, CGFloat keyboardHeight, CGFloat keyboardHeightIncrement) {
//        STRONG_SELF;
//        UIEdgeInsets inset = self.contentTV.contentInset;
//        inset.bottom = keyboardHeight + inset.top - 64;
//        self.contentTV.contentInset = inset;
//    }];
//
//    [self.keyboardMan setAnimateWhenKeyboardDisappear:^(CGFloat keyboardHeight) {
//        STRONG_SELF;
//        UIEdgeInsets inset = self.contentTV.contentInset;
//        inset.bottom = inset.top;
//        self.contentTV.contentInset = inset;
//    }];

    self.myInputAccessoryView = [QWContributionInputAccessoryView createWithNib];
    self.myInputAccessoryView.delegate = self;
    self.chapterTF.inputAccessoryView = self.myInputAccessoryView;
    self.contentTV.inputAccessoryView = self.myInputAccessoryView;
    self.authorWordTF.inputAccessoryView = self.myInputAccessoryView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.scrollView addSubview:self.contentView];
    if (ISIPHONEX) {
        self.scrollView.contentInset = UIEdgeInsetsMake(88, 0, 0, 0);
    }
    else{
        self.scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    }
    
    [self resize:CGSizeMake(UISCREEN_WIDTH, UISCREEN_HEIGHT)];
    self.contentTV.delaysContentTouches = NO;
    if (self.chapter) {
        if (self.draft) {
            self.title = @"修改草稿";
        }
        else {
            self.title = self.chapter.title;
            self.isCopying = true;
            self.orginChapter = self.chapter;
        }
        self.chapterTF.text = self.chapter.title;
        if ([self.chapter.whisper isEqualToString:@""]) {
            
        }
        else{
            self.authorWordTF.text = self.chapter.whisper;
        }
        
        [self getData];
    }
    else {
        self.title = @"创建草稿";
    }
    
}

- (void)resize:(CGSize)size
{
    self.scrollView.contentSize = CGSizeMake(size.width, size.height);
    CGRect frame = self.contentView.frame;
    frame.size.width = size.width;
    frame.size.height = size.height - 64;
    self.contentView.frame = frame;
    END_EDITING;
}

- (QWContributionLogic *)logic
{
    if (!_logic) {
        _logic = [QWContributionLogic logicWithOperationManager:self.operationManager];
        _logic.volume = self.volume;
        _logic.book = self.volume.book;
        _logic.chapter = self.chapter;
    }
    return _logic;
}

- (void)getData
{
    WEAK_SELF;
    [self showLoading];
    [self.logic getContentWithCompleteBlock:^(id aResponseObject, NSError *anError) {
        STRONG_SELF;
        self.contentTV.attributedText = self.logic.originContent;
        self.modifiedContent = NO;
        if (self.contentTV.attributedText.length) {
            NSString *temp = self.contentTV.text;
            temp = [temp stringByReplacingOccurrencesOfString:@" " withString:@""];
            temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            temp = [temp stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            temp = [temp stringByReplacingOccurrencesOfString:@"\f" withString:@""];
            temp = [temp stringByReplacingOccurrencesOfString:@"\v" withString:@""];
            self.title = [NSString stringWithFormat:@"%@字", @(temp.length)];
        }
        else {
            if (self.draft) {
                if (self.chapter) {
                    self.title = @"修改草稿";
                }
                else {
                    self.title = @"创建草稿";
                }
            }
            else {
                if (self.chapter) {
                    self.title = self.chapter.title;
                }
                else {
                    self.title = @"创建草稿";
                }
            }
        }
        [self hideLoading];
    }];
}

- (void)rightBtnClicked:(id)sender {
    END_EDITING;
    if (self.chapter.editWhisper == YES) {
        //只可修改作者的话
        UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@""];
        [actionSheet bk_addButtonWithTitle:@"保存作者的话" handler:^{
            [self saveWhisper:nil];
        }];
        [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:^{
            
        }];
        [actionSheet showInView:self.view];
        
    }
    else{
        UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@""];
        [actionSheet bk_addButtonWithTitle:@"保存草稿" handler:^{
            [self saveDraftWithCompletedBlock:nil];
        }];
        
        if (!self.isCopying) { //在创建副本不需要作为新章节提交审核
            [actionSheet bk_addButtonWithTitle:@"作为新章节提交审核" handler:^{
                [self newDraftSubmit];
            }];
        }
        
        [actionSheet bk_addButtonWithTitle:@"覆盖旧章节提交审核" handler:^{
            [self coverOldChapterSubmit];
        }];
        
        if (!self.isCopying) {
            [actionSheet bk_addButtonWithTitle:@"删除草稿" handler:^{
                [self deleteDraft];
            }];
        }
        
        [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:^{
            
        }];
        [actionSheet showInView:self.view];
    }
    
}

- (NSString *)handleSpecialString {
    NSString *temp = self.contentTV.text;
    temp = [temp stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\f" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\v" withString:@""];
    return temp;
}

- (void)newDraftSubmit {
    /*
     1.先保存到草稿
     2.再用草稿的发布
     */
    NSString *temp = [self handleSpecialString];
    self.modifiedTitle = YES;
    self.modifiedContent = YES;
    if (temp.length < 1000 && self.type.integerValue == 1) {
        [self showToastWithTitle:@"正文章节字数不能小于1000字" subtitle:nil type:ToastTypeAlert];
        return;
    }
    WEAK_SELF;
    [self saveDraftWithCompletedBlock:^(ChapterVO *chapter) {
        STRONG_SELF;
        
        QWContributionChooseVolumeVC *vc = [QWContributionChooseVolumeVC createFromStoryboardWithStoryboardID:@"choosevolume" storyboardName:@"QWContribution"];
        vc.bookId = self.book.nid.stringValue;
        vc.draft = self.draft;
        vc.chapterId = self.chapter.nid.stringValue;
        vc.chapterType = self.type;
        if (self.draft) {
            vc.draft = true;
        } else {
            vc.draft = false;
        }
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

- (void)coverOldChapterSubmit{
    //先保存
    //再选择
    self.modifiedTitle = YES;
    self.modifiedContent = YES;
    NSString *temp = [self handleSpecialString];
    if (temp.length < 1000 && self.type.integerValue == 1) {
        [self showToastWithTitle:@"正文章节字数不能小于1000字" subtitle:nil type:ToastTypeAlert];
        return;
    }
    WEAK_SELF;
    [self saveDraftWithCompletedBlock:^(ChapterVO *chapter) {
        if (self.isCopying) {
            [self submitView:self.mySubmitView selesectVolume:self.volume.nid.stringValue chapter:self.orginChapter.nid.stringValue];
        } else {
            STRONG_SELF;
            self.mySubmitView = [QWContributionSubmitView createWithNib];
            self.mySubmitView.frame = self.view.frame;
            [self.mySubmitView updateWithBook:self.book];
            self.mySubmitView.delegate = self;
            [[UIApplication sharedApplication].delegate.window addSubview:self.mySubmitView];
        }
    }];

}
-(void)saveWhisper:(void (^)(ChapterVO *chapter))completeBlock{
    if (self.authorWordTF.text.length > 50) {
        [self showToastWithTitle:@"作者的话不能超过50个字符" subtitle:nil type:ToastTypeAlert];
        return;
    }
    NSString *temp =  self.contentTV.text;
    temp = [temp stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\f" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\v" withString:@""];
    if (self.logic.isLoading) {
        return ;
    }
    self.logic.loading = YES;
        WEAK_SELF;
        [self showLoading];
        NSString *content = [[QWBannedWords sharedInstance] cryptoStringWithText:self.authorWordTF.text];
        [self.logic  updateWhisperWithBookId:self.book.nid.stringValue title:self.chapterTF.text whisper:content content:self.contentTV.attributedText zhengshiVolumeId:self.chapter.nid.stringValue andCompleteBlock:^(id aResponseObject, NSError *anError) {
            STRONG_SELF;
            if (!anError && aResponseObject) {
                self.modifiedTitle = NO;
                self.modifiedContent = NO;
                
                if (completeBlock) {
                    ChapterVO *tempChapter = [ChapterVO new];
                    tempChapter.nid = [aResponseObject objectForKey:@"id"];
                    self.chapter = tempChapter;
                    self.logic.chapter = tempChapter;
                    completeBlock(tempChapter);
                }
                else {
                    [self showToastWithTitle:@"修改作者的话成功" subtitle:nil type:ToastTypeAlert];
//                    [self performSegueWithIdentifier:identifer sender:self];
                    [self performSegueWithIdentifier:@"chapterupdate" sender:self];
                }
            }
            else {
                [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
            }
            
            [self hideLoading];
            self.logic.loading = NO;
        }];
    
}

- (void)saveDraftWithCompletedBlock:(void (^)(ChapterVO *chapter))completeBlock{ //代表保存完成
    END_EDITING;
    
    if (!self.chapterTF.text.length) {
        [self showToastWithTitle:@"请输入章名" subtitle:nil type:ToastTypeAlert];
        return;
    }

    if (self.chapterTF.text.length > 64) {
        [self showToastWithTitle:@"章名不能超过64个字符" subtitle:nil type:ToastTypeAlert];
        return;
    }
    if (self.authorWordTF.text.length > 50) {
        [self showToastWithTitle:@"作者的话不能超过50个字符" subtitle:nil type:ToastTypeAlert];
        return;
    }
    if (!self.contentTV.text.length) {
        [self showToastWithTitle:@"请输入正文" subtitle:nil type:ToastTypeAlert];
        return;
    }

    if (!self.modifiedContent && !self.modifiedTitle) {
        [self showToastWithTitle:@"无任何修改" subtitle:nil type:ToastTypeAlert];
        return ;
    }

    NSString *temp =  self.contentTV.text;
    temp = [temp stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\f" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\v" withString:@""];

    if (temp.length == 0) {
        [self showToastWithTitle:@"不能是空白内容" subtitle:nil type:ToastTypeAlert];
        return ;
    }

    if (self.logic.isLoading) {
        return ;
    }

    self.logic.loading = YES;
    void (^createDraft)(NSString *identifer) = [^(NSString *identifer) {
        WEAK_SELF;
        
        [self.logic createDraftWithBookId:self.book.nid.stringValue title:self.chapterTF.text whisper:self.authorWordTF.text  content:self.contentTV.attributedText chapterType:self.type andCompleteBlock:^(id aResponseObject, NSError *anError) {
            STRONG_SELF;
            if (!anError && aResponseObject) {
                self.modifiedTitle = NO;
                self.modifiedContent = NO;
        
                if (completeBlock) {
                    ChapterVO *tempChapter = [ChapterVO new];
                    tempChapter.nid = [aResponseObject objectForKey:@"id"];
                    self.chapter = tempChapter;
                    self.logic.chapter = tempChapter;
                    completeBlock(tempChapter);
                }
                else {
                    [self showToastWithTitle:@"创建草稿成功" subtitle:nil type:ToastTypeAlert];
                    [self performSegueWithIdentifier:identifer sender:self];
                }
            }
            else {
                [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
            }
            
            [self hideLoading];
            self.logic.loading = NO;
        }];
    } copy];
    
    [self showLoading];

    if (self.logic.chapter && !self.isCopying) {
        WEAK_SELF;
        NSString *title = self.chapterTF.text;
        NSAttributedString *content = self.modifiedContent ? self.contentTV.attributedText : self.contentTV.attributedText;
        
        [self.logic updateDraftWithDraftId:self.chapter.nid.stringValue  title:title whisper:self.authorWordTF.text content:content andCompleteBlock:^(id aResponseObject, NSError *anError) {
            STRONG_SELF;
            if (!anError && aResponseObject) {
                self.modifiedTitle = NO;
                self.modifiedContent = NO;
                if (completeBlock) {
                    ChapterVO *tempChapter = [ChapterVO new];
                    tempChapter.nid = [aResponseObject objectForKey:@"id"];
                    self.chapter = tempChapter;
                    self.logic.chapter = tempChapter;
                    completeBlock(tempChapter);
                }
                else {
                    [self showToastWithTitle:@"修改草稿成功" subtitle:nil type:ToastTypeAlert];
                    if (self.draft) {
                        [self performSegueWithIdentifier:@"draftupdate" sender:self];
                    } else {
                        [self performSegueWithIdentifier:@"chapterupdate" sender:self];
                    }
                }
            }
            else {
                [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
            }
            
            [self hideLoading];
            self.logic.loading = NO;
        }];
    }
    else {
        if (self.draft) {
            createDraft(@"draftupdate");
        } else {
            createDraft(@"chapterupdate");
        }
    }

}

- (void)deleteDraft {

    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"是否删除草稿"];
    [alertView bk_addButtonWithTitle:@"确定" handler:^{
        if (self.chapter) {
            [self showLoading];
            WEAK_SELF;
            [self.logic deleteDraftWithChapter:self.chapter andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
                STRONG_SELF;
                if (aResponseObject && !anError) {
                    int code = [[aResponseObject objectForKey:@"code"] intValue];
                    if (code != 0) {
                        NSString *msg = [aResponseObject objectForKey:@"msg"];
                        if (msg) {
                            [self showToastWithTitle:msg subtitle:nil type:ToastTypeError];
                        }
                        else {
                            [self showToastWithTitle:@"删除失败" subtitle:nil type:ToastTypeError];
                        }
                    }
                    else {
                        
                        [self onPressCancelBtn:self.navigationItem.leftBarButtonItem];
                    }
                }
                else {
                    [self showToastWithTitle:anError.description subtitle:nil type:ToastTypeError];
                }
                
                [self hideLoading];
            }];
        }
        else {
            [self onPressCancelBtn:self.navigationItem.rightBarButtonItem];
        }
    }];
    
    [alertView bk_setCancelButtonWithTitle:@"取消" handler:^{
        
    }];
    [alertView show];
}

- (IBAction)onPressCancelBtn:(id)sender
{
    NSString *identifier = @"chapter";
    
    if (self.draft) {
        if (self.logic.chapter) {
            identifier = @"draftupdate";
        } else  {
            identifier = @"draft";
        }
    }

    END_EDITING;
    if (self.modifiedTitle || self.modifiedContent) {
        WEAK_SELF;
        UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"提示" message:@"是否放弃修改?"];
        [alertView bk_setCancelButtonWithTitle:@"不放弃" handler:^{

        }];

        [alertView bk_addButtonWithTitle:@"放弃" handler:^{
            STRONG_SELF;
            [self performSegueWithIdentifier:identifier sender:self];
        }];
        
        [alertView show];
    }
    else {
        [self performSegueWithIdentifier:identifier sender:self];
    }
}

- (void)inputAccessoryView:(QWContributionInputAccessoryView *)inputAccessoryView inputCharacter:(NSString *)character
{
    if (self.contentTV.isFirstResponder && self.contentTV.editable) {
        [self.contentTV insertText:character];
    }
}

- (void)inputAccessoryView:(QWContributionInputAccessoryView *)inputAccessoryView onPressedAddImageBtn:(id)sender
{
    NSRange range = self.contentTV.selectedRange;
    if (range.location == NSNotFound) {
        [self showToastWithTitle:@"请先在编辑框中选择图片插入的位置" subtitle:nil type:ToastTypeAlert];
        return;
    }

    self.range = range;

    [self.contentTV resignFirstResponder];

    UIActionSheet *actionSheet = [[UIActionSheet alloc] bk_initWithTitle:@"插入图片"];

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
                [self uploadImage:chosenImage];
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
                [self uploadImage:chosenImage];
            }];
        }];

        [self performInMainThreadBlock:^{
            STRONG_SELF;
            [self presentViewController:picker animated:YES completion:nil];
        } afterSecond:.1f];
    }];

    [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:^{

    }];
    
    [actionSheet showInView:self.navigationController.view];
}

- (void)uploadImage:(UIImage *)image
{
    [self showLoading];
    WEAK_SELF;
    [self performInThreadBlock:^{
        STRONG_SELF;
        [self performInMainThreadBlock:^{
            STRONG_SELF;
            [self.logic uploadImage:image andCompleteBlock:^(id aResponseObject, NSError *anError) {
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
                        NSString *url = aResponseObject[@"path"];
                        url = [NSString stringWithFormat:@"http://image.iqing.in%@", url];
                        NSMutableAttributedString *attributedString = self.contentTV.attributedText.mutableCopy;
                        if (!attributedString) {
                            attributedString = [NSMutableAttributedString new];
                        }
                        QWContributionImageView *imageView = [QWContributionImageView createWithNib];
                        [imageView updateWithUrl:url];
                        NSMutableAttributedString *attachmentString = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeBottom attachmentSize:CGSizeMake(100, 100) alignToFont:[UIFont systemFontOfSize:15] alignment:YYTextVerticalAlignmentBottom];
                        [attachmentString yy_insertString:@"\n" atIndex:0];
                        [attachmentString yy_appendString:@"\n"];
                        [attributedString insertAttributedString:attachmentString atIndex:self.range.location];
                        [attributedString setYy_font:[UIFont systemFontOfSize:15]];
                        self.contentTV.attributedText = attributedString;
                        [self showToastWithTitle:@"上传成功" subtitle:nil type:ToastTypeError];
                    }
                }
                else {
                    [self showToastWithTitle:anError.userInfo[NSLocalizedDescriptionKey] subtitle:nil type:ToastTypeError];
                }

                self.range = NSMakeRange(NSNotFound, 0);
                [self hideLoading];
            }];
        }];
    }];
}

#pragma mark - text field

- (BOOL)textField:(nonnull UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string
{
    self.modifiedTitle = YES;

    if (!string.length) {
        return YES;
    }

    if (textField == self.chapterTF && self.chapterTF.text.length >= 64) {
        return NO;
    }
    if (textField == self.authorWordTF && self.authorWordTF.text.length >= 50) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.myInputAccessoryView setCharacterBtnHidden:YES];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.chapter.editWhisper == YES) {
        //只可修改作者的话
        if (textField == self.authorWordTF) {
            return YES;
        }
        else{
            return NO;
        }
    }else{
        return YES;
    }
}


#pragma mark - text view
- (BOOL)textView:(nonnull YYTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(nonnull NSString *)text
{
    if (!text.length) {
        return YES;
    }

    return YES;
}

- (void)textViewDidBeginEditing:(YYTextView *)textView
{
    
    [self.myInputAccessoryView setCharacterBtnHidden:NO];
    self.scrollView.scrollEnabled = NO;
    [self.scrollView setContentOffset:CGPointMake(0, self.contentTV.frame.origin.y - 64 - 30) animated:YES];
    
}

- (void)textViewDidEndEditing:(YYTextView *)textView
{
    self.scrollView.scrollEnabled = YES;
    [self.scrollView setContentOffset:CGPointMake(0, -64) animated:YES];
}

- (void)textViewDidChange:(YYTextView *)textView
{
    self.modifiedContent = YES;
    if (textView.attributedText.length) {
        NSString *temp = textView.text;
        temp = [temp stringByReplacingOccurrencesOfString:@" " withString:@""];
        temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        temp = [temp stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        temp = [temp stringByReplacingOccurrencesOfString:@"\f" withString:@""];
        temp = [temp stringByReplacingOccurrencesOfString:@"\v" withString:@""];
        self.title = [NSString stringWithFormat:@"%@字", @(temp.length)];
    }
    else {
        if (self.draft) {
            if (self.chapter) {
                self.title = @"修改草稿";
            }
            else {
                self.title = @"创建草稿";
            }
        }
        else {
            if (self.chapter) {
                self.title = @"修改正文";
            }
            else {
                self.title = @"创建章节";
            }
        }
    }
}
-(BOOL)textViewShouldBeginEditing:(YYTextView *)textView{
    if (self.chapter.editWhisper == YES) {
        return NO;
    }
    else{
        return YES;
    }
}
//- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange
//{
//    NSString *imagePath = [textAttachment.image objc_getAssociatedObject:@"image"];
//    if (imagePath.length) {
//        QWPictureVC *vc = [[UIStoryboard storyboardWithName:@"QWReading" bundle:nil] instantiateViewControllerWithIdentifier:@"picture"];
//        vc.pictures = @[imagePath];
//        [self.navigationController pushViewController:vc animated:YES];
//    }
//    return NO;
//}

//- (void)textViewTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = touches.anyObject;
//    CGPoint point = [touch locationInView:self.contentTV];
//    NSUInteger index = [self.contentTV.layoutManager characterIndexForPoint:point inTextContainer:self.contentTV.textContainer fractionOfDistanceBetweenInsertionPoints:NULL];
//    if (index != NSNotFound && self.contentTV.attributedText.length > 1) {
//        [self.contentTV.attributedText enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(index, 1) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
//            NSTextAttachment *textAttachment = value;
//            NSString *imagePath = [textAttachment.image objc_getAssociatedObject:@"image"];
//            if (imagePath.length) {
//                QWPictureVC *vc = [[UIStoryboard storyboardWithName:@"QWReading" bundle:nil] instantiateViewControllerWithIdentifier:@"picture"];
//                vc.pictures = @[imagePath];
//                [self.navigationController pushViewController:vc animated:YES];
//            }
//        }];
//    }
//}

#pragma mark QWContributionSubmitViewDelegate
- (void)submitView:(QWContributionSubmitView *)submitView selesectVolume:(NSString *)volumeId chapter:(NSString *)chapterId {
    [self.logic coverOldChapterWithChapterId:chapterId newChapterId:self.chapter.nid.stringValue andCompletBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (aResponseObject && !anError) {
            [self showToastWithTitle:@"覆盖章节正在审核中" subtitle:nil type:ToastTypeAlert];
            if (self.draft) {
                [self performSegueWithIdentifier:@"draftupdate" sender:nil];
            }
            else {
                [self performSegueWithIdentifier:@"chapter" sender:nil];
            }
        }
        else {
            [self showToastWithTitle:anError.localizedDescription subtitle:nil type:ToastTypeError];
        }
    }];
}
@end
