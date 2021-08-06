//
//  QWGeneralTVCell.m
//  Qingwen
//
//  Created by mumu on 17/3/24.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import "QWGeneralTVCell.h"

@interface QWGeneralTVCell(){
    UIImageView * _iconImageView;
    UILabel * _mainTitleLabel;
    UILabel * _subTitleLabel;
}

@end

@implementation QWGeneralTVCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    return self;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    
    static NSString *identifier = @"MessageCell" ;
    QWGeneralTVCell  *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[QWGeneralTVCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configureCell];
    }
    
    return self;
}

- (void)configureCell {
    _iconImageView = [[UIImageView alloc] init];
    
    _mainTitleLabel = [[UILabel alloc] init];
    _mainTitleLabel.textAlignment = NSTextAlignmentLeft;
    _mainTitleLabel.font = [UIFont systemFontOfSize:14];
    
    _subTitleLabel = [[UILabel alloc] init];
    _subTitleLabel.font = [UIFont fontWithName:@".SFUIText-Medium" size:14.0];
    _subTitleLabel.textAlignment = NSTextAlignmentRight;
    
    [self.contentView addSubview:_iconImageView];
    [self.contentView addSubview:_mainTitleLabel];
    [self.contentView addSubview:_subTitleLabel];
    
    CGFloat paddingX = 12;
    if (self.paddingX) {
        paddingX = self.paddingX;
    }
    
    CGFloat paddingY = 10;
    if (self.paddingY) {
        paddingY = self.paddingY;
    }
    
    [_iconImageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.contentView withOffset: paddingX];
    [_iconImageView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.contentView withOffset:paddingY];
    [_iconImageView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.contentView withOffset:-paddingY];
    [_iconImageView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionHeight ofView:_iconImageView];
    
    [_mainTitleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_iconImageView withOffset:paddingX];
    [_mainTitleLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    if (self.customAccessoryImage) {
       [_subTitleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.contentView withOffset:- (paddingX + 20)];
    }
    else {
        [_subTitleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.contentView withOffset:-paddingX];
    }
    [_subTitleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_mainTitleLabel withOffset:20 relation:NSLayoutRelationGreaterThanOrEqual];
    [_subTitleLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
}

- (void)updateWithVO:(id <QWGeneralCellConfigure>)vo {
    
    if (![vo conformsToProtocol:@protocol(QWGeneralCellConfigure)]) {
        return;
    }
    
    if ([vo respondsToSelector:@selector(imageView)]) {

        [_iconImageView qw_setImageUrlString:[QWConvertImageString convertPicURL:[vo imageView] imageSizeType:QWImageSizeTypeAvatar] placeholder:self.placeholder cornerRadius:self.cornerRadius borderWidth:0 borderColor:[UIColor clearColor] animation:false completeBlock:nil];
    }
    if ([vo respondsToSelector:@selector(mainTitle)]) {
        _mainTitleLabel.text = [vo mainTitle];
        _mainTitleLabel.textColor = self.mainTitleColor ? self.mainTitleColor : [UIColor color33];
    }
    if ([vo respondsToSelector:@selector(subTitle)]) {
        _subTitleLabel.text = [vo subTitle];
        _subTitleLabel.textColor = self.subTitleColor ? self.subTitleColor : [UIColor color33];
    }
}

@end
