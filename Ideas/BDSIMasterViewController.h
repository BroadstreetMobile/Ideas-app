//
//  BDSIMasterViewController.h
//  Ideas
//
//  Created by Darren Baptiste on 2012-09-04.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import <UIKit/UIKit.h>


@class BDSIDetailViewController;

#import <CoreData/CoreData.h>

@interface BDSIMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) BDSIDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
