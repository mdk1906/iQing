//
//  QWNewMessageListCell.m
//  Qingwen
//
//  Created by mumu on 17/3/6.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWNewMessageCenterCell.h"
#import "NewMessageVO.h"
@interface QWNewMessageCenterCell()

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet UILabel *sendDateLabel;
@property (strong, nonatomic) IBOutlet UIButton *unreadCountBtn;


@end

@implementation QWNewMessageCenterCell

- (void)updateCellWithMessageCenterVO:(TalkVO *)talk {
    if (!talk) {
        return;
    }
    
    NewMessageVO *message = talk.last_message;

    if (talk.last_message.created_time && message.content.length > 0) {
        self.sendDateLabel.text = [QWHelper shortDate1ToString:message.created_time];
    }else {
        self.sendDateLabel.text = @"";
    }
    
    if (talk.other.avatar) {
        [self.avatarImageView qw_setImageUrlString:[QWConvertImageString convertPicURL:talk.other.avatar imageSizeType:QWImageSizeTypeAvatar] placeholder:self.placeholder animation:true];
    }
    
    if (talk.other.username) {
        self.titleLabel.text = talk.other.username;
    }
    
    if (message.content) {
        self.contentLabel.text = message.content;
    }
    else {
        self.contentLabel.text = @"";
    }
    
    self.unreadCountBtn.hidden = talk.unread_num.integerValue < 1;
    
    if (talk.unread_num.integerValue > 0 && talk.unread_num.integerValue < 100) {
        [self.unreadCountBtn setTitle:[NSString stringWithFormat:@"%@",talk.unread_num] forState:UIControlStateNormal];
    }
    else if (talk.unread_num.integerValue >= 100) {
        [self.unreadCountBtn setTitle:@"99" forState:UIControlStateNormal];
    }
}

@end
