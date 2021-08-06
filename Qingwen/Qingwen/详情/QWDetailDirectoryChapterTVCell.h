//
//  QWDetailDirectoryChapterTVCell.h
//  Qingwen
//
//  Created by Aimy on 9/29/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWBaseTVCell.h"

@interface QWDetailDirectoryChapterTVCell : QWBaseTVCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabhh;

- (void)updateChapterVO:(ChapterVO *)chapter isContinueReading:(BOOL)isContinueReading;

- (void)updateBookVO:(BookVO *)book volumeId:(NSString *)volumeId;
@end
