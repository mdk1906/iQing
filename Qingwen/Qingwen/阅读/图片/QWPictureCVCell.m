//
//  QWPictureCVCell.m
//  Qingwen
//
//  Created by Aimy on 7/4/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWPictureCVCell.h"

#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "QWFileManager.h"
#import "QWEmptyView.h"
#import "QWInterface.h"
#import "QWReadingConfig.h"

@interface QWPictureCVCell () <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet QWEmptyView *emptyView;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, copy) NSString *url;

@end

@implementation QWPictureCVCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.emptyView.useDark = YES;
    self.emptyView.configFrameManual = YES;

    self.imageView = [UIImageView new];
    [self.scrollView addSubview:self.imageView];
}

- (void)updateImageWithUrl:(NSString *)url bookId:(NSString *)bookId volumeId:(NSString *)volumeId chapterId:(NSString *)chapterId
{
    if (self.url != url) {
        [self.task cancel];
    }

    CGSize size = CGSizeMake([QWSize screenWidth:[QWReadingConfig sharedInstance].landscape], [QWSize screenHeight:[QWReadingConfig sharedInstance].landscape]);

    self.scrollView.contentSize = size;

    self.url = url;

    self.imageView.frame = CGRectZero;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.zoomScale = 1.0;
    self.imageView.image = nil;

    NSString *filePathStr = [QWFileManager imagePathWithBookId:bookId volumeId:volumeId chapterId:chapterId imageName:url];

    if (filePathStr.length && [QWFileManager isFileExistWithFileUrl:filePathStr]) {
        self.imageView.image = [[UIImage alloc] initWithContentsOfFile:filePathStr];
        CGSize imageViewSize = self.imageView.image.size;
        CGSize scrollViewSize = size;
        CGFloat widthScale = scrollViewSize.width / imageViewSize.width;
        CGFloat heightScale = scrollViewSize.height / imageViewSize.height;
        if (isnan(widthScale) || isnan(heightScale)) {
            return;
        }
        self.imageView.frame = CGRectInset(CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height), 1, 1);
        self.scrollView.minimumZoomScale = MIN(widthScale, heightScale);
        self.scrollView.zoomScale = MIN(widthScale, heightScale);
    }
    else {
        WEAK_SELF;
        self.emptyView.hidden = NO;
        [self.imageView qw_setImageUrlString:[QWConvertImageString convertPicURL:url imageSizeType:QWImageSizeTypeIllustration] placeholder:nil animation:YES completeBlock:^(UIImage *image, NSError *error, NSURL *imageURL) {
            STRONG_SELF;
            NSLog(@"%@",url);

#ifndef DEBUG
            if (error.code == 404) {//图片不存在导致
                StatisticVO *statistic = [StatisticVO new];
                statistic.bookId = bookId;
                statistic.volumeId = volumeId;
                statistic.chapterId = chapterId;
                statistic.imageUrl = url;
                [[BaiduMobStat defaultStat] logEvent:@"image404" eventLabel:statistic.toJSONString];
            }
#endif

            if (!image) {//没有图片
                self.emptyView.showError = YES;
                return ;
            }

            CGSize imageViewSize = image.size;
            if (CGSizeEqualToSize(imageViewSize, CGSizeZero)) {//图片为空
                self.emptyView.showError = YES;
                return;
            }

            self.emptyView.hidden = YES;

            self.imageView.image = image;
            [self.imageView showChangeImageAnimtion];

            CGSize scrollViewSize = size;
            CGFloat widthScale = scrollViewSize.width / imageViewSize.width;
            CGFloat heightScale = scrollViewSize.height / imageViewSize.height;
            if (isnan(widthScale) || isnan(heightScale)) {
                return;
            }
            self.imageView.frame = CGRectInset(CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height), 1, 1);
            self.scrollView.minimumZoomScale = MIN(widthScale, heightScale);
            self.scrollView.zoomScale = MIN(widthScale, heightScale);
        }];
    }
}

- (void)rotateImage
{
    if (!self.imageView.image) {
        return ;
    }

    self.imageView.frame = CGRectZero;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.zoomScale = 1.0;
    
    self.imageView.image = [self rotateImage:self.imageView.image orientation:UIImageOrientationLeft];
    CGSize imageViewSize = self.imageView.image.size;
    CGSize scrollViewSize = CGSizeMake(UISCREEN_WIDTH - 1, UISCREEN_HEIGHT - 1);
    CGFloat widthScale = scrollViewSize.width / imageViewSize.width;
    CGFloat heightScale = scrollViewSize.height / imageViewSize.height;
    if (isnan(widthScale) || isnan(heightScale)) {
        return;
    }
    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    self.scrollView.minimumZoomScale = MIN(widthScale, heightScale);
    self.scrollView.zoomScale = MIN(widthScale, heightScale);
}

- (UIImage *)rotateImage:(UIImage *)aImage orientation:(UIImageOrientation)orientation
{
    CGImageRef imgRef = aImage.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGFloat scaleRatio = 1;
    CGFloat boundHeight;
    UIImageOrientation orient = orientation;

    switch(orient)
    {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(width, height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            break;
    }

    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageCopy;
}


- (void)saveImageToDisk
{
    [self saveImageToPhotos:self.imageView.image];
}

- (void)saveImageToPhotos:(UIImage *)image
{
    [self.window showLoadingWithMessage:@"正在保存"];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    WEAK_SELF;
    [library saveImage:image toAlbum:@"轻文" withCompletionBlock:^(NSError *error) {
        STRONG_SELF;
        [self.window hideLoading];
        if (! error) {
            [self.window showLoadingWithMessage:@"保存成功" hideAfter:1.0];
        }
    }];
}

#pragma mark - uiscroll delegate

 -(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGSize imageViewSize = self.imageView.frame.size;

    CGSize size = CGSizeMake([QWSize screenWidth:[QWReadingConfig sharedInstance].landscape], [QWSize screenHeight:[QWReadingConfig sharedInstance].landscape]);
    CGSize scrollViewSize = size;

    CGFloat verticalPadding = (imageViewSize.height < scrollViewSize.height) ? (scrollViewSize.height - imageViewSize.height) / 2 : 0;
    CGFloat horizontalPadding = (imageViewSize.width < scrollViewSize.width) ? (scrollViewSize.width - imageViewSize.width) / 2 : 0;

    scrollView.contentInset = UIEdgeInsetsMake(verticalPadding, horizontalPadding, verticalPadding, horizontalPadding);
}

@end
