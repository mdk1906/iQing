//
//  QWGeneralCellConfigure.h
//  Qingwen
//
//  Created by mumu on 17/3/24.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QWGeneralCellConfigure <NSObject>

- (NSString *)imageView;
- (NSString *)mainTitle;
- (NSString *)subTitle;

@end


@protocol QWBookTVCellCogig <NSObject>

- (NSString *)coverImageString;
- (NSString *)titleString;
- (NSString *)authorString;
- (NSString *)combatString;
- (NSString *)beliefString;

- (NSString *)countString;
- (UIImage *)topCountbgImage;
@end
