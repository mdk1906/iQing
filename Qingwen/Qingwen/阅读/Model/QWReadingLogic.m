//
//  QWReadingLogic.m
//  Qingwen
//
//  Created by Aimy on 7/6/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWReadingLogic.h"
#import "QWReadingManager.h"
#import "QWInterface.h"
#import "DiscussVO.h"
#import "VolumeList.h"

@interface QWReadingLogic()

@end

@implementation QWReadingLogic

- (void)getDiscussCountWithUrl:(NSString *)aUrl andCompleteBlock:(QWCompletionBlock)aBlock;
{
    NSMutableDictionary *params = @{}.mutableCopy;

    NSString *currentUrl = [NSString stringWithFormat:@"%@post_list/",aUrl];

    QWOperationParam *param = [QWInterface getWithUrl:currentUrl params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            DiscussVO *vo = [DiscussVO voWithDict:aResponseObject];
            self.count = vo.count;
            if (aBlock) {
                aBlock(self.count, nil);
            }
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];
    param.useOrigin = YES;
    [self.operationManager requestWithParam:param];
}

- (void)getBulletListWithChapterId:(NSString *)chapterId andCompleteBlock:(QWCompletionBlock)aBlock {
    if ([chapterId isEqualToString:_currentChapterId] && self.bulletList.results.count > 0) {
        return;
    }
    self.bulletList = nil;
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"limit"] = @400;
    NSString *currentUrl = [NSString stringWithFormat:@"%@/chapter/%@/danmaku/",[QWOperationParam currentDomain],chapterId];
    QWOperationParam *param = [QWInterface getWithUrl:currentUrl params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
        if (aResponseObject && !anError) {
            BulletList *vo = [BulletList voWithDict:aResponseObject];
            self.bulletList = vo;
            self.currentChapterId = chapterId;
            if (aBlock) {
                aBlock(self.bulletList, nil);
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

- (void)submitDanmuWithChaperId:(NSString *)chapterId key:(NSNumber *)key content:(NSString *)content completeBlock:(QWCompletionBlock)aBlock {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"token"] = [QWGlobalValue sharedInstance].token;
    params[@"key"] = key;
    params[@"value"] = content;
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/chapter/%@/new_danmaku/",[QWOperationParam currentDomain],chapterId] params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
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

- (void)initReadingManagerWithChapterId:(NSString *)chapterId completeBlock:(QWCompletionBlock)aBlock {
    QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/chapter/%@/",[QWOperationParam currentDomain],chapterId] andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        //获取bookId
        if (aResponseObject && !anError) {
            self.book_id = [[aResponseObject objectForKey:@"book_id"] stringValue];
            NSString *volumeUrl = [aResponseObject objectForKey:@"volume_url"];
            dispatch_group_t group = dispatch_group_create();
            { //获取书信息
                dispatch_group_enter(group);
                QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/book/%@/",[QWOperationParam currentDomain],self.book_id] andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
                    if (aResponseObject && !anError) {
                        BookVO *book = [BookVO voWithDict:aResponseObject];
                        BookCD *bookCD = [BookCD MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"nid == %@ && game == NO", book.nid] inContext:[QWFileManager qwContext]];
                        if (!bookCD) {//如果没有阅读过，则创建一个
                            bookCD = [BookCD MR_createEntityInContext:[QWFileManager qwContext]];
                            [bookCD updateWithBookVO:book];
                        }
                        [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];
                        NSLog(@"获取书信息");
                    }
                    dispatch_group_leave(group);
                }];
                [self.operationManager requestWithParam:param];
            }
            {  //获取卷信息
                dispatch_group_enter(group);
                QWOperationParam *param = [QWInterface getWithUrl:volumeUrl andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
                    if (aResponseObject && !anError) {
                        VolumeVO *volume = [VolumeVO voWithDict:aResponseObject];
                        NSString *chapter_url = [aResponseObject objectForKey:@"chapter_url"];
                        __block NSUInteger index;
                        { //获取当前卷所有chapter,获取Chapter位置
                            QWOperationParam *param = [QWInterface getWithUrl:chapter_url andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
                                if (aResponseObject && !anError) {
                                    NSArray <ChapterVO *> *results = [ChapterVO arrayOfModelsFromDictionaries:aResponseObject error:nil];
                                    [results enumerateObjectsUsingBlock:^(ChapterVO* obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                        if (obj.nid.integerValue == [chapterId integerValue]) {
                                            index = idx;
                                            *stop = YES;
                                        }
                                    }];
                                    VolumeCD *volumeCD = [VolumeCD MR_findFirstByAttribute:@"nid" withValue:volume.nid inContext:[QWFileManager qwContext]];
                                    
                                    if (!volumeCD) {
                                        volumeCD = [VolumeCD MR_createEntityInContext:[QWFileManager qwContext]];
                                        [volumeCD updateWithVolumeVO:volume bookId:[self.book_id toNumberIfNeeded]];
                                        volumeCD.chapterIndex = @0;
                                        volumeCD.location = @0;
                                    }
                                    
                                    if (volumeCD.chapterIndex && volumeCD.chapterIndex.integerValue != index) {//如果读的不是这个章节，则写成这个章节
                                        volumeCD.chapterIndex = @(index);
                                        volumeCD.location = @0;
                                    }
                                    
                                    [volumeCD setReading];
                                    [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];
                                    NSLog(@"获取当前卷所有chapter,获取Chapter位置");
                                    dispatch_group_leave(group);
                                }
                            }];
                            [self.operationManager requestWithParam:param];
                        }
                    }
                }];
                
                [self.operationManager requestWithParam:param];
            }
            
            {//获取书的所有卷信息
                dispatch_group_enter(group);
                QWOperationParam *param = [QWInterface getWithUrl:[NSString stringWithFormat:@"%@/book/%@/chapter/",[QWOperationParam currentDomain],self.book_id] andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
                    if (aResponseObject && !anError) {
                        VolumeList *listVO = [VolumeList voWithDict:aResponseObject];
                        [[QWReadingManager sharedInstance] startOnlineReadingWithBookId:[self.book_id toNumberIfNeeded] volumes:listVO];

                    }
                    NSLog(@"获取书的所有卷信息");
                    dispatch_group_leave(group);
                }];
                [self.operationManager requestWithParam:param];
            }
            
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                if (aBlock) {
                    NSLog(@"获取结束");
                    aBlock([QWReadingManager sharedInstance].volumes, nil);
                }
            });
        }
        else {
            if (aBlock) {
                aBlock(nil, anError);
            }
        }
    }];
    [self.operationManager requestWithParam:param];
}

- (NSArray *)getCurrentBulletsWithCurrentpage:(NSRange)range {
//    NSInteger clintKey = (range.length + range.location) / 2;
    if (self.bulletList && self.bulletList.results.count > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key >= %d AND key <= %d", range.location, range.location + range.length];
        return  [self.bulletList.results filteredArrayUsingPredicate: predicate];
    }else {
        return nil;
    }
}
@end
