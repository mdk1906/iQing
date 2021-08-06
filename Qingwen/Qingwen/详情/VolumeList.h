//
//  VolumeList.h
//  Qingwen
//
//  Created by Aimy on 9/9/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "PageVO.h"

#import "VolumeVO.h"

NS_ASSUME_NONNULL_BEGIN

@interface VolumeList : PageVO

@property (nonatomic, copy) NSArray<VolumeVO> *results;

- (void)configDirectory;

- (void)configOfflineDirectoryWithBookId:(NSString *)bookId;

- (BookPageVO *)getNextPageWithPage:(BookPageVO *)page;

- (BookPageVO *)getPreviousPageWithPage:(BookPageVO *)page;

@end

NS_ASSUME_NONNULL_END