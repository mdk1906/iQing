//
//  QWOperationParam.h
//  Qingwen
//
//  Created by Aimy on 15/4/7.
//  Copyright (c) 2015年 Qingwen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QWRequestType)  {
    QWRequestTypePost = 0,                   //post方式
    QWRequestTypeGet,                        //get方式
    QWRequestTypePatch,                      //patch方式(部分更新)
    QWRequestTypePut,                        //put方式(替换式更新)
    QWRequestTypeDelete,                     //delete方式
};

@interface QWOperationParam : NSObject

#pragma mark - 接口调用相关
@property (nonatomic, copy, nonnull)   NSString *requestUrl;                //请求url
@property (nonatomic, assign) QWRequestType requestType;                    //请求类型，post还是get方式，默认为post方式
@property (nonatomic, strong, nonnull) NSDictionary *requestParam;          //参数
@property (nonatomic, copy, nullable) QWCompletionBlock callbackBlock;      //回调block
@property (nonatomic, assign) NSTimeInterval timeoutTime;                   //超时时间，默认为10秒
@property (nonatomic) int retryTimes;                                       //重试次数
@property (nonatomic) int intervalInSeconds;                                //重试间隔
@property (nonatomic) BOOL printLog;                                        //打印
@property (nonatomic, copy, nullable) UIImage *uploadImage;                 //上传的图片信息
@property (nonatomic) BOOL compressimage;                                   //是否压缩图片
@property (nonatomic) NSInteger compressLength;                             //压缩图片阀值
@property (nonatomic) BOOL uploadBookImage;                                 //upload book image
@property (nonatomic) BOOL useOrigin;                                       //强制远端获取
@property (nonatomic) BOOL paramsUseForm;                                   //将参数转换成表单
@property (nonatomic) BOOL paramsUseData;                                   //将参数转换成data
@property (nonatomic, copy, nonnull) NSData *resumeData;                    //断点续传
@property (nonatomic, copy, nonnull) NSString *filePath;                    //文件地址
@property (nonatomic, copy, nonnull) NSString *destPath;                    //文件解压地址
@property (nonatomic, weak, nullable)  NSProgress *progress;                //进度

@property (nonatomic) BOOL image; //是否是通过get获取image

//FIXME: 后端V4 同步以后去掉
@property (nonatomic) BOOL useV4;

/**
 *  功能:初始化方法
 */
+ (nonnull instancetype)paramWithUrl:(NSString * __nonnull)aUrl
                                type:(QWRequestType)aType
                               param:(NSDictionary * __nonnull)aParam
                            callback:(QWCompletionBlock __nullable)aCallback;

/**
 *  功能:初始化方法
 */
+ (nonnull instancetype)paramWithMethodName:(NSString * __nonnull)aUrl
                                       type:(QWRequestType)aType
                                      param:(NSDictionary * __nonnull)aParam
                                   callback:(QWCompletionBlock __nullable)aCallback;


+ (nonnull NSString *)currentDomain;

+ (nonnull NSString *)currentBfDomain;

+ (nonnull NSString *)currentPecilDomain;
    
+ (nonnull NSString *)currentPayDomain;
    
+ (nonnull NSString *)currentFAVBooksDomain;

@end
