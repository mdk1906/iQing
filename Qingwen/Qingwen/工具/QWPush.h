//
//  QWPush.h
//  
//
//  Created by Aimy on 9/3/15.
//
//

#import <Foundation/Foundation.h>

@interface QWPush : NSObject

+ (QWPush * __nonnull)sharedInstance;

- (void)registPush;

- (void)unRegist;

@end
