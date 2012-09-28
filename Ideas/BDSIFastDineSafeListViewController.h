//
//  BDSIFastDineSafeListViewController.h
//  Ideas
//
//  Created by tabinda siddiqi on 2012-09-12.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestaurantSafetyInfo.h"
#import "InspectionReport.h"
#import <CoreData/CoreData.h>
#import "BDSIDineSafeDetailViewController.h"

@interface BDSIFastDineSafeListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

