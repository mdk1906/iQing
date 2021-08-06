//
//  QWReadingLogic.h
//  Qingwen
//
//  Created by Aimy on 7/6/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBaseLogic.h"
#import "BulletList.h"

@interface QWReadingLogic : QWBaseLogic

@property (nonatomic, copy) NSNumber *count;

@property (nonatomic, copy) NSString *book_id;

@property (nonatomic, strong) BulletList *bulletList;

@property (nonatomic, copy) NSString *currentChapterId;  //避免用户重复拉取一章弹幕


- (void)getDiscussCountWithUrl:(NSString *)url andCompleteBlock:(QWCompletionBlock)aBlock;

//获取一章弹幕
- (void)getBulletListWithChapterId:(NSString *)chapterId andCompleteBlock:(QWCompletionBlock)aBlock;
//提交弹幕
- (void)submitDanmuWithChaperId:(NSString *)chapterId key:(NSNumber *)key content:(NSString *)content completeBlock:(QWCompletionBlock)aBlock;

- (void)initReadingManagerWithChapterId:(NSString *)chapterId completeBlock:(QWCompletionBlock)aBlock;

- (NSArray *)getCurrentBulletsWithCurrentpage:(NSRange)pageIndex;
@end
