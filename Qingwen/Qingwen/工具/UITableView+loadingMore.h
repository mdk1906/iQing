//
//  UITableView+loadingMore.h
//  OneStoreFramework
//
//  Created by Aimy on 9/15/14.
//  Copyright (c) 2014 OneStore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (loadingMore)

/*
 - (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
 {
     if (!tableView.tableFooterView) {
         if (self.logic.homepageContainerVOsWithoutBannerVO.count - 1 == indexPath.section) {//计算是否是最后一个cell
                     [tableView showLoadingMore];//显示loadingmore
                     [self loadMoreProducts];//调用加载新数据的函数
         }
     }
 }
 */

//显示的label的tag为999

/**
 *  显示loadingmore,默认40高度
 */
- (void)showLoadingMore;

/**
 *  显示loadingmore 并可设置整体偏移量
 *
 *  @param aInsets 偏移量
 */
- (void)showLoadingMoreWithHeight:(CGFloat)aHeight andEdgeInsets:(UIEdgeInsets)aInsets;

@end
