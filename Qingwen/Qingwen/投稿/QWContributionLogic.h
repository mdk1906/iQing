//
//  QWContributionLogic.h
//  Qingwen
//
//  Created by Aimy on 9/16/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWBaseLogic.h"

#import "VolumeList.h"
#import "ContributionListVO.h"
#import "BookVO.h"
#import "CategoryVO.h"
#import "DraftListVO.h"
#import "ActivityVO.h"
#import "ActivityListVO.h"

NS_ASSUME_NONNULL_BEGIN

@interface QWContributionLogic : QWBaseLogic

//投稿列表
@property (nonatomic, strong, nullable) ContributionListVO *contributionBooks;//我创建的书

//书
@property (nonatomic, strong, nullable) ContributionVO *contributionVO;//我的投稿
@property (nonatomic, strong, nullable) BookVO *book;//卷所属的书
@property (nonatomic, strong, nullable) UIImage *cover;//书的封面
@property (nonatomic, strong, nullable) NSNumber *channel;//书的分区10男，11女
@property (nonatomic, copy, nullable)   NSString *coverPath;//书的封面的地址
//活动
@property (nonatomic, strong, nullable) ActivityListVO *activityList; //查询到的正在进行活动列表
@property (nonatomic, strong, nullable) NSArray<ActivityVO *> *activitys; //活动Id
//分类
@property (nonatomic, strong, nullable) CategoryVO *categoryVO;//查询到的分类
@property (nonatomic, strong, nullable) NSArray<CategoryItemVO *> *categorys;//在分类界面选择的分类

//目录
@property (nonatomic, strong, nullable) VolumeList *volumeList;


@property (nonatomic, strong, nullable) VolumeVO *volume;
//章
@property (nonatomic, strong, nullable) ChapterVO *chapter;//章节
@property (nonatomic, strong, nullable) ContentVO *content;//内容
@property (nonatomic, strong, nullable) NSAttributedString *originContent;

//草稿
@property (nonatomic, strong, nullable) DraftListVO *draftList;
@property (nonatomic, strong, nullable) VolumeList *draftVolumeList;

//列表
- (void)getContributionsWithCompleteBlock:(__nullable QWCompletionBlock)aBlock;

//书
- (void)createBookWithTitle:(NSString * __nonnull)title intro:(NSString * __nonnull)intro andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
- (void)updateBookWithIntro:(NSString * __nullable)intro andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
- (void)updateApproveBookWithIntro:(NSString * __nullable)intro andCompleteBlock:(__nullable QWCompletionBlock)aBlock;

- (void)deleteBookWithCompeteBlock:(QWCompletionBlock)aBlock;
- (void)endBookWithCompeteBlock:(QWCompletionBlock)aBlock;
//上传封面
- (void)uploadCover:(UIImage * __nonnull)aImage andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
- (void)uploadImage:(UIImage * __nonnull)aImage andCompleteBlock:(__nullable QWCompletionBlock)aBlock;

//获取分类
- (void)getCategoryWithCompleteBlock:(__nullable QWCompletionBlock)aBlock;
//获取活动
- (void)getActivitListWithCompleteBlock:(__nullable QWCompletionBlock)aBlock;
//卷
- (void)createVolumeWithTitle:(NSString * __nonnull)title andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
- (void)updateVolumeWithVolume:(VolumeVO * __nonnull)volume title:(NSString * __nonnull)title andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
- (void)getDirectoryWithBookId:(NSString *__nonnull)bookId andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
//删除卷
- (void)deleteVolumeWithVolume:(VolumeVO * __nonnull)volume andCompleteBlock:(__nullable QWCompletionBlock)aBlock;

//提交审核
- (void)submitBookWithComment:(NSString * __nullable)comment andCompleteBlock:(__nullable QWCompletionBlock)aBlock;

//排序
- (void)reorderVolume:(NSArray <VolumeVO *>* __nonnull)volumes andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
- (void)reorderChapter:(NSArray <ChapterVO *>* __nonnull)chapters andCompleteBlock:(__nullable QWCompletionBlock)aBlock;

//章节
- (void)getChaptersWithVolume:(VolumeVO * __nonnull)volume andCompleteBlock:(QWCompletionBlock)aBlock;
- (void)createChapterWithVolumeUrl:(NSString * __nullable)url title:(NSString * __nonnull)title content:(NSAttributedString * __nullable)content chapterType:(NSNumber * __nullable)chapterType andCompleteBlock:(QWCompletionBlock)aBlock;
//修改标题
- (void)updateChapterWithChapter:(ChapterVO * __nonnull)chapter title:(NSString * __nonnull)title andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
//修改内容
- (void)updateChapterWithChapter:(ChapterVO * __nonnull)chapter content:(NSAttributedString * __nonnull)content andCompleteBlock:(QWCompletionBlock)aBlock;
//删除章
- (void)deleteChapterWithChapter:(ChapterVO * __nonnull)chapter andCompleteBlock:(__nullable QWCompletionBlock)aBlock;

//编辑章节
- (void)getContentWithCompleteBlock:(__nullable QWCompletionBlock)aBlock;

//编辑章节
- (void)getRecordWithUrl:(NSString *)url andCompleteBlock:(__nullable QWCompletionBlock)aBlock;

////
//获取草稿
- (void)getDraftsWithBookId:(NSString * __nonnull)nid andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
//获取卷列表
- (void)getVolumesWithBookId:(NSString * __nonnull)nid andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
//创建草稿
- (void)createDraftWithBookId:(NSString * __nonnull)nid title:(NSString * __nonnull)title whisper:(NSString * __nonnull)whisper content:(NSAttributedString * __nullable)content chapterType:(NSNumber * _Nullable)chapterType andCompleteBlock:(QWCompletionBlock)aBlock;
//修改作者的话
- (void)updateWhisperWithBookId:(NSString * __nonnull)nid title:(NSString * __nonnull)title whisper:(NSString * __nonnull)whisper content:(NSAttributedString * __nullable)content zhengshiVolumeId:(NSString * __nullable)zhengshiVolumeId andCompleteBlock:(QWCompletionBlock)aBlock;
//草稿更新
- (void)updateDraftWithDraftId:(NSString * __nonnull)DraftId title:(NSString * __nonnull)title whisper:(NSString *__nonnull)whisper  content:(NSAttributedString * __nonnull)content andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
//删除草稿
- (void)deleteDraftWithChapter:(ChapterVO * __nonnull)chapter andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
//发布草稿
- (void)releaseDraftWithDraftId:(NSString * __nonnull)dratfId volumeId:(NSString *)volumeId chapterType:(NSNumber * __nonnull)chapterType date:(NSDate * __nullable)date andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
//提交审核
- (void)coverOldChapterWithChapterId:(NSString * __nonnull)oldChapterId newChapterId:(NSString * __nonnull)newChapterId andCompletBlock:(QWCompletionBlock)aBlock;
//取消发布
- (void)cancelreleaseDraftWithChapterId:(NSString * __nonnull)oldChapterId andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
//撤回草稿
- (void)withdrawDraftWithChapterId:(NSString * __nonnull)ChapterId andCompleteBlock:(__nullable QWCompletionBlock)aBlock;
@end

NS_ASSUME_NONNULL_END
