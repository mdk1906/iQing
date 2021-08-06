//
//  QWReadingGestureDelegate.m
//  Qingwen
//
//  Created by Aimy on 7/6/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWReadingGestureDelegate.h"

#import "QWReadingPVC.h"
#import "QWReadingVC.h"
#import "QWReadingManager.h"

@interface QWReadingPVC ()

@property (nonatomic) BOOL showSetting;

- (void)toPictureVC;
- (void)showSettingViews;
- (void)hideAllSettingViews;
- (void)showEndView;

@end

@interface QWReadingGestureDelegate () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet QWReadingPVC *ownerPVC;

@end

@implementation QWReadingGestureDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];

        if (self.ownerPVC.showSetting) {
            return YES;
        }
        else if (self.ownerPVC.isAloud){
            return YES;
        }
        else {
            QWReadingVC *currentVC = self.ownerPVC.currentVC;

            //中上,左边－》上一页
            if ((point.x > UISCREEN_WIDTH / 3 &&
                 point.x < UISCREEN_WIDTH * 2 / 3 &&
                 point.y > 0 &&
                 point.y < UISCREEN_HEIGHT * 1 / 3) ||
                (point.x > 0 &&
                 point.x < UISCREEN_WIDTH * 1 / 3 &&
                 point.y > 0 &&
                 point.y < UISCREEN_HEIGHT)) {
                    QWReadingVC *vc = ({
                        if ([currentVC isLoading]) {//正在加载数据
                            [self.ownerPVC showLoadingWithMessage:@"章节正文正在加载，请稍等" hideAfter:1.0];
                            return NO;
                        }

                        if (![currentVC previousPage]) {//没有上一页
                            [self.ownerPVC showLoadingWithMessage:@"没有上一页了" hideAfter:1.0];
                            return NO;
                        }

                        [[QWReadingManager sharedInstance] getPreviousPageReadingVCWithCurrentReadingVC:currentVC];
                    });
                    if (vc) {
                        self.ownerPVC.currentVC = vc;
                        self.ownerPVC.GDTAdView.hidden = YES;
                        self.ownerPVC.VipLine.hidden = YES;
                        self.ownerPVC.VipLab.hidden = YES;
                        [self.ownerPVC.pageViewController setViewControllers:@[vc, [vc.storyboard instantiateViewControllerWithIdentifier:@"placeholder"]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
                    }
                    return NO;
                }
            //中下,右边－》下一页
            else if ((point.x > UISCREEN_WIDTH / 3 &&
                      point.x < UISCREEN_WIDTH * 2 / 3 &&
                      point.y > UISCREEN_HEIGHT * 2 / 3 &&
                      point.y < UISCREEN_HEIGHT) ||

                     (point.x > UISCREEN_WIDTH * 2 / 3 &&
                      point.x < UISCREEN_WIDTH &&
                      point.y > 0 &&
                      point.y < UISCREEN_HEIGHT)) {
                         QWReadingVC *vc = ({
                             if ([currentVC isLoading]) {//正在加载数据
                                 [self.ownerPVC showLoadingWithMessage:@"章节正文正在加载，请稍等" hideAfter:1.0];
                                 return NO;
                             }

                             if (![currentVC nextPage]) {//没有下一页
                                 [self.ownerPVC showLoadingWithMessage:@"没有下一页了" hideAfter:1.0];
                                 [self.ownerPVC showEndView];
                                 return NO;
                             }

                             [[QWReadingManager sharedInstance] getNextPageReadingVCWithCurrentReadingVC:currentVC];
                         });
                         if (vc) {
                             self.ownerPVC.currentVC = vc;
                             self.ownerPVC.GDTAdView.hidden = YES;
                             self.ownerPVC.VipLine.hidden = YES;
                             self.ownerPVC.VipLab.hidden = YES;
                             [self.ownerPVC.pageViewController setViewControllers:@[vc, [vc.storyboard instantiateViewControllerWithIdentifier:@"placeholder"]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
                         }
                         return NO;
                     }
            else {//中心－》设置
                return YES;
            }
        }

        return NO;
    }
    else if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        QWReadingVC *currentVC = self.ownerPVC.currentVC;
        if (!currentVC.isLoading && currentVC.isPicture && currentVC.pictureName) {
            return YES;
        }

        return NO;
    }

    return NO;
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    // 输出点击的view的类名
//    NSLog(@"%@", NSStringFromClass([touch.view class]));
//    
//    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
//    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCell"]) {
//        return NO;
//    }
//    if ([NSStringFromClass([touch.view class]) isEqualToString:@"QWSendDanmuView"]) {
//        return NO;
//    }
//    if ([NSStringFromClass([touch.view class]) isEqualToString:@"QWTextView"]) {
//        return NO;
//    }
//    return  YES;
//}

- (IBAction)onTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        if (self.ownerPVC.showSetting) {
            [self.ownerPVC hideAllSettingViews];
        }
        else {
            [self.ownerPVC showSettingViews];
        }
    }
    else if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            [self.ownerPVC toPictureVC];
        }
    }
}

@end
