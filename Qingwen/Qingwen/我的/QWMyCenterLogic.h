//
//  QWMyCenterLogic.h
//  Qingwen
//
//  Created by Aimy on 7/10/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWBaseLogic.h"
#import "BindingVO.h"
#import "AuthenticationVO.h"
#import "CommentsListVO.h"
typedef NS_ENUM(NSUInteger, QWVerificationType) {
    QWVerificationTypeRegiste = 0, //注册
    QWVerificationTypeResetPassword, //更换密码
    QWVerificationTypeCheck //发送检查验证码
};

@interface QWMyCenterLogic : QWBaseLogic

@property (nonatomic, strong) NSNumber *unread;//未读个人消息
@property (nonatomic, strong) NSNumber *officialCount;//官方消息总数

@property (nonatomic, strong) NSArray <BindingVO> *bindingList;
@property (nonatomic, strong) AuthenticationVO *authorVO;

@property (nonatomic, strong) UserPageVO *blacklist;
@property (nonatomic, strong) CommentsListVO *CommentsList;

- (void)appWasPublished:(QWCompletionBlock)block;//App was Reviewing or Published
- (void)loginByVistor:(QWCompletionBlock)block;
- (void)loginWithName:(NSString *)phone password:(NSString *)password andCompleteBlock:(QWCompletionBlock)block;

- (void)logout;

- (void)checkCodeWithPhone:(NSString *)phone code:(NSString *)code registe:(BOOL)registe andCompleteBlock:(QWCompletionBlock)block;

//https://stynx.iqing.in/backend/shaymin/wikis/user_mobile
- (void)checkCodeWithPhone:(NSString *)phone code:(NSString *)code registe:(BOOL)registe
                   save:(BOOL)save andCompleteBlock:(QWCompletionBlock)block;


- (void)registWithName:(NSString *)phone password:(NSString *)password code:(NSString *)code username:(NSString *)username invite:(NSString *)invite andCompleteBlock:(QWCompletionBlock)block;

- (void)sendVerificationCodeToPhone:(NSString *)phone registe:(QWVerificationType)registe andCompleteBlock:(QWCompletionBlock)block;

- (void)resetPasswordWithPhone:(NSString *)mobile password:(NSString *)password code:(NSString *)code andCompleteBlock:(QWCompletionBlock)block;

- (void)getUserInfoWithCompleteBlock:(QWCompletionBlock)block;

//0未选择，1男，2女
- (void)updateUserWithSex:(NSInteger)sex birthday:(NSDate *)date andCompleteBlock:(QWCompletionBlock)block;
//上传图片
- (void)uploadAvatar:(UIImage *)image andCompleteBlock:(QWCompletionBlock)block;

//关注迁移
- (void)migrateWithBookIds:(NSArray *)ids andCompleteBlock:(QWCompletionBlock)block;

//注册push
- (void)registPushWithCompleteBlock:(QWCompletionBlock)block;

//签到
- (void)checkinWithCompleteBlock:(QWCompletionBlock)block;

//获取推送设置
- (void)getPushSettingCompleteBlock:(QWCompletionBlock)block;
//设置推送开关
- (void)setPushSettingWithType:(NSInteger)type open:(BOOL)open andCompleteBlock:(QWCompletionBlock)block;
//获取订阅清单
-(void)getSubscriberListCompleteBlock:(QWCompletionBlock)block;
//设置订阅开关
- (void)setSubscribedBookCompleteBlock:(NSNumber *)book isSub:(BOOL)value CompleteBlock:(QWCompletionBlock)block;
//未读消息数量
- (void)getUnreadMessageWithCompleteBlock:(QWCompletionBlock)block;

//获取黑名单列表
//- (void)getBlacklistWithCompleteBlock:(QWCompletionBlock)block;
//拉黑某人
//- (void)shieldUserWithId:(NSString *)userId andCompleteBlock:(QWCompletionBlock)block;
//取消拉黑某人
//- (void)unshieldUserWithId:(NSString *)userId andCompleteBlock:(QWCompletionBlock)block;

//3.2.1 第三方登录
- (void)registWithWXCode:(NSString *)code andCompleteBlock:(QWCompletionBlock)block;
- (void)registWithQQJsonResponse:(NSDictionary *)jsonResponse andCompleteBlock:(QWCompletionBlock)block;
- (void)registWithWBJsonResponse:(NSDictionary *)jsonResponse andCompleteBlock:(QWCompletionBlock)block;

//3.6.0 账号绑定
//获取当前用户手机号
- (void)getCheckUserMobileWithCompleteBlock:(QWCompletionBlock)block;
/**
 验证旧的验证码
 @param code 验证码
 @param type type = check_user,对原来手机发送验证码
 */
- (void)checkOlderBindCodeWithCode:(NSString *)code type:(NSString *)type CompleteBlock:(QWCompletionBlock)block;
//绑定列表
- (void)getBindingListWithCompleteBlock:(QWCompletionBlock)block;
//绑定微信
- (void)boundWithWXCode:(NSString *)code check:(BOOL)check andCompleteBlock:(QWCompletionBlock)block;
//绑定QQ
- (void)boundWithQQJsonResponse:(NSDictionary *)jsonResponse check:(BOOL)check andCompleteBlock:(QWCompletionBlock)block;
//绑定微博
- (void)boundWithWbJsonResponse:(NSDictionary *)jsonResponse check:(BOOL)check andCompleteBlock:(QWCompletionBlock)block;
//取消绑定
- (void)cancelBoundWithThirdState:(NSString *)state andCompleteBlock:(QWCompletionBlock)block;

- (void)boundWithPhone:(NSString *)phone password:(NSString *)password code:(NSString *)code andCompleteBlock:(QWCompletionBlock)block;

//获取所在地区
- (void)getUserLocation:(QWCompletionBlock)block;

-(void)pushCommentsVCWithPostUrl:(NSString *)postUrl;

- (BOOL)canRegistered;
@end
