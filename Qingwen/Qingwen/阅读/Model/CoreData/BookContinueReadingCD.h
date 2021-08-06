//
//  BookContinueReadingCD.h
//  
//
//  Created by Aimy on 7/29/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BookContinueReadingCD : NSManagedObject

@property (nonatomic, retain) NSNumber * bookId;
@property (nonatomic, retain) NSNumber * volumeIndex;
@property (nonatomic, retain) NSNumber * chapterIndex;
@property (nonatomic, retain) NSNumber * location;
@property (nonatomic, retain) NSNumber * readingProgress;

@end
