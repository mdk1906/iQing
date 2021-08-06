//
//  NSObject+QW.m
//  Qingwen
//
//  Created by Aimy on 7/6/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "NSObject+QW.h"

#import <UIImageView+WebCache.h>
#import <SDWebImageManager.h>
#import <UIView+WebCacheOperation.h>

#import "OBCConvertor.h"
#import "NSObject+swizzle.h"
#import <mach/mach_time.h>
#import <YYText/YYTextLayout.h>
CGFloat BNRTimeBlock (void (^block)(void));

CGFloat BNRTimeBlock (void (^block)(void)) {
    mach_timebase_info_data_t info;
    if (mach_timebase_info(&info) != KERN_SUCCESS) return -1.0;

    uint64_t start = mach_absolute_time ();
    block ();
    uint64_t end = mach_absolute_time ();
    uint64_t elapsed = end - start;

    uint64_t nanos = elapsed * info.numer / info.denom;
    return (CGFloat)nanos / NSEC_PER_SEC;
}

@implementation NSString (iOS7_QQ_SDK)

- (BOOL)qw_containsString:(NSString *)str
{
    return [self rangeOfString:str].location != NSNotFound;
}

+ (BOOL)resolveInstanceMethod:(SEL)aSelector
{
    if (aSelector == @selector(containsString:)) {
        IMP imp = class_getMethodImplementation(self, @selector(qw_containsString:));
        class_addMethod(self, aSelector, imp, "b@:@");
        return YES;
    }

    return [super resolveInstanceMethod:aSelector];
}

@end

@implementation NSObject (toast)

- (void)showToastWithTitle:(NSString *)title subtitle:(NSString *)subtitle type:(ToastType)type
{
    [self showToastWithTitle:title subtitle:subtitle type:type options:nil];
}

- (void)showToastWithTitle:(NSString *)title subtitle:(NSString *)subtitle type:(ToastType)type options:(NSDictionary *)anOptions
{
    if (title && ![title isKindOfClass:[NSString class]]) {
        return ;
    }

    if (subtitle && ![subtitle isKindOfClass:[NSString class]]) {
        return ;
    }

    if (!title.length && !subtitle.length) {
        return ;
    }

    NSMutableDictionary *options = @{}.mutableCopy;

    if (anOptions) {
        [options setValuesForKeysWithDictionary:anOptions];
    }
    
    if (title) {
        options[kCRToastTextKey] = title;
    }

    if (subtitle) {
        options[kCRToastSubtitleTextKey] = subtitle;
    }

    switch (type) {
        case ToastTypeAlert:
            options[kCRToastTimeIntervalKey] = @1.0f;
            break;
        case ToastTypeError:
            options[kCRToastTimeIntervalKey] = @1.5f;
            break;
        default:
            break;
    }

    [CRToastManager showNotificationWithOptions:options completionBlock:nil];
}

@end

@implementation UIImage (tintColor)

- (UIImage *)imageWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, 1, 1);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)scaleToSize:(CGSize)size
{
    CGFloat height = size.width * self.size.height / self.size.width;
    size.height = height;
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0,0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage *scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    //返回新的改变大小后的图片
    return scaledImage;
}

+ (UIImage *)imageWithSize:(CGSize)size leftColor:(UIColor *)leftColor rightColor:(UIColor *)rightColor width:(CGFloat)leftWidth
{
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    {
        CGContextSaveGState(context);
        CGRect rect = CGRectMake(0, 0, leftWidth, size.height);
        [leftColor setFill];
        CGContextFillRect(context, rect);
        CGContextRestoreGState(context);
    }
    {
        CGContextSaveGState(context);
        CGRect rect = CGRectMake(leftWidth, 0, size.width - leftWidth, size.height);
        [rightColor setFill];
        CGContextFillRect(context, rect);
        CGContextRestoreGState(context);
    }
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//- (UIImage *)roundedCornerImageWithCornerRadius:(CGFloat)cornerRadius {
//    CGFloat w = self.size.width;
//    CGFloat h = self.size.height;
//    CGFloat scale = [UIScreen mainScreen].scale;
//    if (cornerRadius < 0)
//        cornerRadius = 0;
//    else if (cornerRadius > MIN(w, h))
//        cornerRadius = MIN(w, h) / 2.;
//    
//    UIImage *image = nil;
//    CGRect imageFrame = CGRectMake(0., 0., w, h);
//    UIGraphicsBeginImageContextWithOptions(self.size, NO, scale);
//    [[UIBezierPath bezierPathWithRoundedRect:imageFrame cornerRadius:cornerRadius] addClip];
//    [self drawInRect:imageFrame];
//    image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return image;
//}

- (CGSize ) getCompressFitSizeScale:(CGSize)targetSize{
    CGSize imageSize = self.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    if(CGSizeEqualToSize(imageSize, targetSize) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
            
        }
        else{
            
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
    }
    

    
    return CGSizeMake(scaledWidth, scaledHeight);
}

-(CGSize) getCompressForSize:(CGFloat)defineWidth{
    CGSize imageSize = self.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
    }
    CGSize scaledSzie = CGSizeMake(scaledWidth, scaledHeight);
    return scaledSzie;
}
@end


@implementation UIButton (backgroundColor)

- (void)setNormalBackgroundColor:(UIColor *)normalBackgroundColor
{
    [self setBackgroundImage:[UIImage imageWithColor:normalBackgroundColor] forState:UIControlStateNormal];
}

- (UIColor *)normalBackgroundColor
{
    return nil;
}

- (void)setHighlightBackgroundColor:(UIColor *)highlightBackgroundColor
{
    [self setBackgroundImage:[UIImage imageWithColor:highlightBackgroundColor] forState:UIControlStateHighlighted];
}

- (UIColor *)highlightBackgroundColor
{
    return nil;
}

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor
{
    [self setBackgroundImage:[UIImage imageWithColor:selectedBackgroundColor] forState:UIControlStateSelected];
}

- (UIColor *)selectedBackgroundColor
{
    return nil;
}

- (void)setDisableBackgroundColor:(UIColor *)disableBackgroundColor
{
    [self setBackgroundImage:[UIImage imageWithColor:disableBackgroundColor] forState:UIControlStateDisabled];
}

- (UIColor *)disableBackgroundColor
{
    return nil;
}

@end

@implementation UIImageView (animation)

- (void)qw_setImageName:(NSString *)imageName animation:(BOOL)animation
{
    self.image = [UIImage imageNamed:imageName];
    if (animation) {
        [self showChangeImageAnimtion];
    }
}

- (void)qw_setImageUrlString:(NSString *)urlString placeholder:(UIImage *)placeholder animation:(BOOL)animation
{
    [self qw_setImageUrlString:urlString placeholder:placeholder animation:animation completeBlock:nil];
}

- (void)qw_setImageUrlString:(NSString *)urlString placeholder:(UIImage *)placeholder animation:(BOOL)animation completeBlock:(QWImageCompletionBlock)block
{
    [self qw_setImageUrlString:urlString placeholder:placeholder cornerRadius:0 borderWidth:0 borderColor:nil animation:animation completeBlock:block];
}

- (void)qw_setImageUrlString:(NSString *)urlString placeholder:(UIImage *)placeholder cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor animation:(BOOL)animation completeBlock:(QWImageCompletionBlock)block
{
    WEAK_SELF;
//    NSLog(@"%@",[NSURL URLWithString:urlString]);
    [self sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:placeholder options:SDWebImageAvoidAutoSetImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        STRONG_SELF;
        if (!error && image) {
            if (cornerRadius || borderWidth || borderColor) {
                [self performInThreadBlock:^{
                    STRONG_SELF;
                    UIImage *tempImage = image;
                    tempImage = [image imageWithCornerRadius:cornerRadius * image.size.width / self.bounds.size.width borderWidth:borderWidth * image.size.width / self.bounds.size.width borderColor:borderColor];
                    [self performInMainThreadBlock:^{
                        STRONG_SELF;
                        self.image = tempImage;
                        if (cacheType == SDImageCacheTypeNone && animation) {
                            [self showChangeImageAnimtion];
                        }

                        if (block) {
                            block(image, error, imageURL);
                        }
                    }];
                }];
            }
            else {
                self.image = image;
                if (cacheType == SDImageCacheTypeNone && animation) {
                    [self showChangeImageAnimtion];
                }

                if (block) {
                    block(image, error, imageURL);
                }
            }
        }
        else {
            if (block) {
                block(image, error, imageURL);
            }
        }
    }];
}

- (void)showChangeImageAnimtion
{
    CATransition *transition = [CATransition animation];
    transition.duration = .3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    transition.type = kCATransitionFade;
    [self.layer addAnimation:transition forKey:nil];
}

@end

@implementation NSString (traditional)

- (NSString *)stringWithType:(BOOL)traditional Origin:(BOOL)isOrgin
{
    if(isOrgin){
        return self;
    }
    if (traditional) {
        return [[OBCConvertor getInstance] s2t:self];
    }

    return [[OBCConvertor getInstance] t2s:self];
}

@end

@implementation NSData (base64)

- (NSString *)base64EncodedString
{
    return [self base64EncodedStringWithWrapWidth:0];
}


- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth
{
    //ensure wrapWidth is a multiple of 4
    wrapWidth = (wrapWidth / 4) * 4;

    const char lookup[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    long long inputLength = [self length];
    const unsigned char *inputBytes = (const unsigned char *)[self bytes];

    long long maxOutputLength = (inputLength / 3 + 1) * 4;
    maxOutputLength += wrapWidth? (maxOutputLength / wrapWidth) * 2: 0;
    unsigned char *outputBytes = (unsigned char *)malloc((size_t)maxOutputLength);

    long long i;
    long long outputLength = 0;
    for (i = 0; i < inputLength - 2; i += 3)
    {
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[((inputBytes[i] & 0x03) << 4) | ((inputBytes[i + 1] & 0xF0) >> 4)];
        outputBytes[outputLength++] = lookup[((inputBytes[i + 1] & 0x0F) << 2) | ((inputBytes[i + 2] & 0xC0) >> 6)];
        outputBytes[outputLength++] = lookup[inputBytes[i + 2] & 0x3F];

        //add line break
        if (wrapWidth && (outputLength + 2) % (wrapWidth + 2) == 0)
        {
            outputBytes[outputLength++] = '\r';
            outputBytes[outputLength++] = '\n';
        }
    }

    //handle left-over data
    if (i == inputLength - 2)
    {
        // = terminator
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[((inputBytes[i] & 0x03) << 4) | ((inputBytes[i + 1] & 0xF0) >> 4)];
        outputBytes[outputLength++] = lookup[(inputBytes[i + 1] & 0x0F) << 2];
        outputBytes[outputLength++] =   '=';
    }
    else if (i == inputLength - 1)
    {
        // == terminator
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0x03) << 4];
        outputBytes[outputLength++] = '=';
        outputBytes[outputLength++] = '=';
    }

    if (outputLength >= 4)
    {
        //truncate data to match actual output length
        outputBytes = (unsigned char *)realloc(outputBytes, (size_t)outputLength);
        return [[NSString alloc] initWithBytesNoCopy:outputBytes
                                              length:(NSUInteger)outputLength
                                            encoding:NSASCIIStringEncoding
                                        freeWhenDone:YES];
    }
    else if (outputBytes)
    {
        free(outputBytes);
    }
    return nil;
}

@end

@implementation NSObject (safe)

- (NSNumber *)toNumberIfNeeded
{
    if ([self isKindOfClass:[NSNumber class]]) {
        return (NSNumber *)self;
    }

    if ([self isKindOfClass:[NSString class]]) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterNoStyle;
        NSNumber *myNumber = [f numberFromString:(NSString *)self];
        return myNumber;
    }

    return nil;
}

@end

@interface UIAlertController (supportedInterfaceOrientations)

@end

@implementation UIAlertController (supportedInterfaceOrientations)

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations; {
    return UIInterfaceOrientationMaskPortrait;
}
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
#endif

@end

@implementation NSObject (textHeight)


- (CGSize)getSizeWithWidth:(CGFloat)width textString:(NSString *)textString {
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:textString attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17]}];
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(width, CGFLOAT_MAX) text:attributedStr];
    
    return layout.textBoundingSize;
}

@end
