//
//  ContributionVO.h
//  Qingwen
//
//  Created by Aimy on 10/29/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWValueObject.h"
#import "ActivityVO.h"

@protocol ContributionVO <NSObject>

@end

//FIXME: 估计会有坑
@interface ContributionVO : BookVO

@property (nonatomic, strong, nullable) NSString *author_comment;
@property (nonatomic, strong, nullable) NSString *staff_comment;
@property (nonatomic, strong, nullable) NSString *record_url;
@property (nonatomic, strong, nullable) NSString *book_url;
@property (nonatomic, strong, nonnull) BookVO <Ignore> *book;

//@property (nonatomic, assign) QWBookType bookStatus;

@end
