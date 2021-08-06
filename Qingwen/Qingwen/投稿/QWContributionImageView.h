//
//  QWContributionImageView.h
//  Qingwen
//
//  Created by Aimy on 1/13/16.
//  Copyright © 2016 iQing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QWContributionImageView : UIView

@property (nonatomic, strong) NSString *url;

- (void)updateWithUrl:(NSString *)url;

@end
