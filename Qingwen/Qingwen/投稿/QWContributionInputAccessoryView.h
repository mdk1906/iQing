//
//  QWContributionInputAccessoryView.h
//  Qingwen
//
//  Created by Aimy on 9/24/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QWContributionInputAccessoryView;

@protocol QWContributionInputAccessoryViewDelegate <NSObject>

- (void)inputAccessoryView:(QWContributionInputAccessoryView *)inputAccessoryView inputCharacter:(NSString *)character;
- (void)inputAccessoryView:(QWContributionInputAccessoryView *)inputAccessoryView onPressedAddImageBtn:(id)sender;

@end

@interface QWContributionInputAccessoryView : UIView

@property (nonatomic, weak) id <QWContributionInputAccessoryViewDelegate> delegate;


- (void)setCharacterBtnHidden:(BOOL)hidden;

@end
