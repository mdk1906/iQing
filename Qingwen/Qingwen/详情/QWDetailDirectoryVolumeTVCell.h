//
//  QWDetailDirectoryVolumeTVCell.h
//  Qingwen
//
//  Created by Aimy on 9/29/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWBaseTVCell.h"

#import "BookVO.h"
#import "VolumeVO.h"

@class QWDetailDirectoryVolumeTVCell;

@protocol QWDetailDirectoryVolumeTVCellDelegate <NSObject>

- (void)volumeCell:(QWDetailDirectoryVolumeTVCell *)cell didClickedFoldBtn:(UIButton *)sender;

@end

@interface QWDetailDirectoryVolumeTVCell : QWBaseTVCell

- (void)updateWithBookVO:(BookVO *)book volume:(VolumeVO *)volume;
@property (strong, nonatomic) IBOutlet UIButton *foldBtn;
@property (nonatomic, weak) id <QWDetailDirectoryVolumeTVCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *titleLabhh;


@end
