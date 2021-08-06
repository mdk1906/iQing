//
//  QWTBC.h
//  Qingwen
//
//  Created by Aimy on 7/1/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QWTBC : UITabBarController

- (void)doChargeWithBook:(BookVO *)book heavy:(BOOL)heavy;
- (void)doChargeWithFavorite:(FavoriteBooksVO *)favorite heavy:(BOOL)heavy;
- (void)doCharge;

@end
