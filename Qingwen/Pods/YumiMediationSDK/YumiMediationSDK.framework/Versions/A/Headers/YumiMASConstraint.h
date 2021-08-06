//
//  YumiMASConstraint.h
//  Masonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "YumiMASUtilities.h"

/**
 *	Enables Constraints to be created with chainable syntax
 *  Constraint can represent single NSLayoutConstraint (YumiMASViewConstraint)
 *  or a group of NSLayoutConstraints (YumiMASComposisteConstraint)
 */
@interface YumiMASConstraint : NSObject

// Chaining Support

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects YumiMASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (YumiMASConstraint * (^)(YumiMASEdgeInsets insets))insets;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects YumiMASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (YumiMASConstraint * (^)(CGFloat inset))inset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects YumiMASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeWidth, NSLayoutAttributeHeight
 */
- (YumiMASConstraint * (^)(CGSize offset))sizeOffset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects YumiMASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeCenterX, NSLayoutAttributeCenterY
 */
- (YumiMASConstraint * (^)(CGPoint offset))centerOffset;

/**
 *	Modifies the NSLayoutConstraint constant
 */
- (YumiMASConstraint * (^)(CGFloat offset))offset;

/**
 *  Modifies the NSLayoutConstraint constant based on a value type
 */
- (YumiMASConstraint * (^)(NSValue *value))valueOffset;

/**
 *	Sets the NSLayoutConstraint multiplier property
 */
- (YumiMASConstraint * (^)(CGFloat multiplier))multipliedBy;

/**
 *	Sets the NSLayoutConstraint multiplier to 1.0/dividedBy
 */
- (YumiMASConstraint * (^)(CGFloat divider))dividedBy;

/**
 *	Sets the NSLayoutConstraint priority to a float or YumiMASLayoutPriority
 */
- (YumiMASConstraint * (^)(YumiMASLayoutPriority priority))priority;

/**
 *	Sets the NSLayoutConstraint priority to YumiMASLayoutPriorityLow
 */
- (YumiMASConstraint * (^)())priorityLow;

/**
 *	Sets the NSLayoutConstraint priority to YumiMASLayoutPriorityMedium
 */
- (YumiMASConstraint * (^)())priorityMedium;

/**
 *	Sets the NSLayoutConstraint priority to YumiMASLayoutPriorityHigh
 */
- (YumiMASConstraint * (^)())priorityHigh;

/**
 *	Sets the constraint relation to NSLayoutRelationEqual
 *  returns a block which accepts one of the following:
 *    YumiMASViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (YumiMASConstraint * (^)(id attr))equalTo;

/**
 *	Sets the constraint relation to NSLayoutRelationGreaterThanOrEqual
 *  returns a block which accepts one of the following:
 *    YumiMASViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (YumiMASConstraint * (^)(id attr))greaterThanOrEqualTo;

/**
 *	Sets the constraint relation to NSLayoutRelationLessThanOrEqual
 *  returns a block which accepts one of the following:
 *    YumiMASViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (YumiMASConstraint * (^)(id attr))lessThanOrEqualTo;

/**
 *	Optional semantic property which has no effect but improves the readability of constraint
 */
- (YumiMASConstraint *)with;

/**
 *	Optional semantic property which has no effect but improves the readability of constraint
 */
- (YumiMASConstraint *)and;

/**
 *	Creates a new YumiMASCompositeConstraint with the called attribute and reciever
 */
- (YumiMASConstraint *)left;
- (YumiMASConstraint *)top;
- (YumiMASConstraint *)right;
- (YumiMASConstraint *)bottom;
- (YumiMASConstraint *)leading;
- (YumiMASConstraint *)trailing;
- (YumiMASConstraint *)width;
- (YumiMASConstraint *)height;
- (YumiMASConstraint *)centerX;
- (YumiMASConstraint *)centerY;
- (YumiMASConstraint *)baseline;

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) ||                           \
    (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

- (YumiMASConstraint *)firstBaseline;
- (YumiMASConstraint *)lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

- (YumiMASConstraint *)leftMargin;
- (YumiMASConstraint *)rightMargin;
- (YumiMASConstraint *)topMargin;
- (YumiMASConstraint *)bottomMargin;
- (YumiMASConstraint *)leadingMargin;
- (YumiMASConstraint *)trailingMargin;
- (YumiMASConstraint *)centerXWithinMargins;
- (YumiMASConstraint *)centerYWithinMargins;

#endif

/**
 *	Sets the constraint debug name
 */
- (YumiMASConstraint * (^)(id key))key;

// NSLayoutConstraint constant Setters
// for use outside of mas_updateConstraints/mas_makeConstraints blocks

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects YumiMASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (void)setInsets:(YumiMASEdgeInsets)insets;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects YumiMASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (void)setInset:(CGFloat)inset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects YumiMASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeWidth, NSLayoutAttributeHeight
 */
- (void)setSizeOffset:(CGSize)sizeOffset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects YumiMASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeCenterX, NSLayoutAttributeCenterY
 */
- (void)setCenterOffset:(CGPoint)centerOffset;

/**
 *	Modifies the NSLayoutConstraint constant
 */
- (void)setOffset:(CGFloat)offset;

// NSLayoutConstraint Installation support

#if TARGET_OS_MAC && !(TARGET_OS_IPHONE || TARGET_OS_TV)
/**
 *  Whether or not to go through the animator proxy when modifying the constraint
 */
@property (nonatomic, copy, readonly) YumiMASConstraint *animator;
#endif

/**
 *  Activates an NSLayoutConstraint if it's supported by an OS.
 *  Invokes install otherwise.
 */
- (void)activate;

/**
 *  Deactivates previously installed/activated NSLayoutConstraint.
 */
- (void)deactivate;

/**
 *	Creates a NSLayoutConstraint and adds it to the appropriate view.
 */
- (void)install;

/**
 *	Removes previously installed NSLayoutConstraint
 */
- (void)uninstall;

@end

/**
 *  Convenience auto-boxing macros for YumiMASConstraint methods.
 *
 *  Defining YumiMAS_SHORTHAND_GLOBALS will turn on auto-boxing for default syntax.
 *  A potential drawback of this is that the unprefixed macros will appear in global scope.
 */
#define mas_equalTo(...) equalTo(YumiMASBoxValue((__VA_ARGS__)))
#define mas_greaterThanOrEqualTo(...) greaterThanOrEqualTo(YumiMASBoxValue((__VA_ARGS__)))
#define mas_lessThanOrEqualTo(...) lessThanOrEqualTo(YumiMASBoxValue((__VA_ARGS__)))

#define mas_offset(...) valueOffset(YumiMASBoxValue((__VA_ARGS__)))

#ifdef YumiMAS_SHORTHAND_GLOBALS

#define equalTo(...) mas_equalTo(__VA_ARGS__)
#define greaterThanOrEqualTo(...) mas_greaterThanOrEqualTo(__VA_ARGS__)
#define lessThanOrEqualTo(...) mas_lessThanOrEqualTo(__VA_ARGS__)

#define offset(...) mas_offset(__VA_ARGS__)

#endif

@interface YumiMASConstraint (AutoboxingSupport)

/**
 *  Aliases to corresponding relation methods (for shorthand macros)
 *  Also needed to aid autocompletion
 */
- (YumiMASConstraint * (^)(id attr))mas_equalTo;
- (YumiMASConstraint * (^)(id attr))mas_greaterThanOrEqualTo;
- (YumiMASConstraint * (^)(id attr))mas_lessThanOrEqualTo;

/**
 *  A dummy method to aid autocompletion
 */
- (YumiMASConstraint * (^)(id offset))mas_offset;

@end
