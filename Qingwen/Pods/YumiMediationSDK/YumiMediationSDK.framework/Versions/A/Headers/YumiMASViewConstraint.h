//
//  YumiMASConstraint.h
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "YumiMASConstraint.h"
#import "YumiMASLayoutConstraint.h"
#import "YumiMASUtilities.h"
#import "YumiMASViewAttribute.h"

/**
 *  A single constraint.
 *  Contains the attributes neccessary for creating a NSLayoutConstraint and adding it to the appropriate view
 */
@interface YumiMASViewConstraint : YumiMASConstraint <NSCopying>

/**
 *	First item/view and first attribute of the NSLayoutConstraint
 */
@property (nonatomic, strong, readonly) YumiMASViewAttribute *firstViewAttribute;

/**
 *	Second item/view and second attribute of the NSLayoutConstraint
 */
@property (nonatomic, strong, readonly) YumiMASViewAttribute *secondViewAttribute;

/**
 *	initialises the YumiMASViewConstraint with the first part of the equation
 *
 *	@param	firstViewAttribute	view.mas_left, view.mas_width etc.
 *
 *	@return	a new view constraint
 */
- (id)initWithFirstViewAttribute:(YumiMASViewAttribute *)firstViewAttribute;

/**
 *  Returns all YumiMASViewConstraints installed with this view as a first item.
 *
 *  @param  view  A view to retrieve constraints for.
 *
 *  @return An array of YumiMASViewConstraints.
 */
+ (NSArray *)installedConstraintsForView:(YumiMAS_VIEW *)view;

@end
