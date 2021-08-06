//
//  QWContributionImageView.m
//  Qingwen
//
//  Created by Aimy on 1/13/16.
//  Copyright © 2016 iQing. All rights reserved.
//

#import "QWContributionImageView.h"

@interface QWContributionImageView ()

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@end

@implementation QWContributionImageView

- (void)setFrame:(CGRect)frame
{
    CGRect temp = frame;
    temp.size = CGSizeMake(100, 100);
    [super setFrame:temp];
}

- (void)updateWithUrl:(NSString *)url
{
    self.url = url;
    [self.imageView qw_setImageUrlString:[QWConvertImageString convertPicURL:url imageSizeType:QWImageSizeTypeAvatar] placeholder:[UIImage imageNamed:@"placeholder2to1"] animation:YES];
}

- (IBAction)onPressedImageView:(id)sender
{
    if (self.url.length) {
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"pictures"] = @[self.url];
        [[QWRouter sharedInstance] routerWithUrlString:[NSString getRouterVCUrlStringFromUrlString:@"picture" andParams:params]];
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(100, 100);
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(100, 100);
}

@end
