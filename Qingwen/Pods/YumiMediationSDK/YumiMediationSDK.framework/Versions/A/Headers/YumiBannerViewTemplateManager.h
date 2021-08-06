//
//  YumiBannerViewTemplateManager.h
//  Pods
//
//  Created by ShunZhi Tang on 2017/6/23.
//
//

#import "YumiMediationConfiguration.h"
#import "YumiMediationTemplateModel.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiBannerViewTemplateManager : NSObject

- (instancetype)initWithGeneralTemplate:(YumiMediationNativeTemplate *)generalTemplate
                      landscapeTemplate:(YumiMediationNativeTemplate *)landscapeTemplate
                       verticalTemplate:(YumiMediationNativeTemplate *)verticalTemplate
                       saveTemplateName:(NSString *)templateName;

- (void)fetchMediationTemplateSuccess:(void (^)(YumiMediationTemplateModel *_Nullable templateModel))success
                              failure:(void (^)(NSError *error))failure;

- (NSString *)replaceHtmlCharactersWithString:(NSString *)htmlString
                                      iconURL:(NSString *)iconURL
                                        title:(NSString *)title
                                  description:(NSString *)description
                                     imageURL:(NSString *)imageURL
                                 hyperlinkURL:(NSString *)hyperlinkURL;

- (YumiMediationNativeTemplate *)getCurrentNativeTemplate;
@end

NS_ASSUME_NONNULL_END
