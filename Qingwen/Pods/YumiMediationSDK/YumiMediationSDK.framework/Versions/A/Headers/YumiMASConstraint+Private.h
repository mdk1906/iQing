//
//  YumiMASConstraint+Private.h
//  Masonry
//
//  Created by Nick Tymchenko on 29/04/14.
//  Copyright (c) 2014 cloudling. All rights reserved.
//

#import "YumiMASConstraint.h"

@protocol YumiMASConstraintDelegate;

@interface YumiMASConstraint ()

/**
 *  Whether or not to check for an existing constraint instead of adding constraint
 */
@property (nonatomic, assign) BOOL updateExisting;

/**
 *	Usually YumiMASConstraintMaker but could be a parent YumiMASConstraint
 */
@property (nonatomic, weak) id<YumiMASConstraintDelegate> delegate;

/**
 *  Based on a provided value type, is equal to calling:
 *  NSNumber - setOffset:
 *  NSValue with CGPoint - setPointOffset:
 *  NSValue with CGSize - setSizeOffset:
 *  NSValue with YumiMASEdgeInsets - setInsets:
 */
- (void)setLayoutConstantWithValue:(NSValue *)value;

@end

@interface YumiMASConstraint (Abstract)

/**
 *	Sets the constraint relation to given NSLayoutRelation
 *  returns a block which accepts one of the following:
 *    YumiMASViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (YumiMASConstraint * (^)(id, NSLayoutRelation))equalToWithRelation;

/**
 *	Override to set a custom chaining behaviour
 */
- (YumiMASConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute;

@end

@protocol YumiMASConstraintDelegate <NSObject>

/**
 *	Notifies the delegate when the constraint needs to be replaced with another constraint. For example
 *  A YumiMASViewConstraint may turn into a YumiMASCompositeConstraint when an array is passed to one of the equality
 *blocks
 */
- (void)constraint:(YumiMASConstraint *)constraint
    shouldBeReplacedWithConstraint:(YumiMASConstraint *)replacementConstraint;

- (YumiMASConstraint *)constraint:(YumiMASConstraint *)constraint
    addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute;

@end
