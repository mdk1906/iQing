//
//  QWMessageLoginView.m
//  Qingwen
//
//  Created by Aimy on 8/27/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWMessageLoginView.h"

@interface QWMessageLoginView ()

@property (strong, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation QWMessageLoginView

- (IBAction)onPressedLoginBtn:(id)sender {
    [[QWRouter sharedInstance] routerToLogin];
}

@end
