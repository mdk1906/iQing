//
//  QWBulletManager.m
//  Qingwen
//
//  Created by mumu on 16/12/8.
//  Copyright © 2016年 iQing. All rights reserved.
//

#import "QWBulletManager.h"
#import "QWBulletView.h"
#import "BulletVO.h"

@interface QWBulletManager()

@property (nonatomic, strong) NSMutableArray *allBullets;

@property (nonatomic, strong) NSMutableArray *tempBullets;

@property (nonatomic, strong) NSMutableArray *bulletQueue;

@property (assign) BOOL isStrarted;

@property (assign) BOOL isStopAnimation;


@end

@implementation QWBulletManager

- (void)start {
    if (self.tempBullets.count == 0) {
        [self.tempBullets addObjectsFromArray:self.allBullets];
    }
    self.isStrarted = true;
    self.isStopAnimation = false;
    [self initBulletCommentView];
}

- (void)stop {
    self.isStopAnimation = YES;
    [self.bulletQueue enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        QWBulletView *view = obj;
        [view stopAnimation];
        view = nil;
    }];
    [self.tempBullets removeAllObjects];
    [self.allBullets removeAllObjects];
    self.tempBullets = nil;
    self.bulletQueue = nil;
    self.allBullets = nil;
}

- (void)stopPlaceholder {
    self.isStopAnimation = YES;
    [self.bulletQueue enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        QWBulletView *view = obj;
        if (view.placeholder) {
            [view stopAnimation];
            view = nil;
        }
    }];
}

- (void)loadBulletArray:(NSArray *) bulletArray {
    if (bulletArray.count == 0) {
        return;
    }
    [self stop];
    [self.allBullets addObjectsFromArray:bulletArray];
    [self.tempBullets addObjectsFromArray:bulletArray];
    [self start];
}

- (void)addBullet:(BulletVO *)bullet {
        BulletVO *bullet1 = [self.tempBullets firstObject];
        if (bullet1) {
            [self.tempBullets insertObject:bullet atIndex:0];
            [self.allBullets addObject:bullet];
        }else {
            if (self.allBullets.count == 0) {
                [self loadBulletArray:@[bullet]];
            } else {
                [self.allBullets addObject:bullet];
            }
        }
}

- (void)initBulletCommentView {
    //初始化三条弹幕轨迹
    NSMutableArray *arr = [NSMutableArray arrayWithArray:@[@(0), @(1), @(2)]];
    for (int i = 3; i > 0; i--) {
        BulletVO *bullet = [self.tempBullets firstObject];
        if (bullet) {
            [self.tempBullets removeObjectAtIndex:0];
            //随机生成弹道创建弹幕进行展示（弹幕的随机飞入效果）
            NSInteger index = arc4random()%arr.count;
            Trajectory trajectory = [[arr objectAtIndex:index] intValue];
            [arr removeObjectAtIndex:index];
            [self createBullet:bullet trajectory:trajectory];
        } else {
            break;
        }
    }
}

- (void)createBullet:(BulletVO *)bullet trajectory:(Trajectory)trajectory {
    if (self.isStopAnimation) {
        return;
    }
    QWBulletView *bulletView = [[QWBulletView alloc]initWithBulletVO:bullet];
    bulletView.trajectory = trajectory;
    __weak QWBulletView *weakBulletView = bulletView;
    __weak QWBulletManager *weakSelf = self;

    bulletView.bulletMoveBlock = ^(QWBulletViewMoveStatus status) {
        if ([weakSelf isStopAnimation]) {
            return;
        }
        switch (status) {
            case QWBulletViewStart:
                [self.bulletQueue addObject:weakBulletView]; //弹幕开始将其加入弹幕管理
                break;
                
            case QWBulletViewEnter:{
                BulletVO *nextBullet = [weakSelf nextBullet];
        
                if (nextBullet) {
                    [weakSelf createBullet:nextBullet trajectory:trajectory];
                } else {
                }
                break;
            }
            case QWBulletViewEnd : {
                if ([weakSelf.bulletQueue containsObject:weakBulletView]) {
                    [weakSelf.bulletQueue removeObject:weakBulletView];
                }
                if (weakSelf.bulletQueue.count == 0) {
                    //若运行完 可以在这里循环
//                    [weakSelf loadBulletArray:self.allBullets];
                    [weakSelf start];
                }
            }
                
            default:
                break;
        }
    };
    
    if (self.generateBulletBlock) {
        self.generateBulletBlock(bulletView);
    }
}

- (BulletVO *)nextBullet {
    BulletVO *bullet = [self.tempBullets firstObject];
    if (bullet) {
        [self.tempBullets removeObjectAtIndex:0];
    }
    return  bullet;
}

- (NSMutableArray *)bulletQueue {
    if (!_bulletQueue) {
        _bulletQueue = [NSMutableArray array];
    }
    return _bulletQueue;
}

- (NSMutableArray *)tempBullets {
    if (!_tempBullets) {
        _tempBullets = [NSMutableArray array];
    }
    if (_tempBullets.count == 0) {
    }
    return _tempBullets;
}

- (NSMutableArray *)allBullets {
    @synchronized (self) {
        if (!_allBullets) {
            _allBullets = [NSMutableArray array];
        }
        return  _allBullets;
    }
}

- (void)dealloc {
//    NSLog(@"%@--call %@",[self class], NSStringFromSelector(_cmd));

}
@end
