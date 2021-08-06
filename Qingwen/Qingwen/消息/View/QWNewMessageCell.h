//
//  QWNewMessageCell.h
//  Qingwen
//
//  Created by mumu on 17/3/3.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWBaseTVCell.h"
#import "NewMessageVO.h"
@interface QWNewMessageCell : QWBaseTVCell

- (void)updateCellWithMessageVO:(NewMessageVO *)message;
- (void)updateAvatarImage:(NSString *)avatar;

+ (CGFloat)heightWithMessage:(NewMessageVO *)message;
@end
