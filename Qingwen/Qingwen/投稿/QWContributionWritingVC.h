//
//  QWContributionWritingVC.h
//  Qingwen
//
//  Created by Aimy on 8/5/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBaseVC.h"

#import "VolumeVO.h"
#import "ChapterVO.h"

NS_ASSUME_NONNULL_BEGIN

@interface QWContributionWritingVC : QWBaseVC

@property (nonatomic, strong) BookVO *book;
@property (nonatomic, strong) VolumeVO *volume;
@property (nonatomic, strong, nullable) ChapterVO *chapter;
@property (nonatomic) BOOL draft;

@property (nonatomic) NSNumber *type;
@property (nonatomic) BOOL whisper;
@end

NS_ASSUME_NONNULL_END
