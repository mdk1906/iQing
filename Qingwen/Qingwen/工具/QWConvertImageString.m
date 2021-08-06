//
//  QWConvertImageString.m
//  Qingwen
//
//  Created by Aimy on 7/11/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWConvertImageString.h"

//支持phone pad
#define kMaxImageWidth  1024
#define kMaxImageHeight 1024

@implementation QWConvertImageString

+ (NSString *)convertPicURL:(NSString *)picURL toSize:(CGSize)size
{
    return [self convertPicURL:picURL viewWidth:size.width viewHeight:size.height];
}

+ (NSString *)convertPicURL:(NSString *)picURL
                  viewWidth:(NSInteger)aWidth
                 viewHeight:(NSInteger)aHeight
{
    if (aWidth > kMaxImageWidth) {
        aWidth = kMaxImageWidth;
    }
    if (aHeight > kMaxImageHeight) {
        aHeight = kMaxImageHeight;
    }

    NSString *sizeString = [NSString stringWithFormat:@"@%ldw_%ldh_90Q", (long)(aWidth * [[UIScreen mainScreen] scale]), (long)(aHeight * [[UIScreen mainScreen] scale])];

    return [self convertPicURL:picURL toSizeFormat:sizeString];
}

+ (NSString *)convertPicURL:(NSString *)picURL toSizeFormat:(NSString *)sizeStr
{
    if (!picURL) {
        return nil;
    }

    if (!sizeStr) {
        return picURL;
    }

    static NSRegularExpression *serviceRE = nil, *extRE = nil;

    if (!extRE) {
        //后缀
        extRE = [NSRegularExpression regularExpressionWithPattern:@".(jpg|jpeg|webp|png|bmp)$" options:0 error:nil];
    }

    if (!serviceRE) {
        //设置服务器url正则表达式
        serviceRE = [NSRegularExpression regularExpressionWithPattern:@"^http://raichu.iqing.in/" options:0 error:nil];
    }

    //获取服务器range
    NSRange serviceRange = [[serviceRE firstMatchInString:picURL options:0 range:NSMakeRange(0, [picURL length])] rangeAtIndex:0];
    NSRange extRange = [[extRE firstMatchInString:picURL options:0 range:NSMakeRange(0, picURL.length)] rangeAtIndex:0];

    //处理
    if(serviceRange.length > 0 && extRange.length > 0) {
        // 给的图片url加上大小字段
        NSString *extString = [picURL substringWithRange:extRange];
        return [NSString stringWithFormat:@"%@%@%@", picURL, sizeStr, extString];
    }
    else {
        // 不由可变的图片服务器提供
        return picURL;
    }
}

+ (NSString *)convertPicURL:(NSString *)picURL imageSizeType:(QWImageSizeType)type
{
    if (picURL == nil) {
        
    }else{
        NSMutableString *picURLNew = [[NSMutableString alloc]initWithString:picURL];
        if ([picURL rangeOfString:@"https://image.iqing.in/"].location !=NSNotFound) {
            picURL = [picURLNew stringByReplacingOccurrencesOfString:@"https://image.iqing.in/" withString:@"https://new-image.iqing.com/"];
        }
        else if ([picURL rangeOfString:@"https://image.iqing.com/"].location !=NSNotFound){
            picURL = [picURLNew stringByReplacingOccurrencesOfString:@"https://image.iqing.com/" withString:@"https://new-image.iqing.com/"];
        }
        else if ([picURL rangeOfString:@"https://dn-image-iqing.qbox.me/"].location !=NSNotFound){
            picURL = [picURLNew stringByReplacingOccurrencesOfString:@"https://dn-image-iqing.qbox.me/" withString:@"https://new-image.iqing.com/"];
        }
        else{
            
        }
    }
    
//    NSLog(@"picUrl1234 /5 = %@",picURL);
    NSString *typeString = @"";
    switch (type) {
        case QWImageSizeTypeRecommend: {
//            typeString = @"recommend";
//            typeString = @"imageMogr2/auto-orient/thumbnail/384x384/format/webp";
            typeString =@"x-oss-process=image/auto-orient,1/resize,m_lfit,w_384,h_384/format,webp";
            break;
        }
        case QWImageSizeTypePromotion: {
//            typeString = @"promotion";
//            typeString = @"imageMogr2/auto-orient/thumbnail/1020x300/format/webp";
            typeString =@"x-oss-process=image/auto-orient,1/resize,m_lfit,w_1020,h_300/format,webp";
            break;
        }
        case QWImageSizeTypeAvatar: {
//            typeString = @"avatar";
//            typeString = @"imageMogr2/auto-orient/thumbnail/384x384!/format/webp";
            typeString =@"x-oss-process=image/auto-orient,1/resize,m_fixed,w_384,h_384/format,webp";

            break;
        }
        case QWImageSizeTypeAvatarThumbnail: {
//            typeString = @"avatarThumbnail";
//            typeString = @"imageMogr2/auto-orient/thumbnail/384x384/format/webp";
            typeString =@"x-oss-process=image/auto-orient,1/resize,m_lfit,w_384,h_384/format,webp";

            break;
        }
        case QWImageSizeTypeCategory: {
//            typeString = @"category";
//            typeString = @"imageMogr2/auto-orient/thumbnail/384x384/format/webp";
            typeString =@"x-oss-process=image/auto-orient,1/resize,m_lfit,w_384,h_384/format,webp";

            break;
        }
        case QWImageSizeTypeCover: {
//            typeString = @"cover";
//            typeString = @"imageMogr2/auto-orient/thumbnail/480x640/format/webp";
            typeString =@"x-oss-process=image/auto-orient,1/resize,m_lfit,w_480,h_640/format,webp";

            break;
        }
        case QWImageSizeTypeCoverThumbnail: {
//            typeString = @"coverThumbnail";
//            typeString = @"imageMogr2/auto-orient/thumbnail/480x640/format/webp";
            typeString =@"x-oss-process=image/auto-orient,1/resize,m_lfit,w_480,h_640/format,webp";

            break;
        }
        case QWImageSizeTypeIllustration: {
//            typeString = @"illustration";
//            typeString = @"imageMogr2/auto-orient/thumbnail/1280x1280/format/webp";
            typeString =@"x-oss-process=image/auto-orient,1/resize,m_lfit,w_1280,h_1280/format,webp";

            break;
        }
        case QWImageSizeTypeSlide: {
//            typeString = @"slide";
//            typeString = @"imageMogr2/auto-orient/thumbnail/1080x360/format/webp";
            typeString =@"x-oss-process=image/auto-orient,1/resize,m_lfit,w_1080,h_360/format,webp";

            break;
        }
        case QWImageSizeTypeSlide2: {
//            typeString = @"slide2";
//            typeString = @"imageMogr2/auto-orient/thumbnail/1080x540/format/webp";
            typeString =@"x-oss-process=image/auto-orient,1/resize,m_lfit,w_1080,h_540/format,webp";

            break;
        }
        case QWImageSizeTypeShare: {
            typeString = @"share";
//            typeString = @"imageMogr2/auto-orient/thumbnail/128x128/format/webp";
            return [NSString stringWithFormat:@"%@-%@", picURL, typeString];
        }
        case QWImageSizeTypeMultipreview: {
//            typeString = @"multipreview";
//            typeString = @"imageMogr2/auto-orient/thumbnail/384x384/format/webp";
            typeString =@"x-oss-process=image/auto-orient,1/resize,m_lfit,w_384,h_384/format,webp";
            break;
        }
        case QWImageSizeTypeSinglepreview: {
//            typeString = @"singlepreview";
//            typeString = @"imageMogr2/auto-orient/thumbnail/720x480/format/webp";
            typeString =@"x-oss-process=image/auto-orient,1/resize,m_lfit,w_720,h_480/format,webp";

            break;
        }
        case QWImageSizeTypeUploadpreview: {
//            typeString = @"uploadpreview";
//            typeString = @"imageMogr2/auto-orient/thumbnail/280x210/format/webp";
            typeString =@"x-oss-process=image/auto-orient,1/resize,m_lfit,w_280,h_210/format,webp";

            break;
        }
        case QWImageSizeTypeGameCover: {
//            typeString = @"coverGame";
//            typeString = @"imageMogr2/auto-orient/thumbnail/640x480/format/webp";
            typeString =@"x-oss-process=image/auto-orient,1/resize,m_lfit,w_640,h_480/format,webp";

            break;
        }
        case QWImageSizeTypeAvatarWebP:{
            typeString = @"avatarwebp";
            break;
        }
        case QWImageSizeTypeCoverWebP:{
            break;
        }
        case QWImageSizeTypeLaunchImgWebP:{
//            typeString = @"imageMogr2/auto-orient/thumbnail/1080x1620/format/webp";
            typeString =@"x-oss-process=image/auto-orient,1/resize,m_lfit,w_1080,h_1620/format,webp";
            
            break;
        }
        default: {
            break;
        }
    }
    return [NSString stringWithFormat:@"%@?%@", picURL, typeString];
}

@end
