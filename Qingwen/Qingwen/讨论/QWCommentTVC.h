//
//  QWCommentTVC.h
//  Qingwen
//
//  Created by Aimy on 8/11/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBaseVC.h"

@class DiscussItemVO;

@interface QWCommentTVC : QWBaseVC

@property (nonatomic, strong) DiscussItemVO *itemVO;
@property (nonatomic, strong) NSNumber *own;
@end
