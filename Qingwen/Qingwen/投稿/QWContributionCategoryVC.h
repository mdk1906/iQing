//
//  QWContributionCategoryVC.h
//  Qingwen
//
//  Created by Aimy on 9/17/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWBaseVC.h"

#import "CategoryItemVO.h"

@interface QWContributionCategoryVC : QWBaseVC

@property (nonatomic, strong) NSArray<__kindof CategoryItemVO *> *categorys;

@end
