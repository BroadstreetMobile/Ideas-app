//
//  Restaurant_Safety_Info.h
//  Ideas
//
//  Created by tabinda siddiqi on 2012-09-11.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Restaurant_Safety_Info : NSManagedObject

@property (nonatomic, retain) NSString * establishment_name;
@property (nonatomic, retain) NSString * establishment_type;
@property (nonatomic, retain) NSString * safety_action;
@property (nonatomic, retain) NSString * establishment_status;

@end
