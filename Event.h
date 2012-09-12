//
//  Event.h
//  Ideas
//
//  Created by Darren Baptiste on 2012-09-10.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic) NSTimeInterval timeStamp;

@end
