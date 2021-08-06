//
//  QWEmptyView.m
//  Qingwen
//
//  Created by Aimy on 7/20/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWEmptyView.h"

@interface QWEmptyView ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *errorMsgLabel;

@end

@implementation QWEmptyView

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.imageView.animationDuration = [self.class animationDuration];
    self.imageView.animationImages = [self getAnimationImages:self.useDark error:self.showError];
    [self.imageView startAnimating];

    if (ISIPHONE4_0 || ISIPHONE3_5) {
        self.errorMsgLabel.font = [UIFont systemFontOfSize:14.f];
    }
}

- (void)setCustomImages:(NSArray<UIImage *> *)customImages
{
    _customImages = customImages;
    self.imageView.animationDuration = [self.class animationDuration];
    if (_customImages) {
        self.imageView.animationImages = _customImages;
        self.imageView.image = self.imageView.animationImages.firstObject;
    }
    else {
        self.imageView.animationImages = [self getAnimationImages:self.useDark error:self.showError];
        self.imageView.image = self.imageView.animationImages.firstObject;
    }
    [self.imageView startAnimating];
}

- (void)setShowError:(BOOL)showError
{
    _showError = showError;
    WEAK_SELF;
    [self performInMainThreadBlock:^{
        STRONG_SELF;
        self.imageView.animationDuration = [self.class animationDuration];
        if (self.customImages) {
            self.imageView.animationImages = self.customImages;
            self.imageView.image = self.imageView.animationImages.firstObject;
        }
        else {
            self.imageView.animationImages = [self getAnimationImages:self.useDark error:self.showError];
            self.imageView.image = self.imageView.animationImages.firstObject;
        }

        [self.imageView startAnimating];

    } afterSecond:0.1];//避免突然转换成error的,导致可以察觉到
    self.errorMsgLabel.hidden = !self.showError || !self.errorMsg.length;
}

- (void)setUseDark:(BOOL)useDark
{
    _useDark = useDark;
    self.imageView.animationDuration = [self.class animationDuration];
    self.imageView.animationImages = [self getAnimationImages:self.useDark error:self.showError];
    self.imageView.image = self.imageView.animationImages.firstObject;
    [self.imageView startAnimating];
}

- (void)setErrorMsg:(NSString *)errorMsg
{
    _errorMsg = errorMsg;

    self.errorMsgLabel.text = _errorMsg;
    self.errorMsgLabel.hidden = !self.showError || !self.errorMsg.length;
}

- (NSArray *)getAnimationImages:(BOOL)dark error:(BOOL)error
{
    if (error) {
        if (self.errorImage) {
            return @[self.errorImage];
        }

        if (dark) {
            return @[[UIImage imageNamed:@"empty_2_none"]];
        }
        else {
            return @[[UIImage imageNamed:@"empty_1_none"]];
        }
    }
    else {
        if (dark) {
            return [self.class darkAnimationImages];
        }
        else {
            return [self.class lightAnimationImages];
        }
    }
}

+ (CGFloat)animationDuration
{
    return 0.7;
}

+ (NSArray *)lightAnimationImages
{
    return @[[UIImage imageNamed:@"empty_1_0"], [UIImage imageNamed:@"empty_1_1"], [UIImage imageNamed:@"empty_1_2"], [UIImage imageNamed:@"empty_1_3"], [UIImage imageNamed:@"empty_1_4"], [UIImage imageNamed:@"empty_1_5"], [UIImage imageNamed:@"empty_1_5"]];
}

+ (NSArray *)darkAnimationImages
{
    return @[[UIImage imageNamed:@"empty_2_0"], [UIImage imageNamed:@"empty_2_1"], [UIImage imageNamed:@"empty_2_2"], [UIImage imageNamed:@"empty_2_3"], [UIImage imageNamed:@"empty_2_4"], [UIImage imageNamed:@"empty_2_5"], [UIImage imageNamed:@"empty_2_5"]];
}

@end
