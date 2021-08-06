//
//  QWConvertImageString.h
//  Qingwen
//
//  Created by Aimy on 7/11/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QWImageSizeType) {
    QWImageSizeTypeNone = 0,
    QWImageSizeTypeRecommend,//推荐位
    QWImageSizeTypePromotion,//活动位
    QWImageSizeTypeAvatar,//用户头像
    QWImageSizeTypeAvatarThumbnail,//用户头像的缩略图
    QWImageSizeTypeCategory,//分类
    QWImageSizeTypeCover,//书籍页面封面图
    QWImageSizeTypeCoverThumbnail,//列表书籍缩略图
    QWImageSizeTypeIllustration,//插画
    QWImageSizeTypeSlide,//热门的图片，3:1
    QWImageSizeTypeSlide2,//热门的图片，2:1
    QWImageSizeTypeShare,//分享
    QWImageSizeTypeMultipreview,//grid 3
    QWImageSizeTypeSinglepreview,//单张大图
    QWImageSizeTypeUploadpreview,//上传预览
    QWImageSizeTypeGameCover,//游戏封面 4:3
    QWImageSizeTypeAvatarWebP,
    QWImageSizeTypeCoverWebP,
    QWImageSizeTypeLaunchImgWebP,//闪屏
};

@interface QWConvertImageString : NSObject

///**
// *	功能:图片的url,根据控件的宽、高来获取适配的url
// *
// *	@param picURL  :源图片url
// *	@param aWidth  :控件的宽
// *	@param aHeight :控件的高
// *
// *	@return
// */
//+ (NSString *)convertPicURL:(NSString *)picURL
//                  viewWidth:(NSInteger)aWidth
//                 viewHeight:(NSInteger)aHeight;



+ (NSString * __nonnull)convertPicURL:(NSString * __nullable)picURL imageSizeType:(QWImageSizeType)type;

@end
