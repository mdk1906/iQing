//
//  QWDetailDirectoryVC.h
//  Qingwen
//
//  Created by Aimy on 9/29/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWBaseVC.h"

#import "BookVO.h"
#import "VolumeList.h"

@interface QWDetailDirectoryVC : QWBaseVC

@property (nonatomic, strong) BookVO *bookVO;
@property (nonatomic, strong) VolumeList *volumeList;
@property (nonatomic, strong) NSString *InId;//1显示下载 else不显示下载
@end
