//
//  QWReadingVC.h
//  Qingwen
//
//  Created by Aimy on 7/2/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "QWBaseVC.h"
#import "QWReadingTopNameView.h"
@class QWReadingLogic;
@class BookPageVO;

@interface QWReadingVC : QWBaseVC

@property (nonatomic, strong) BookPageVO *nextPage;//下一个page
@property (nonatomic, strong) BookPageVO *currentPage;//当前page
@property (nonatomic, strong) BookPageVO *previousPage;//上一个page

@property (nonatomic, getter=isLoading) BOOL loading;//正在加载数据
@property (nonatomic, getter=isLoadingBook) BOOL loadingBook;
@property (nonatomic, getter=isPicture) BOOL picture;//当前page是个图片
@property (nonatomic,getter=isChapter) BOOL isChapter;
@property (nonatomic,getter=issubscribe) BOOL isSubscribe;
@property (nonatomic, copy) NSString *pictureName;//图片地址

//看完广告的data
@property (nonatomic, strong) NSString *wacthAdData;

//广告是否准备好
@property (nonatomic) BOOL adready;
@property (strong, nonatomic) QWReadingTopNameView *topNameView;
@property (weak, nonatomic) IBOutlet UIImageView *contentImg;
- (void)refreshContent;
- (void) WhetherWatchAd;
@end
