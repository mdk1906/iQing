//
//  QWEmptyView.h
//  Qingwen
//
//  Created by Aimy on 7/20/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QWEmptyView : UIView

@property (nonatomic) BOOL showError;
@property (nonatomic) BOOL useDark;
@property (nonatomic) BOOL configFrameManual;
@property (nonatomic, copy) NSString *errorMsg;
@property (nonatomic, copy) UIImage *errorImage;

@property (nonatomic, strong) NSArray<UIImage *> *customImages;

@end
