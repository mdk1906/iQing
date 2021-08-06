//
//  QWAutoSubscriberListTVCell.m
//  Qingwen
//
//  Created by wei lu on 18/11/17.
//  Copyright © 2017 iQing. All rights reserved.
//

#import "QWAutoSubscriberListTVCell.h"

@interface QWAutoSubscriberListTVCell()
@property (strong, nonatomic,readwrite) IBOutlet UISwitch *switchView;
@end

@implementation QWAutoSubscriberListTVCell

- (void)updateWithSuscribeList:(SubscriberBooks *)list {
//    [self.avatar qw_setImageUrlString:[QWConvertImageString convertPicURL:user.avatar imageSizeType:QWImageSizeTypeAvatar] placeholder:[UIImage imageNamed:@"mycenter_logo"] animation:true];
//    self.sexImageView.image = (user.sex && user.sex.integerValue == 1) ? [UIImage imageNamed:@"sex1"] : [UIImage imageNamed:@"sex0"];
//    self.nameLabel.text = user.username;
    //self.introLabel.text = user.signature;
    self.textLabel.text = list.title;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.accessoryView = self.switchView;
    
    if([list.toggle boolValue]){
        [self.switchView setOn:true animated:NO];
    }else{
        [self.switchView setOn:false animated:NO];
    }
    
}

@end
