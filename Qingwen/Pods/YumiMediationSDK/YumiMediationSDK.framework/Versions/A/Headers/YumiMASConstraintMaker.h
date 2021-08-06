//
//  YumiMASConstraintBuilder.h
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "YumiMASConstraint.h"
#import "YumiMASUtilities.h"

typedef NS_OPTIONS(NSInteger, YumiMASAttribute) {
    YumiMASAttributeLeft = 1 << NSLayoutAttributeLeft,
    YumiMASAttributeRight = 1 << NSLayoutAttributeRight,
    YumiMASAttributeTop = 1 << NSLayoutAttributeTop,
    YumiMASAttributeBottom = 1 << NSLayoutAttributeBottom,
    YumiMASAttributeLeading = 1 << NSLayoutAttributeLeading,
    YumiMASAttributeTrailing = 1 << NSLayoutAttributeTrailing,
    YumiMASAttributeWidth = 1 << NSLayoutAttributeWidth,
    YumiMASAttributeHeight = 1 << NSLayoutAttributeHeight,
    YumiMASAttributeCenterX = 1 << NSLayoutAttributeCenterX,
    YumiMASAttributeCenterY = 1 << NSLayoutAttributeCenterY,
    YumiMASAttributeBaseline = 1 << NSLayoutAttributeBaseline,

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) ||                           \
    (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

    YumiMASAttributeFirstBaseline = 1 << NSLayoutAttributeFirstBaseline,
    YumiMASAttributeLastBaseline = 1 << NSLayoutAttributeLastBaseline,

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

    YumiMASAttributeLeftMargin = 1 << NSLayoutAttributeLeftMargin,
    YumiMASAttributeRightMargin = 1 << NSLayoutAttributeRightMargin,
    YumiMASAttributeTopMargin = 1 << NSLayoutAttributeTopMargin,
    YumiMASAttributeBottomMargin = 1 << NSLayoutAttributeBottomMargin,
    YumiMASAttributeLeadingMargin = 1 << NSLayoutAttributeLeadingMargin,
    YumiMASAttributeTrailingMargin = 1 << NSLayoutAttributeTrailingMargin,
    YumiMASAttributeCenterXWithinMargins = 1 << NSLayoutAttributeCenterXWithinMargins,
    YumiMASAttributeCenterYWithinMargins = 1 << NSLayoutAttributeCenterYWithinMargins,

#endif

};

/**
 *  Provides factory methods for creating YumiMASConstraints.
 *  Constraints are collected until they are ready to be installed
 *
 */
@interface YumiMASConstraintMaker : NSObject

/**
 *	The following properties return a new YumiMASViewConstraint
 *  with the first item set to the makers associated view and the appropriate YumiMASViewAttribute
 */
@property (nonatomic, strong, readonly) YumiMASConstraint *left;
@property (nonatomic, strong, readonly) YumiMASConstraint *top;
@property (nonatomic, strong, readonly) YumiMASConstraint *right;
@property (nonatomic, strong, readonly) YumiMASConstraint *bottom;
@property (nonatomic, strong, readonly) YumiMASConstraint *leading;
@property (nonatomic, strong, readonly) YumiMASConstraint *trailing;
@property (nonatomic, strong, readonly) YumiMASConstraint *width;
@property (nonatomic, strong, readonly) YumiMASConstraint *height;
@property (nonatomic, strong, readonly) YumiMASConstraint *centerX;
@property (nonatomic, strong, readonly) YumiMASConstraint *centerY;
@property (nonatomic, strong, readonly) YumiMASConstraint *baseline;

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) ||                           \
    (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) YumiMASConstraint *firstBaseline;
@property (nonatomic, strong, readonly) YumiMASConstraint *lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) YumiMASConstraint *leftMargin;
@property (nonatomic, strong, readonly) YumiMASConstraint *rightMargin;
@property (nonatomic, strong, readonly) YumiMASConstraint *topMargin;
@property (nonatomic, strong, readonly) YumiMASConstraint *bottomMargin;
@property (nonatomic, strong, readonly) YumiMASConstraint *leadingMargin;
@property (nonatomic, strong, readonly) YumiMASConstraint *trailingMargin;
@property (nonatomic, strong, readonly) YumiMASConstraint *centerXWithinMargins;
@property (nonatomic, strong, readonly) YumiMASConstraint *centerYWithinMargins;

#endif

/**
 *  Returns a block which creates a new YumiMASCompositeConstraint with the first item set
 *  to the makers associated view and children corresponding to the set bits in the
 *  YumiMASAttribute parameter. Combine multiple attributes via binary-or.
 */
@property (nonatomic, strong, readonly) YumiMASConstraint * (^attributes)(YumiMASAttribute attrs);

/**
 *	Creates a YumiMASCompositeConstraint with type YumiMASCompositeConstraintTypeEdges
 *  which generates the appropriate YumiMASViewConstraint children (top, left, bottom, right)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) YumiMASConstraint *edges;

/**
 *	Creates a YumiMASCompositeConstraint with type YumiMASCompositeConstraintTypeSize
 *  which generates the appropriate YumiMASViewConstraint children (width, height)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) YumiMASConstraint *size;

/**
 *	Creates a YumiMASCompositeConstraint with type YumiMASCompositeConstraintTypeCenter
 *  which generates the appropriate YumiMASViewConstraint children (centerX, centerY)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) YumiMASConstraint *center;

/**
 *  Whether or not to check for an existing constraint instead of adding constraint
 */
@property (nonatomic, assign) BOOL updateExisting;

/**
 *  Whether or not to remove existing constraints prior to installing
 */
@property (nonatomic, assign) BOOL removeExisting;

/**
 *	initialises the maker with a default view
 *
 *	@param	view	any YumiMASConstrait are created with this view as the first item
 *
 *	@return	a new YumiMASConstraintMaker
 */
- (id)initWithView:(YumiMAS_VIEW *)view;

/**
 *	Calls install method on any YumiMASConstraints which have been created by this maker
 *
 *	@return	an array of all the installed YumiMASConstraints
 */
- (NSArray *)install;

- (YumiMASConstraint * (^)(dispatch_block_t))group;

@end
