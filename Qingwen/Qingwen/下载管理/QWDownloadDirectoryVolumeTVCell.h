//
//  QWDownloadDirectoryVolumeTVCell.h
//  Qingwen
//
//  Created by Aimy on 9/29/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWBaseTVCell.h"

#import "VolumeVO.h"

@interface QWDownloadDirectoryVolumeTVCell : QWBaseTVCell

- (void)updateWithBookVO:(BookVO *)book volume:(VolumeVO *)volume originVolume:(VolumeVO *)originVolume;

@end
