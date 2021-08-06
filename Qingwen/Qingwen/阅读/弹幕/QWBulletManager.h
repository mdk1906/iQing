//
//  QWBulletManager.h
//  Qingwen
//
//  Created by mumu on 16/12/8.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BulletVO.h"

@class QWBulletView;
@interface QWBulletManager : NSObject

@property (nonatomic, copy) void (^generateBulletBlock)(QWBulletView *bulletView);

- (void)loadBulletArray:(NSArray *) bulletArray;

- (void)addBullet:(BulletVO *)bullet;

- (void)start;
- (void)stop;

@end
