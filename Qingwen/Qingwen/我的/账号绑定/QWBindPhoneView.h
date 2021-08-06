//
//  QWBindPhoneView.h
//  Qingwen
//
//  Created by mumu on 2017/8/9.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QWBindFirstView : QWBaseView

@end

@interface QWBindSecondView : QWBaseView

@end

@interface QWBindThirdView : QWBaseView

@end

@interface QWBindPhoneView : NSObject

+ (QWBindPhoneView *)sharedInstance;
@end
