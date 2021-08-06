//
//  QWPictureCVCell.h
//  Qingwen
//
//  Created by Aimy on 7/4/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBaseCVCell.h"

#import "QWOperationManager.h"

@interface QWPictureCVCell : QWBaseCVCell

@property (nonatomic, strong) QWOperationManager *manager;

- (void)updateImageWithUrl:(NSString *)url bookId:(NSString *)bookId volumeId:(NSString *)volumeId chapterId:(NSString *)chapterId;

- (void)rotateImage;

- (void)saveImageToDisk;

@end
