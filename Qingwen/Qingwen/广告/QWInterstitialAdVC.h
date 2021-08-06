//
//  QWInterstitialAdVC.h
//  Qingwen
//
//  Created by qingwen on 2019/2/26.
//  Copyright © 2019 iQing. All rights reserved.
//

#import "QWBaseVC.h"

@interface QWInterstitialAdVC : QWBaseVC
@property (nonatomic,strong) NSString *waitTime;
@property (nonatomic,strong) NSNumber *chapterId;
@property (nonatomic,strong) NSNumber *bookId;
-(void)startAd;
@end
