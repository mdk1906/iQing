//
//  QWInputView.h
//  Qingwen
//
//  Created by Aimy on 8/13/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QWTextView.h"
#import "QWDiscussLogic.h"

@class QWInputView;

@protocol QWInputViewDelegate <NSObject>

- (void)inputView:(QWInputView *)inputView onPressedSendBtn:(id)sender;
- (void)inputView:(QWInputView *)inputView onPressedAddBookBtn:(id)sender;
- (void)inputView:(QWInputView *)inputView onPressedAddAtBtn:(id)sender;

@end

@interface QWInputView : UIView <UITextViewDelegate>

@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;
@property (nonatomic, strong) IBOutlet QWTextView *contentTV;

@property (nonatomic, weak) id<QWInputViewDelegate> delegate;

@property (strong, nonatomic) QWAddImageView *imageInputView;

- (void)setLogic:(QWDiscussLogic *)logic;

- (void)resetHeight;
- (void)resetInputView;

@end
