//
//  RestaurantSafetyInfo.h
//  Ideas
//
//  Created by Darren Baptiste on 2012-09-12.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RestaurantSafetyInfo : NSManagedObject

@property (nonatomic, retain) NSString * establishment_name;
@property (nonatomic, retain) NSString * establishment_type;
@property (nonatomic, retain) NSString * establishment_status;
@property (nonatomic, retain) NSString * safety_action;

@end
