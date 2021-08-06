//
//  QWDetailDirectoryChapterTVCell.m
//  Qingwen
//
//  Created by Aimy on 9/29/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWDetailDirectoryChapterTVCell.h"
#import "QWFileManager.h"
@interface QWDetailDirectoryChapterTVCell()

@property (strong, nonatomic) IBOutlet UILabel *chapterTitle;

@property (strong, nonatomic) IBOutlet UIImageView *lockStateImage;

@property (strong, nonatomic) IBOutlet UIButton *lockStateBtn;

@property (strong, nonatomic) IBOutlet UIImageView *selectImage;

@property (nonatomic, assign) BOOL currentSelectedState;

@property (nonatomic, strong) ChapterVO *chapterVO;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *selectImageLeftConstraint;

@property (nonatomic, copy) BookVO *book;
@property (nonatomic, copy) NSString *volumeId;

@end

@implementation QWDetailDirectoryChapterTVCell

- (void)updateChapterVO:(ChapterVO *)chapter isContinueReading:(BOOL)isContinueReading {
    
    self.chapterVO = chapter;
    if (isContinueReading) {
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:@"[继续阅读]" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: QWPINK}];
        [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:chapter.title attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: HRGB(0x505050)}]];
        self.chapterTitle.attributedText = attributedText;
    } else {
        self.chapterTitle.attributedText = [[NSAttributedString alloc] initWithString:chapter.title attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: HRGB(0x505050)}];
    }
    if ([QWFileManager isChapterExitWithBookId:_book.nid.stringValue volumeId:_volumeId chapterId:_chapterVO.nid.stringValue]) {
        self.selectImage.hidden = true;
        
    }else {
        self.selectImage.hidden = false;
    }
}

- (void)updateBookVO:(BookVO *)book volumeId:(NSString *)volumeId {
    _book = book;
    _volumeId = volumeId;
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (editing) {
        self.selectImage.image = [UIImage imageNamed:@"chapter_unchoice"];

        if ([QWFileManager isChapterExitWithBookId:_book.nid.stringValue volumeId:_volumeId chapterId:_chapterVO.nid.stringValue]) {
            self.selectImageLeftConstraint.constant = 10;
            self.selectImage.hidden = true;
            [self.lockStateBtn setTitle:@"已下载" forState:UIControlStateNormal];
            [self.lockStateBtn setBackgroundImage:nil forState:UIControlStateNormal];
            
        }else {
            self.selectImage.hidden = false;
            self.selectImageLeftConstraint.constant = 30;

            if (self.chapterVO.amount.floatValue == 0 || self.chapterVO.subscriber == true) {
                [self.lockStateBtn setTitle:@"" forState:UIControlStateNormal];

            }else {
            [self.lockStateBtn setTitle:[NSString stringWithFormat:@"%.1f重石",self.chapterVO.amount.floatValue] forState:UIControlStateNormal];
            }
            
            [self.lockStateBtn setBackgroundImage:nil forState:UIControlStateNormal];
        }
    } else {
        self.selectImageLeftConstraint.constant = 10;
        self.selectImage.hidden = true;
        
        [self.lockStateBtn setTitle:@"" forState:UIControlStateNormal];

        switch (self.chapterVO.type.integerValue) {
            case 0:
                [self.lockStateBtn setBackgroundImage:nil forState:UIControlStateNormal];
                break;
            case 1:
                [self.lockStateBtn setBackgroundImage:nil forState:UIControlStateNormal];
                break;
            case 2:
                if (self.chapterVO.subscriber) {
                    [self.lockStateBtn setBackgroundImage:[UIImage imageNamed:@"unlock"] forState:UIControlStateNormal];
                }else  {
                    [self.lockStateBtn setBackgroundImage:[UIImage imageNamed:@"lock"] forState:UIControlStateNormal];
                }
                if (_book.need_pay.integerValue > 0 && _book.discount.integerValue == 0 ) {
                    [self.lockStateBtn setBackgroundImage:[UIImage imageNamed:@"chapter_free"] forState:UIControlStateNormal];
                }
                break;
            default:
                break;
        }

    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (selected) {
        self.selectImage.image = [UIImage imageNamed:@"chapter_choice"];
    } else  {
        self.selectImage.image = [UIImage imageNamed:@"chapter_unchoice"];
    }
    
}


@end
