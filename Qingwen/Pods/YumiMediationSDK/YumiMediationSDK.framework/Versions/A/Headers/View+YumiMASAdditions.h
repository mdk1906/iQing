//
//  UIView+YumiMASAdditions.h
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "YumiMASConstraintMaker.h"
#import "YumiMASUtilities.h"
#import "YumiMASViewAttribute.h"

/**
 *	Provides constraint maker block
 *  and convience methods for creating YumiMASViewAttribute which are view + NSLayoutAttribute pairs
 */
@interface YumiMAS_VIEW (YumiMASAdditions)

/**
 *	following properties return a new YumiMASViewAttribute with current view and appropriate NSLayoutAttribute
 */
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_left;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_top;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_right;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_bottom;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_leading;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_trailing;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_width;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_height;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_centerX;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_centerY;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_baseline;
@property (nonatomic, strong, readonly) YumiMASViewAttribute * (^mas_attribute)(NSLayoutAttribute attr);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) ||                           \
    (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_firstBaseline;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_leftMargin;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_rightMargin;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_topMargin;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_bottomMargin;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_leadingMargin;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_trailingMargin;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_centerXWithinMargins;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *mas_centerYWithinMargins;

#endif

/**
 *	a key to associate with this view
 */
@property (nonatomic, strong) id mas_key;

/**
 *	Finds the closest common superview between this view and another view
 *
 *	@param	view	other view
 *
 *	@return	returns nil if common superview could not be found
 */
- (instancetype)mas_closestCommonSuperview:(YumiMAS_VIEW *)view;

/**
 *  Creates a YumiMASConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created YumiMASConstraints
 */
- (NSArray *)mas_makeConstraints:(void(NS_NOESCAPE ^)(YumiMASConstraintMaker *make))block;

/**
 *  Creates a YumiMASConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing.
 *  If an existing constraint exists then it will be updated instead.
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created/updated YumiMASConstraints
 */
- (NSArray *)mas_updateConstraints:(void(NS_NOESCAPE ^)(YumiMASConstraintMaker *make))block;

/**
 *  Creates a YumiMASConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing.
 *  All constraints previously installed for the view will be removed.
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created/updated YumiMASConstraints
 */
- (NSArray *)mas_remakeConstraints:(void(NS_NOESCAPE ^)(YumiMASConstraintMaker *make))block;

@end
