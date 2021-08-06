//
//  QWContributionLogic.m
//  Qingwen
//
//  Created by Aimy on 9/16/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWContributionLogic.h"

#import "QWInterface.h"
#import "QWJsonKit.h"
#import "NSObject+category.h"
#import <YYText.h>
#import "QWContributionImageView.h"

#define CONTENT_LENGTH 2000


typedef void (^dataBlock)(id aResponseObject);

@interface QWContributionLogic()

@end

@implementation QWContributionLogic


- (void)handleResponseObject:(id)aResponseObject dataBlock:(dataBlock)block{
    int code = [[aResponseObject objectForKey:@"code"] intValue];

    if (code == 0) { //成功
        NSMutableDictionary *data = [aResponseObject objectForKey:@"data"];
        if (!data) {
            data[@"data"] = @"成功.无数据返回";
        }
        if (block) {
            block(data);
        }
    }
    else if (code >= 200 && code < 300) {
        NSMutableDictionary *data = [aResponseObject objectForKey:@"data"];
        if (!data) {
            data[@"data"] = @"成功.无数据返回";
        }
        if (block) {
            block(data);
        }
    }
    else { //脏数据不返回
        NSString *msg = [aResponseObject objectForKey:@"msg"];
        [self showToastWithTitle:msg subtitle:nil type:ToastTypeError];
        if (block) {
            block(nil);
        }
    }
}

- (void)getContributionsWithCompleteBlock:(QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    NSString *currentUrl = [NSString stringWithFormat:@"%@/submit/book/", [QWOperationParam currentPecilDomain]];
    if (self.contributionBooks.next.length) {
        currentUrl = self.contributionBooks.next;
    }

    QWOperationParam *param = [QWInterface getWithUrl:currentUrl andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            [self handleResponseObject:aResponseObject dataBlock:^(id aResponseObject) {
                ContributionListVO *vo = [ContributionListVO voWithDict:aResponseObject];
                if (self.contributionBooks.count) {
                    [self.contributionBooks addResultsWithNewPage:vo];
                }
                else {
                    self.contributionBooks = vo;
                }
                
                if (aBlock) {
                    aBlock(self.contributionBooks, anError);
                }
            }];
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];
    param.useV4 = true;
    [self.operationManager requestWithParam:param];
}

- (void)createBookWithTitle:(NSString *)title intro:(NSString *)intro andCompleteBlock:(QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    NSMutableDictionary *contents = @{}.mutableCopy;
    contents[@"title"] = title;
    contents[@"intro"] = intro;
    contents[@"channel"] = self.channel;
    contents[@"cover"] = self.coverPath;

    NSArray *nids = [self.categorys valueForKeyPath:@"@distinctUnionOfObjects.nid"];
//    contents[@"categories"] = [nids componentsJoinedByString:@","];
    contents[@"categories"] = nids;
    
    NSArray *activityNids = [self.activitys valueForKeyPath:@"@distinctUnionOfObjects.nid"];
//    contents[@"activity"] = [activityNids componentsJoinedByString:@","];
    contents[@"activity"] = activityNids;
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"data"] = [QWJsonKit stringFromDict:contents];
    
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/submit/book/",[QWOperationParam currentPecilDomain]] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            
            [self handleResponseObject:aResponseObject dataBlock:^(id aResponseObject) {
                if (aResponseObject) {
                    ContributionVO *book = [ContributionVO voWithDict:aResponseObject];
                    self.contributionVO = book;
                    self.contributionVO.status = QWBookTypeDraft;
                    self.book = book;
                    if (aBlock) {
                        aBlock(aResponseObject, anError);
                    }
                }
                else {
                    if (aBlock) {
                        aBlock(aResponseObject, anError);
                    }
                }
            }];
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];

    param.requestType = QWRequestTypePost;
    param.paramsUseData = YES;
    param.useV4 = YES;
    [self.operationManager requestWithParam:param];
}

- (void)updateBookWithIntro:(NSString *)intro andCompleteBlock:(QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    NSMutableDictionary *contents = @{}.mutableCopy;
    contents[@"token"] = [QWGlobalValue sharedInstance].token;

    if (intro.length) {
        contents[@"intro"] = intro;
    }

    if (self.coverPath.length) {
        contents[@"cover"] = self.coverPath;
    }

    contents[@"channel"] = self.channel;
    NSArray *nids = [self.categorys valueForKeyPath:@"@distinctUnionOfObjects.nid"];
    //    contents[@"categories"] = [nids componentsJoinedByString:@","];
    contents[@"categories"] = nids;
    
    NSArray *activityNids = [self.activitys valueForKeyPath:@"@distinctUnionOfObjects.nid"];
    //    contents[@"activity"] = [activityNids componentsJoinedByString:@","];
    contents[@"activity"] = activityNids;
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"data"] = [QWJsonKit stringFromDict:contents];
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/submit/book/%@/change/",[QWOperationParam currentPecilDomain],self.book.nid] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            [self handleResponseObject:aResponseObject dataBlock:^(id aResponseObject) {
                if (aResponseObject) {
                    if (intro.length) {
                        self.book.intro = intro;
                    }
                    
                    if (self.coverPath.length) {
                        self.book.cover = self.coverPath;
                    }
                    
                    if (aBlock) {
                        aBlock(aResponseObject, anError);
                    }
                }
                else {
                    if (aBlock) {
                        aBlock(aResponseObject, anError);
                    }
                }
            }];
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];

    param.requestType = QWRequestTypePost;
    param.paramsUseData = YES;
    param.useV4 = YES;
    [self.operationManager requestWithParam:param];
}

- (void)updateApproveBookWithIntro:(NSString *)intro andCompleteBlock:(QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    NSMutableDictionary *contents = @{}.mutableCopy;
    contents[@"token"] = [QWGlobalValue sharedInstance].token;

    if (intro.length) {
        contents[@"intro"] = intro;
    }

    if (self.coverPath.length) {
        contents[@"cover"] = self.coverPath;
    }

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"data"] = [QWJsonKit stringFromDict:params];
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/submit/book/%@/change/", [QWOperationParam currentPecilDomain],self.book.nid] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            [self handleResponseObject:aResponseObject dataBlock:^(id aResponseObject) {
                if (aResponseObject) {
                    if (intro.length) {
                        self.book.intro = intro;
                    }
                    if (self.coverPath.length) {
                        self.book.cover = self.coverPath;
                    }
                    if (aBlock) {
                        aBlock(aResponseObject, anError);
                    }
                }
                else {
                    if (aBlock) {
                        aBlock(aResponseObject, anError);
                    }
                }
            }];
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];

    param.requestType = QWRequestTypePost;
    param.paramsUseData = YES;
    param.useV4 = YES;
    [self.operationManager requestWithParam:param];
}

- (void)deleteBookWithCompeteBlock:(QWCompletionBlock)aBlock {
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }
    
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/submit/book/%@/delete/",[QWOperationParam currentPecilDomain],self.contributionVO.nid.stringValue] andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (aBlock) {
            aBlock(aResponseObject, anError);
        }
    }];
    param.requestType = QWRequestTypePost;
    param.useV4 = YES;
    [self.operationManager requestWithParam:param];
}
- (void)endBookWithCompeteBlock:(QWCompletionBlock)aBlock{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }
    
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/submit/book/%@/end/",[QWOperationParam currentPecilDomain],self.contributionVO.nid.stringValue] andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (aBlock) {
            aBlock(aResponseObject, anError);
        }
    }];
    param.requestType = QWRequestTypePost;
    param.useV4 = YES;
    [self.operationManager requestWithParam:param];
}
- (void)uploadCover:(UIImage *)aImage andCompleteBlock:(QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"type"] = @"book";

    QWOperationParam *param = [QWInterface uploadImageWithParam:params image:aImage andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (!anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }
            else {
                self.coverPath = aResponseObject[@"path"];
            }
        }

        if (aBlock) {
            aBlock(aResponseObject, anError);
        }
    }];

    param.compressimage = YES;
    param.compressLength = 500 * 1000;
    [self.operationManager requestWithParam:param];
}

- (void)uploadImage:(UIImage *)aImage andCompleteBlock:(QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"type"] = @"content";

    UIImage *tempImage = aImage.copy;
    if (MAX(tempImage.size.width, tempImage.size.height) > 1280) {
        CGFloat times = MAX(tempImage.size.width, tempImage.size.height) / 1280;
        tempImage = [aImage scaleToSize:CGSizeMake(aImage.size.width / times, aImage.size.height / times)];
    }

    QWOperationParam *param = [QWInterface uploadImageWithParam:params image:tempImage andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aBlock) {
            aBlock(aResponseObject, anError);
        }
    }];

    [self.operationManager requestWithParam:param];
}

- (void)getCategoryWithCompleteBlock:(QWCompletionBlock)aBlock
{
    NSMutableDictionary *params = @{}.mutableCopy;

    QWOperationParam *param = [QWInterface getCategoryWithParams:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }
            else {
                CategoryVO *vo = [CategoryVO voWithDict:aResponseObject];
                NSMutableArray *temp = vo.results.mutableCopy;
                [temp.copy enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    CategoryItemVO *item = obj;
                    if ( ! [item.submit isEqualToNumber:@1]) {
                        [temp removeObject:item];
                    }
                }];
                vo.results = temp.copy;
                self.categoryVO = vo;

                if (aBlock) {
                    aBlock(aResponseObject, nil);
                }
            }
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];

    [self.operationManager requestWithParam:param];
}

- (void)getActivitListWithCompleteBlock:(__nullable QWCompletionBlock)aBlock {
    NSMutableDictionary *params = @{}.mutableCopy;

    QWOperationParam *param = [QWInterface getWithDomainUrl:@"activity/active/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            ActivityListVO *vo = [ActivityListVO voWithDict:aResponseObject];
            self.activityList = vo;
            if (aBlock) {
                aBlock(aResponseObject, nil);
            }
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];
    [self.operationManager requestWithParam:param];
}

- (void)getDirectoryWithBookId:(NSString *__nonnull)bookId andCompleteBlock:(QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/submit/book/%@/volume/",[QWOperationParam currentPecilDomain],bookId] andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            [self handleResponseObject:aResponseObject dataBlock:^(id aResponseObject) {
                if (aResponseObject) {
                    VolumeList *listVO = [VolumeList voWithDict:aResponseObject];
                    self.volumeList = listVO;
                    if (aBlock) {
                        aBlock(self.volumeList, nil);
                    }

                }
            }];
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];

    param.useV4 = YES;
    [self.operationManager requestWithParam:param];
}

- (void)deleteVolumeWithVolume:(VolumeVO *)volume andCompleteBlock:(QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;

    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/submit/volume/%@/delete/",[QWOperationParam currentPecilDomain],volume.nid] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        [self handleResponseObject:aResponseObject dataBlock:^(id aResponseObject) {
            if (aBlock) {
                aBlock(aResponseObject, anError);
            }
        }];
    }];

    param.requestType = QWRequestTypePost;
    param.paramsUseForm = YES;
    param.useV4 = true;
    [self.operationManager requestWithParam:param];
}

- (void)submitBookWithComment:(NSString * __nullable)comment andCompleteBlock:(__nullable QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    if (comment.length) {
        params[@"comment"] = comment;
    }

    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@apply/", self.book.url] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }
            else {
                self.contributionVO.status = QWBookTypeInReview;

                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];

    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

- (void)createVolumeWithTitle:(NSString *)title andCompleteBlock:(QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    NSMutableDictionary *contents = @{}.mutableCopy;
    contents[@"token"] = [QWGlobalValue sharedInstance].token;
    contents[@"title"] = title;
    contents[@"intro"] = @"";
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"data"] = [QWJsonKit stringFromDict:contents];

    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/submit/book/%@/volume/", [QWOperationParam currentPecilDomain], self.book.nid] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            [self handleResponseObject:aResponseObject dataBlock:^(id aResponseObject) {
                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }];
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];

    param.requestType = QWRequestTypePost;
    param.useV4 = true;
    param.paramsUseData = YES;
    [self.operationManager requestWithParam:param];
}

- (void)updateVolumeWithVolume:(VolumeVO *)volume  title:(NSString *)title andCompleteBlock:(QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    NSMutableDictionary *contents = @{}.mutableCopy;
    contents[@"token"] = [QWGlobalValue sharedInstance].token;
    contents[@"title"] = title;
    contents[@"intro"] = @"";
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"data"] = [QWJsonKit stringFromDict:contents];
    
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/submit/volume/%@/change/", [QWOperationParam currentPecilDomain], volume.nid] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            [self handleResponseObject:aResponseObject dataBlock:^(id aResponseObject) {
                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }];
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];

    param.requestType = QWRequestTypePost;
    param.useV4 = YES;
    param.paramsUseData = YES;
    [self.operationManager requestWithParam:param];
}

- (void)reorderVolume:(NSArray <VolumeVO *>*)volumes andCompleteBlock:(__nullable QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    NSMutableDictionary *contents = @{}.mutableCopy;
    contents[@"token"] = [QWGlobalValue sharedInstance].token;

    NSMutableArray *items = @[].mutableCopy;
    [volumes enumerateObjectsUsingBlock:^(VolumeVO * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [items addObject:@{@"id": obj.nid, @"order": @(idx + 1)}];
    }];
    contents[@"volumes"] = items;

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"data"] = [QWJsonKit stringFromDict:contents];

    QWOperationParam *param = [QWInterface getWithDomainUrl:@"submit_volume/order/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }
            else {
                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];

    param.requestType = QWRequestTypePost;
    param.paramsUseData = YES;
    [self.operationManager requestWithParam:param];
}

- (void)reorderChapter:(NSArray <ChapterVO *>*)chapters andCompleteBlock:(QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    NSMutableDictionary *contents = @{}.mutableCopy;
    contents[@"token"] = [QWGlobalValue sharedInstance].token;

    NSMutableArray *items = @[].mutableCopy;
    [chapters enumerateObjectsUsingBlock:^(ChapterVO * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [items addObject:@{@"id": obj.nid, @"order": @(idx + 1)}];
    }];
    contents[@"chapters"] = items;

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"data"] = [QWJsonKit stringFromDict:contents];

    QWOperationParam *param = [QWInterface getWithDomainUrl:@"submit_chapter/order/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }
            else {
                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];

    param.requestType = QWRequestTypePost;
    param.paramsUseData = YES;
    [self.operationManager requestWithParam:param];
}

- (void)getChaptersWithVolume:(VolumeVO * )volume andCompleteBlock:(QWCompletionBlock)aBlock {
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/submit/volume/%@/chapter/",[QWOperationParam currentPecilDomain],volume.nid] andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            [self handleResponseObject:aResponseObject dataBlock:^(id aResponseObject) {
                if (aResponseObject) {
                    if (aBlock) {
                        if (volume.chapter.count > 0) {
                            volume.chapter = nil;
                        }
                        NSArray <ChapterVO>*chappters = [[ChapterVO arrayOfModelsFromDictionaries:aResponseObject error:nil] copy];
                        volume.chapter = chappters;
                        aBlock(aResponseObject, anError);
                    }
                }
                else {
                    if (aBlock) {
                        aBlock(aResponseObject, anError);
                    }
                }
            }];
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];
    
    param.useV4 = YES;
    [self.operationManager requestWithParam:param];
}

- (void)createChapterWithVolumeUrl:(NSString *)url title:(NSString *)title content:(NSAttributedString *)content chapterType:(NSNumber *)chapterType andCompleteBlock:(QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    NSMutableDictionary *contents = @{}.mutableCopy;
    contents[@"token"] = [QWGlobalValue sharedInstance].token;
    contents[@"title"] = title;
    contents[@"content"] = [self getContentWithContentString:content];
    if (chapterType) {
        contents[@"type"] = chapterType;
    }
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"data"] = [QWJsonKit stringFromDict:contents];

    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@add_chapter/", url] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }
            else {
                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];

    param.requestType = QWRequestTypePost;
    param.paramsUseData = YES;
    [self.operationManager requestWithParam:param];
}

- (void)updateChapterWithChapter:(ChapterVO *)chapter title:(NSString *)title andCompleteBlock:(QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"title"] = title;

    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@update/", chapter.url] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }
            else {
                ChapterVO *chapter = [ChapterVO voWithDict:aResponseObject];
                self.chapter = chapter;
                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];

    param.requestType = QWRequestTypePatch;
    [self.operationManager requestWithParam:param];
}

- (void)updateChapterWithChapter:(ChapterVO *)chapter content:(NSAttributedString *)content andCompleteBlock:(QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    NSMutableDictionary *contents = @{}.mutableCopy;
    contents[@"token"] = [QWGlobalValue sharedInstance].token;
    contents[@"content"] = [self getContentWithContentString:content];

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"data"] = [QWJsonKit stringFromDict:contents];

    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@content/", chapter.url] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            NSNumber *code = aResponseObject[@"code"];
            if (code && ! [code isEqualToNumber:@0]) {//有错误
                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }
            else {
                ChapterVO *chapter = [ChapterVO voWithDict:aResponseObject];
                self.chapter = chapter;
                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];

    param.requestType = QWRequestTypePut;
    param.paramsUseData = YES;
    [self.operationManager requestWithParam:param];
}

- (NSArray *)getContentWithContentString:(NSAttributedString *)content
{
    NSMutableArray *contents = @[].mutableCopy;
    ContentItemVO *item = [ContentItemVO new];
    //切分图片
    WEAK_SELF;
    [content enumerateAttribute:YYTextAttachmentAttributeName inRange:NSMakeRange(0, content.length) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if (value) {
            YYTextAttachment *attachment = value;
            QWContributionImageView *imageView = attachment.content;
            NSString *imagePath = imageView.url;
            imagePath = [imagePath stringByReplacingOccurrencesOfString:@"http://image.iqing.in" withString:@""];
            item.type = @1;
            item.value = imagePath;
            [contents addObject:item.toDictionary];//添加图片
        }
        else {
            NSMutableArray<NSString *> *tempContents = @[].mutableCopy;

            //切分换行
            NSArray<NSString *> *subContents = [[content attributedSubstringFromRange:range].string componentsSeparatedByString:@"\n"];
            [subContents enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.length) {
                    [tempContents addObject:obj];
                }
            }];

            NSMutableString *string = @"".mutableCopy;
            //组合换行
            [tempContents enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                STRONG_SELF;
                if (string.length + obj.length < CONTENT_LENGTH) {
                    [string appendFormat:@"%@\n", obj];
                }
                else {
                    [self addString:string toContenets:contents withItem:item];

                    [string setString:@""];
                    [string appendFormat:@"%@\n", obj];
                }

                if (idx + 1 == tempContents.count) {
                    [self addString:string toContenets:contents withItem:item];
                }
            }];
        }
    }];

    return contents;
}

- (void)addString:(NSString *)contentString toContenets:(NSMutableArray *)contents withItem:(ContentItemVO *)item
{
    NSString *content = contentString;
    content = [content stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    content = [content stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (content.length) {
        item.type = @0;
        item.value = contentString;
        [contents addObject:item.toDictionary];
    }
}

- (void)deleteChapterWithChapter:(ChapterVO *)chapter andCompleteBlock:(QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;

    QWOperationParam *param = [QWInterface getWithUrl:chapter.url params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            if (aBlock) {
                aBlock(aResponseObject, anError);
            }
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];

    param.requestType = QWRequestTypeDelete;
    param.paramsUseForm = YES;
    [self.operationManager requestWithParam:param];
}

- (void)getContentWithCompleteBlock:(QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    QWOperationParam *param = [QWInterface getWithUrl:self.chapter.content_url andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            [self handleResponseObject:aResponseObject dataBlock:^(id aResponseObject) {
                if (aResponseObject) {
                    ContentVO *content = [ContentVO voWithDict:aResponseObject];
                    self.content = content;
                    self.chapter.contentVO = self.content;
                    [self configChapter];
                    
                    if (aBlock) {
                        aBlock(self.chapter.contentVO, anError);
                    }
                }
            }];
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];

    param.useV4 = YES;
    [self.operationManager requestWithParam:param];
}

- (void)configChapter
{
    WEAK_SELF;
    ContentVO *vo = self.chapter.contentVO;
    NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
    [vo.results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        @autoreleasepool {
            STRONG_SELF;

            ContentItemVO *itemVO = obj;
            if (itemVO.type.integerValue == 1) {//图片
                QWContributionImageView *imageView = [QWContributionImageView createWithNib];
                [imageView updateWithUrl:itemVO.value];
                [imageView sizeToFit];
                NSAttributedString *attachmentString = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeBottom attachmentSize:CGSizeMake(100, 100) alignToFont:[UIFont systemFontOfSize:15] alignment:YYTextVerticalAlignmentBottom];
                [attributedString appendAttributedString:attachmentString];
                [attributedString yy_appendString:@"\n"];
            }
            else {
                [attributedString yy_appendString:itemVO.value];
                [attributedString yy_appendString:@"\n"];
            }
        }
    }];

    [attributedString setYy_font:[UIFont systemFontOfSize:15.f]];
    self.originContent = attributedString.copy;
}

- (void)getRecordWithUrl:(NSString *)url andCompleteBlock:(__nullable QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;

    QWOperationParam *param = [QWInterface getWithUrl:url params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {

            if (aBlock) {
                aBlock(aResponseObject, nil);
            }
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];

    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

//获取草稿
- (void)getDraftsWithBookId:(NSString *)nid andCompleteBlock:(__nullable QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    NSString *currentUrl = [NSString stringWithFormat:@"%@/submit/book/%@/chapter_draft/?limit=9999", [QWOperationParam currentPecilDomain],nid];

    QWOperationParam *param = [QWInterface getWithUrl:currentUrl andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            [self handleResponseObject:aResponseObject dataBlock:^(id aResponseObject) {
                if (aResponseObject) {
                    DraftListVO *vo = [DraftListVO voWithDict:aResponseObject];
                    self.draftList = vo;
                    if (aBlock) {
                        aBlock(self.draftList, nil);
                    }
                }
                else {
                    if (aBlock) {
                        aBlock(nil, anError);
                    }
                }
            }];
        }
    }];

    param.useV4 = YES;
    [self.operationManager requestWithParam:param];
}
//获取卷列表
- (void)getVolumesWithBookId:(NSString *)nid andCompleteBlock:(__nullable QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;

    NSString *currentUrl = [NSString stringWithFormat:@"book/%@/listvolumes/", nid];

    QWOperationParam *param = [QWInterface getWithDomainUrl:currentUrl params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            VolumeList *listVO = [VolumeList voWithDict:aResponseObject];
            self.draftVolumeList = listVO;
            if (aBlock) {
                aBlock(self.draftVolumeList, nil);
            }
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];

    param.requestType = QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}
//创建草稿
- (void)createDraftWithBookId:(NSString * __nonnull)nid title:(NSString * __nonnull)title whisper:(NSString * __nonnull)whisper content:(NSAttributedString * __nullable)content chapterType:(NSNumber * _Nullable)chapterType andCompleteBlock:(QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    NSMutableDictionary *contents = @{}.mutableCopy;
    contents[@"token"] = [QWGlobalValue sharedInstance].token;
    contents[@"book_id"] = nid;
    contents[@"title"] = title;
    contents[@"whisper"] = whisper;
    contents[@"content"] = [self getContentWithContentString:content];
    if (chapterType) {
        contents[@"type"] = chapterType;
    }

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"data"] = [QWJsonKit stringFromDict:contents];

    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/submit/book/%@/chapter_draft/", [QWOperationParam currentPecilDomain],nid] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            [self handleResponseObject:aResponseObject dataBlock:^(id aResponseObject) {
                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }];
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];

    param.requestType = QWRequestTypePost;
    param.paramsUseData = YES;
    param.useV4 = YES;
    [self.operationManager requestWithParam:param];
}
//修改作者的话
- (void)updateWhisperWithBookId:(NSString * __nonnull)nid title:(NSString * __nonnull)title whisper:(NSString * __nonnull)whisper content:(NSAttributedString * __nullable)content zhengshiVolumeId:(NSString * __nullable)zhengshiVolumeId andCompleteBlock:(QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }
    
    NSMutableDictionary *contents = @{}.mutableCopy;
    contents[@"token"] = [QWGlobalValue sharedInstance].token;
    contents[@"book_id"] = nid;
    contents[@"title"] = title;
    contents[@"whisper"] = whisper;
    contents[@"content"] = [self getContentWithContentString:content];
    
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"data"] = [QWJsonKit stringFromDict:contents];
    
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/submit/chapter/%@/change/", [QWOperationParam currentPecilDomain],zhengshiVolumeId] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            [self handleResponseObject:aResponseObject dataBlock:^(id aResponseObject) {
                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }];
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];
    
    param.requestType = QWRequestTypePost;
    param.paramsUseData = YES;
    param.useV4 = YES;
    [self.operationManager requestWithParam:param];
}
//草稿更新标题
- (void)updateDraftWithDraftId:(NSString * __nonnull)DraftId title:(NSString * __nonnull)title whisper:(NSString *__nonnull)whisper content:(NSAttributedString * __nonnull)content andCompleteBlock:(__nullable QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    NSMutableDictionary *contents = @{}.mutableCopy;
    contents[@"token"] = [QWGlobalValue sharedInstance].token;
    if (title) {
        contents[@"title"] = title;
    }
    if (whisper) {
        contents[@"whisper"] = whisper;
    }
    if (content) {
        contents[@"content"] = [self getContentWithContentString:content];
    }

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"data"] = [QWJsonKit stringFromDict:contents];

    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/submit/chapter_draft/%@/content/", [QWOperationParam currentPecilDomain],DraftId] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        [self handleResponseObject:aResponseObject dataBlock:^(id aResponseObject) {
            if (aResponseObject) {
                ChapterVO *chapter = [ChapterVO voWithDict:aResponseObject];
                self.chapter = chapter;
                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }
            else {
                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }
        }];
    }];

    param.requestType = QWRequestTypePost;
    param.paramsUseData = YES;
    param.useV4 = YES;
    [self.operationManager requestWithParam:param];
}
//删除草稿
- (void)deleteDraftWithChapter:(ChapterVO * __nonnull)chapter andCompleteBlock:(__nullable QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;

    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/submit/chapter_draft/%@/delete/",[QWOperationParam currentPecilDomain], chapter.nid] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        [self handleResponseObject:aResponseObject dataBlock:^(id aResponseObject) {
            if (aBlock) {
                aBlock(aResponseObject,anError);
            }
        }];
    }];

    param.requestType = QWRequestTypePost;
    param.paramsUseData = YES;
    param.useV4 = YES;
    [self.operationManager requestWithParam:param];
}
//发布草稿
- (void)releaseDraftWithDraftId:(NSString * __nonnull)dratfId volumeId:(NSString *)volumeId chapterType:(NSNumber * __nonnull)chapterType date:(NSDate * __nullable)date andCompleteBlock:(__nullable QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }

    NSMutableDictionary *contents = @{}.mutableCopy;
    contents[@"action"] = @"new";
    contents[@"volume_id"] = volumeId;
    contents[@"type"] = chapterType;
    if (date) {
        contents[@"release_time"] = @((long long)(date.timeIntervalSince1970) * 1000);
    }
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"data"] = [QWJsonKit stringFromDict:contents];
    
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/submit/chapter_draft/%@/apply/",[QWOperationParam currentPecilDomain],dratfId] params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (aResponseObject && !anError) {
            [self handleResponseObject:aResponseObject dataBlock:^(id aResponseObject) {
                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }];
        }
        else {
            if (aBlock) {
                aBlock(aResponseObject, anError);
            }
        }
    }];

    param.requestType = QWRequestTypePost;
    param.useV4 = YES;
    param.paramsUseData = YES;
    [self.operationManager requestWithParam:param];
}

- (void)coverOldChapterWithChapterId:(NSString *)oldChapterId newChapterId:(NSString * __nonnull)newChapterId andCompletBlock:(QWCompletionBlock)aBlock{

    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }
    NSMutableDictionary *contents = @{}.mutableCopy;
    contents[@"action"] = @"override";
    contents[@"target_id"] = oldChapterId;
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"data"] = [QWJsonKit stringFromDict:contents];
    
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/submit/chapter_draft/%@/apply/",[QWOperationParam currentPecilDomain],newChapterId] params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (aResponseObject && !anError) {
            [self handleResponseObject:aResponseObject dataBlock:^(id aResponseObject) {
                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }];
        }
        else {
            if (aBlock) {
                aBlock(aResponseObject, anError);
            }
        }
    }];
    
    param.useV4 = YES;
    param.paramsUseData = YES;
    param.requestType =  QWRequestTypePost;
    [self.operationManager requestWithParam:param];
}

//取消发布
- (void)cancelreleaseDraftWithChapterId:(NSString * __nonnull)ChapterId andCompleteBlock:(__nullable QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }
    
    NSMutableDictionary *contents = @{}.mutableCopy;
    contents[@"action"] = @"cancel_release";
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"data"] = [QWJsonKit stringFromDict:contents];
    
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/submit/chapter_draft/%@/apply/",[QWOperationParam currentPecilDomain],ChapterId] params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (aResponseObject && !anError) {
            [self handleResponseObject:aResponseObject dataBlock:^(id aResponseObject) {
                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }];
        }
        else {
            if (aBlock) {
                aBlock(aResponseObject, anError);
            }
        }
    }];
    
    param.requestType = QWRequestTypePost;
    param.useV4 = YES;
    param.paramsUseData = YES;
    [self.operationManager requestWithParam:param];
}

//撤回草稿
- (void)withdrawDraftWithChapterId:(NSString * __nonnull)ChapterId andCompleteBlock:(__nullable QWCompletionBlock)aBlock
{
    if ( ! [QWGlobalValue sharedInstance].isLogin) {
        [[QWRouter sharedInstance] routerToLogin];
        [self showToastWithTitle:@"请先登录" subtitle:nil type:ToastTypeAlert];
        if (aBlock) {
            aBlock(nil, NOT_LOGIN_ERROR);
        }
        return ;
    }
    
//    NSMutableDictionary *contents = @{}.mutableCopy;
//    contents[@"action"] = @"cancel_release";
    
    NSMutableDictionary *params = @{}.mutableCopy;
//    params[@"data"] = [QWJsonKit stringFromDict:contents];
    
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/submit/chapter_draft/%@/back/",[QWOperationParam currentPecilDomain],ChapterId] params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        if (aResponseObject && !anError) {
            [self handleResponseObject:aResponseObject dataBlock:^(id aResponseObject) {
                if (aBlock) {
                    aBlock(aResponseObject, anError);
                }
            }];
        }
        else {
            if (aBlock) {
                aBlock(aResponseObject, anError);
            }
        }
    }];
    
    param.requestType = QWRequestTypePost;
    param.useV4 = YES;
    param.paramsUseData = YES;
    [self.operationManager requestWithParam:param];
}
@end
