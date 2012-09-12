//
//  BDSIWhitePaperListViewController.h
//  Ideas
//
//  Created by Darren Baptiste on 2012-09-10.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "BDSIWhitePaperViewController.h"

@interface BDSIWhitePaperListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) BDSIDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
