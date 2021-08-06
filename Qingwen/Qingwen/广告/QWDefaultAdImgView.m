//
//  QWDefaultAdImgView.m
//  Qingwen
//
//  Created by mdk mdk on 2019/5/21.
//  Copyright © 2019 iQing. All rights reserved.
//

#import "QWDefaultAdImgView.h"
@interface QWDefaultAdImgView ()

@property (nonatomic, strong) UIImageView *bannerView;

@end
@implementation QWDefaultAdImgView

-(instancetype)initWithFrame:(CGRect)frame withImgUrl:(NSString *)url withPost:(NSString*)postUrl{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.bannerView = [UIImageView new];
        _bannerView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[@"source"] = @"iQing";
        [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"IndexEvent" extra:params];
        [_bannerView qw_setImageUrlString:url placeholder:nil animation:YES];
        _bannerView.userInteractionEnabled = YES;
        [_bannerView bk_tapped:^{
            [[QWRouter sharedInstance] routerWithUrlString:postUrl];
            NSMutableDictionary *params = [NSMutableDictionary new];
            params[@"source"] = @"iQing";
            [QWUserStatistics sendEventToServer:@"CustomEvent" pageID:@"IndexClickEvent" extra:params];
        }];
        [self addSubview:_bannerView];
        
    }
    return self;
}

@end
