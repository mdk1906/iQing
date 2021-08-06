//
//  QWTextView.h
//  Qingwen
//
//  Created by Aimy on 8/6/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QWTextViewDelegate <UITextViewDelegate>

@optional
- (void)textViewTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;

@end

@interface QWTextView : UITextView

@property (nonatomic, weak) id <QWTextViewDelegate> delegate;
@property (nonatomic, copy) IBInspectable NSString *placeholder;
@property (nonatomic, copy) IBInspectable UIColor *placeholderColor;

@end
