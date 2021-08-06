//
//  QWReadingDirectoryVC.h
//  Qingwen
//
//  Created by Aimy on 9/23/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWBaseVC.h"

#import "VolumeVO.h"
#import "BookCD.h"
#import "VolumeList.h"
@class QWReadingDirectoryVC;

@protocol QWReadingDirectoryVCDelegate <NSObject>

- (void)hideDirectoryVC:(QWReadingDirectoryVC *)directoryVC;
- (void)directoryVC:(QWReadingDirectoryVC *)directoryVC didClickChapterAtIndex:(NSInteger)index;
- (void)directoryVC:(QWReadingDirectoryVC *)directoryVC didClickChapterAtIndex:(NSIndexPath*)index volumes:(VolumeList *)volumes Book:(BookVO *)book;
@end

@interface QWReadingDirectoryVC : QWBaseVC

@property (nonatomic, weak) id<QWReadingDirectoryVCDelegate> delegate;

- (void)updateWithBook:(BookCD *)book volume:(VolumeVO *)volume volumeList:(VolumeList *)list;

@end
