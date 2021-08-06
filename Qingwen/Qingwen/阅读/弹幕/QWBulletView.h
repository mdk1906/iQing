//
//  QWBulletView.h
//  Qingwen
//
//  Created by mumu on 16/12/8.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BulletVO.h"
typedef NS_ENUM(NSInteger, QWBulletViewMoveStatus) {
    QWBulletViewStart, //刚开始进入
    QWBulletViewEnter, //已经进入
    QWBulletViewEnd    //
};

typedef NS_ENUM(NSInteger, Trajectory) {
    Trajectory_1 = 0, //轨道1
    Trajectory_2 = 1, //轨道2
    Trajectory_3 = 2 //轨道3
};

@interface QWBulletView : UIView

@property (nonatomic, copy) void (^bulletMoveBlock)(QWBulletViewMoveStatus status); //获取当前View的进入状态
@property Trajectory trajectory;

@property (nonatomic, strong) BulletVO *previosBulletVO;

@property (assign) BOOL placeholder;
@property (assign, readonly) BOOL isWalking; //在Enter - End 之间

- (instancetype)initWithBulletVO:(BulletVO *)bullet;

- (void)startAnimation;

- (void)stopAnimation;

@end
