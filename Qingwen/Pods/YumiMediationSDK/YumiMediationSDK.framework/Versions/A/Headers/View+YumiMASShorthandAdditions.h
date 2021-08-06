//
//  UIView+YumiMASShorthandAdditions.h
//  Masonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "View+YumiMASAdditions.h"

#ifdef YumiMAS_SHORTHAND

/**
 *	Shorthand view additions without the 'mas_' prefixes,
 *  only enabled if YumiMAS_SHORTHAND is defined
 */
@interface YumiMAS_VIEW (YumiMASShorthandAdditions)

@property (nonatomic, strong, readonly) YumiMASViewAttribute *left;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *top;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *right;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *bottom;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *leading;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *trailing;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *width;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *height;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *centerX;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *centerY;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *baseline;
@property (nonatomic, strong, readonly) YumiMASViewAttribute * (^attribute)(NSLayoutAttribute attr);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) ||                           \
    (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) YumiMASViewAttribute *firstBaseline;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) YumiMASViewAttribute *leftMargin;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *rightMargin;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *topMargin;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *bottomMargin;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *leadingMargin;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *trailingMargin;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *centerXWithinMargins;
@property (nonatomic, strong, readonly) YumiMASViewAttribute *centerYWithinMargins;

#endif

- (NSArray *)makeConstraints:(void (^)(YumiMASConstraintMaker *make))block;
- (NSArray *)updateConstraints:(void (^)(YumiMASConstraintMaker *make))block;
- (NSArray *)remakeConstraints:(void (^)(YumiMASConstraintMaker *make))block;

@end

#define YumiMAS_ATTR_FORWARD(attr)                                                                                     \
    -(YumiMASViewAttribute *)attr {                                                                                    \
        return [self mas_##attr];                                                                                      \
    }

@implementation YumiMAS_VIEW (YumiMASShorthandAdditions)

YumiMAS_ATTR_FORWARD(top);
YumiMAS_ATTR_FORWARD(left);
YumiMAS_ATTR_FORWARD(bottom);
YumiMAS_ATTR_FORWARD(right);
YumiMAS_ATTR_FORWARD(leading);
YumiMAS_ATTR_FORWARD(trailing);
YumiMAS_ATTR_FORWARD(width);
YumiMAS_ATTR_FORWARD(height);
YumiMAS_ATTR_FORWARD(centerX);
YumiMAS_ATTR_FORWARD(centerY);
YumiMAS_ATTR_FORWARD(baseline);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) ||                           \
    (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

YumiMAS_ATTR_FORWARD(firstBaseline);
YumiMAS_ATTR_FORWARD(lastBaseline);

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

YumiMAS_ATTR_FORWARD(leftMargin);
YumiMAS_ATTR_FORWARD(rightMargin);
YumiMAS_ATTR_FORWARD(topMargin);
YumiMAS_ATTR_FORWARD(bottomMargin);
YumiMAS_ATTR_FORWARD(leadingMargin);
YumiMAS_ATTR_FORWARD(trailingMargin);
YumiMAS_ATTR_FORWARD(centerXWithinMargins);
YumiMAS_ATTR_FORWARD(centerYWithinMargins);

#endif

- (YumiMASViewAttribute * (^)(NSLayoutAttribute))attribute {
    return [self mas_attribute];
}

- (NSArray *)makeConstraints:(void(NS_NOESCAPE ^)(YumiMASConstraintMaker *))block {
    return [self mas_makeConstraints:block];
}

- (NSArray *)updateConstraints:(void(NS_NOESCAPE ^)(YumiMASConstraintMaker *))block {
    return [self mas_updateConstraints:block];
}

- (NSArray *)remakeConstraints:(void(NS_NOESCAPE ^)(YumiMASConstraintMaker *))block {
    return [self mas_remakeConstraints:block];
}

@end

#endif
