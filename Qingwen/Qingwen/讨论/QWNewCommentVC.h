//
//  QWNewCommentVC.h
//  Qingwen
//
//  Created by Aimy on 8/11/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBaseVC.h"

@class DiscussItemVO;

@interface QWNewCommentVC : QWBaseVC

@property (nonatomic, strong) NSString *discussUrl;
@property (nonatomic, strong) DiscussItemVO *itemVO;

@end
