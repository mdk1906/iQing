//
//  QWPictureVC.h
//  Qingwen
//
//  Created by Aimy on 7/2/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBaseVC.h"

@interface QWPictureVC : QWBaseVC

@property (nonatomic, copy) NSString *bookId;
@property (nonatomic, copy) NSString *volumeId;
@property (nonatomic, copy) NSString *chapterId;
@property (nonatomic, copy) NSArray *pictures;
@property (nonatomic, copy) NSNumber *index;

@end
