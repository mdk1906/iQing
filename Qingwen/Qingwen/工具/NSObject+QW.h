//
//  NSObject+QW.h
//  Qingwen
//
//  Created by Aimy on 7/6/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ToastType) {
    ToastTypeNormal = 0,
    ToastTypeAlert,
    ToastTypeError,
    ToastTypeNone,
};

#import <CRToast/CRToast.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (toast)

- (void)showToastWithTitle:(NSString * _Nullable)title subtitle:(NSString * _Nullable)subtitle type:(ToastType)type;
- (void)showToastWithTitle:(NSString * _Nullable)title subtitle:(NSString * _Nullable)subtitle type:(ToastType)type options:(NSDictionary * _Nullable)anOptions;

@end

@interface UIImage (tintColor)

- (UIImage * _Nullable)imageWithColor:(UIColor * _Nullable)color;
+ (UIImage * _Nullable)imageWithColor:(UIColor * _Nullable)color;
- (UIImage * _Nullable)scaleToSize:(CGSize)size;
+ (UIImage * _Nullable)imageWithSize:(CGSize)size leftColor:(UIColor *)leftColor rightColor:(UIColor *)rightColor width:(CGFloat)leftWidth;
-(CGSize)getCompressForSize:(CGFloat)defineWidth;
- (CGSize ) getCompressFitSizeScale:(CGSize)targetSize;
@end

@interface UIButton (backgroundColor)

@property (nonatomic) IBInspectable UIColor *normalBackgroundColor;
@property (nonatomic) IBInspectable UIColor *highlightBackgroundColor;
@property (nonatomic) IBInspectable UIColor *selectedBackgroundColor;
@property (nonatomic) IBInspectable UIColor *disableBackgroundColor;

@end

typedef void(^QWImageCompletionBlock)(UIImage * _Nullable image, NSError * _Nullable error, NSURL * _Nullable imageURL);

@interface UIImageView (animation)

- (void)qw_setImageName:(NSString * _Nullable)imageName animation:(BOOL)animation;
- (void)qw_setImageUrlString:(NSString * _Nullable)urlString placeholder:(UIImage * _Nullable)placeholder animation:(BOOL)animation;
- (void)qw_setImageUrlString:(NSString * _Nullable)urlString placeholder:(UIImage * _Nullable)placeholder animation:(BOOL)animation completeBlock:(QWImageCompletionBlock _Nullable)block;
- (void)qw_setImageUrlString:(NSString * _Nullable)urlString placeholder:(UIImage * _Nullable)placeholder cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor * _Nullable)borderColor animation:(BOOL)animation completeBlock:(QWImageCompletionBlock _Nullable)block;
- (void)showChangeImageAnimtion;

@end

@interface NSString (traditional)

- (NSString * _Nullable)stringWithType:(BOOL)traditional Origin:(BOOL)isOrgin;

@end

@interface NSData (base64)

- (NSString *)base64EncodedString;

@end

@interface NSObject (safe)

/**
 *  转换成nsstring－》nsnumber
 *
 *  @return NSnumber
 */
- (NSNumber * _Nullable)toNumberIfNeeded;

@end

@interface NSObject (textHeight)
//返回text高
- (CGSize)getSizeWithWidth:(CGFloat)width textString:(NSString *)textString;

@end

@interface NSString (regex)

@end

NS_ASSUME_NONNULL_END
