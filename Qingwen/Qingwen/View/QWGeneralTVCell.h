//
//  QWGeneralTVCell.h
//  Qingwen
//
//  Created by mumu on 17/3/24.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWBaseTVCell.h"
#import "QWGeneralCellConfigure.h"

@interface QWGeneralTVCell : QWBaseTVCell

/**
    mainTitleColor default = [UIColor color50]
 */
@property (nonatomic, strong) UIColor *mainTitleColor;

/**
    subTitleColor default = [UIColor color50]
 */
@property (nonatomic, strong) UIColor *subTitleColor;
/**
    PaddingLeft defalut = 12
 */
@property (nonatomic, assign) CGFloat paddingX;
/**
 PaddingLeft defalut = 10
 */
@property (nonatomic, assign) CGFloat paddingY;

//@property (nonatomic, assign) CGFloat imgcornerRadius;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

- (void)updateWithVO:(id <QWGeneralCellConfigure>)vo;


@end
