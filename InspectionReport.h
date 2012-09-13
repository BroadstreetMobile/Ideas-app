//
//  InspectionReport.h
//  Ideas
//
//  Created by Darren Baptiste on 2012-09-13.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface InspectionReport : NSManagedObject

@property (nonatomic, retain) NSString * establishment_name;
@property (nonatomic, retain) NSString * establishment_address;
@property (nonatomic, retain) NSNumber * establishment_id;
@property (nonatomic, retain) NSString * establishment_type;
@property (nonatomic, retain) NSDate * inspection_date;
@property (nonatomic, retain) NSString * inspection_status;
@property (nonatomic, retain) NSDecimalNumber * amount_fined;

@end
