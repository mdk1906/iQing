//
//  YumiMASCompositeConstraint.h
//  Masonry
//
//  Created by Jonas Budelmann on 21/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "YumiMASConstraint.h"
#import "YumiMASUtilities.h"

/**
 *	A group of YumiMASConstraint objects
 */
@interface YumiMASCompositeConstraint : YumiMASConstraint

/**
 *	Creates a composite with a predefined array of children
 *
 *	@param	children	child YumiMASConstraints
 *
 *	@return	a composite constraint
 */
- (id)initWithChildren:(NSArray *)children;

@end
