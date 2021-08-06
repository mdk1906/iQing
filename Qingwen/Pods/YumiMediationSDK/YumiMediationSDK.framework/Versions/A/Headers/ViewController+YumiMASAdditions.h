//
//  UIViewController+YumiMASAdditions.h
//  Masonry
//
//  Created by Craig Siemens on 2015-06-23.
//
//

#import "YumiMASConstraintMaker.h"
#import "YumiMASUtilities.h"
#import "YumiMASViewAttribute.h"

#ifdef YumiMAS_VIEW_CONTROLLER

@interface YumiMAS_VIEW_CONTROLLER (YumiMASAdditions)

/**
 *	following properties return a new YumiMASViewAttribute with appropriate UILayoutGuide and NSLayoutAttribute
 */
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_topLayoutGuide;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_bottomLayoutGuide;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_topLayoutGuideTop;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_topLayoutGuideBottom;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_bottomLayoutGuideTop;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_bottomLayoutGuideBottom;

@end

#endif
