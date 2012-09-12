//
//  WhitePaper.h
//  Ideas
//
//  Created by Darren Baptiste on 2012-09-12.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface WhitePaper : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;

@end
