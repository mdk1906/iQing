//
//  QWContributionSubmitView.h
//  Qingwen
//
//  Created by mumu on 2017/9/9.
//  Copyright © 2017年 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QWContributionSubmitView;
@protocol QWContributionSubmitViewDelegate <NSObject>

- (void)submitView:(QWContributionSubmitView *)submitView selesectVolume:(NSString *)volumeId chapter:(NSString *)chapterId;

@end

@interface QWContributionSubmitView : QWBaseView

@property (nonatomic, weak) id <QWContributionSubmitViewDelegate> delegate;

- (void)updateWithBook:(BookVO *)book;
@end
