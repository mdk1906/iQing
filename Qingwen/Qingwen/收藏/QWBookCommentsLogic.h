//
//  QWBookCommentsLogic.h
//  Qingwen
//
//  Created by wei lu on 5/01/18.
//  Copyright © 2018 iQing. All rights reserved.
//

#import "QWBaseLogic.h"

#import "BookCommentsVO.h"
#import "BookCommentsListVO.h"
#import "FavoriteBooksVO.h"
@interface QWBookCommentsLogic : QWBaseLogic

@property (nonatomic, strong, nullable) BookCommentsListVO *commentsVO;
@property (nonatomic, strong, nullable) FavoriteBooksListVO *relatetiveFavoritesVO;

/**
 获取书评
 */
- (void)getCommentsWithCompleteBlock:(NSNumber *_Nonnull)workId workType:(NSNumber *_Nonnull)type andCompleteBlock:(QWCompletionBlock _Nonnull )aBlock;

- (void)getRelativeFavoriteWithCompleteBlock:(NSNumber *_Nonnull)workId workType:(NSNumber *_Nonnull)type andCompleteBlock:(QWCompletionBlock _Nonnull )aBlock;
@end
