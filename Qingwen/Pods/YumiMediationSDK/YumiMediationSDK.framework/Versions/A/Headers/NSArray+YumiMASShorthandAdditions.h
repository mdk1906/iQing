//
//  NSArray+YumiMASShorthandAdditions.h
//  Masonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "NSArray+YumiMASAdditions.h"

#ifdef YumiMAS_SHORTHAND

/**
 *	Shorthand array additions without the 'mas_' prefixes,
 *  only enabled if YumiMAS_SHORTHAND is defined
 */
@interface NSArray (YumiMASShorthandAdditions)

- (NSArray *)makeConstraints:(void (^)(YumiMASConstraintMaker *make))block;
- (NSArray *)updateConstraints:(void (^)(YumiMASConstraintMaker *make))block;
- (NSArray *)remakeConstraints:(void (^)(YumiMASConstraintMaker *make))block;

@end

@implementation NSArray (YumiMASShorthandAdditions)

- (NSArray *)makeConstraints:(void (^)(YumiMASConstraintMaker *))block {
    return [self mas_makeConstraints:block];
}

- (NSArray *)updateConstraints:(void (^)(YumiMASConstraintMaker *))block {
    return [self mas_updateConstraints:block];
}

- (NSArray *)remakeConstraints:(void (^)(YumiMASConstraintMaker *))block {
    return [self mas_remakeConstraints:block];
}

@end

#endif
