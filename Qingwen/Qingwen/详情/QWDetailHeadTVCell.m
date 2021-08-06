//
//  QWDetailHeadTVCell.m
//  Qingwen
//
//  Created by Aimy on 9/29/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWDetailHeadTVCell.h"

#import "BookCD.h"
#import "QWHelper.h"

@interface QWDetailHeadTVCell ()

@property (nonatomic, strong) QWDetailHeadView *headView;
@property (strong, nonatomic) IBOutlet UIButton *showAllBtn;

@property (strong, nonatomic) IBOutlet UIButton *collectionCountBtn;
@property (strong, nonatomic) IBOutlet UIButton *heavyCoinBtn;
@property (strong, nonatomic) IBOutlet UIButton *coinBtn;

@property (strong, nonatomic) IBOutlet UILabel *collectionCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *heavyCoinLabel;
@property (strong, nonatomic) IBOutlet UILabel *coinLabel;

@property (strong, nonatomic) IBOutlet UIButton *discussBtn;

@property (strong, nonatomic) IBOutlet UIButton *attentionBtn;

@property (strong, nonatomic) IBOutlet UIButton *gotoReadingBtn;

@end

@implementation QWDetailHeadTVCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.headView = [QWDetailHeadView createWithNib];
    [self.contentView addSubview:self.headView];

    [self.headView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.contentView];
    [self.headView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.contentView];
    [self.headView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.contentView];
    [self.headView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView: self.contentView];
    [self.contentView sendSubviewToBack:self.headView];
    
    self.clipsToBounds = YES;
}

- (void)updateWithData:(BookVO *)book andAttention:(NSNumber *)attention discussCount:(NSNumber *)discussCount showAll:(BOOL)showAll
{
    [self.headView updateWithBook:book andAttention:attention showAll:showAll];

    VolumeCD *volumeCD = [VolumeCD findLastReadingVolumeWithBookId:book.nid];
    if (volumeCD) {
        [self.gotoReadingBtn setTitle:@"继续阅读" forState:UIControlStateNormal];
    }
    else {
        [self.gotoReadingBtn setTitle:@"开始阅读" forState:UIControlStateNormal];
    }

    if (attention.boolValue) {
        [self.attentionBtn setImage:[UIImage imageNamed:@"detail_icon_1"] forState:UIControlStateNormal];
    }
    else {
        [self.attentionBtn setImage:[UIImage imageNamed:@"detail_icon_0"] forState:UIControlStateNormal];
    }

    if ([QWGlobalValue sharedInstance].isLogin) {
        self.attentionBtn.enabled = (attention != nil);
    }

    if (showAll) {
        [self.showAllBtn setImage:[UIImage imageNamed:@"arrow_up"] forState:UIControlStateNormal];
    }
    else {
        [self.showAllBtn setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
    }

    self.collectionCountLabel.text = [QWHelper countToShortString:book.follow_count];
    self.heavyCoinLabel.text = [QWHelper countToShortString:book.gold];
    self.coinLabel.text = [QWHelper countToShortString:book.coin];
}

- (IBAction)onPressedShowAllBtn:(id)sender {
    [self.delegate headCell:self didClickedShowAllBtn:sender];
}

- (IBAction)onPressedChargeBtn:(id)sender {
    [self.delegate headCell:self didClickedChargeBtn:sender];
}

- (IBAction)onPressedHeavyChargeBtn:(id)sender {
    [self.delegate headCell:self didClickedHeavyChargeBtn:sender];
}

- (IBAction)onPressedAttentionBtn:(id)sender {
    [self.delegate headCell:self didClickedAttentionBtn:sender];
}

- (IBAction)onPressedDiscussBtn:(id)sender {
    [self.delegate headCell:self didClickedDiscussBtn:sender];
}

- (IBAction)onPressedDirectoryBtn:(id)sender {
    [self.delegate headCell:self didClickedDirectoryBtn:sender];
}

- (IBAction)onPressedGotoReadingBtn:(id)sender {
    [self.delegate headCell:self didClickedGotoReadingBtn:sender];
}

@end
