//
//  BDSISlowDineSafeListViewController.m
//  Ideas
//
//  Created by tabinda siddiqi on 2012-09-12.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import "BDSISlowDineSafeListViewController.h"


@interface BDSISlowDineSafeListViewController ()

@end

@implementation BDSISlowDineSafeListViewController
@synthesize fetchedResultsController = _fetchedResultsController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BDSIAppDelegate *appDelegate = (BDSIAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setTitle:@"Dine Safely"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    _fetchedResultsController = nil;
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"slowDineSafeCell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    
    
    
    return cell;
}

//Returns the number of distinct dine safe establishment types given a type as a parameter
- (NSNumber *)findEstTypeCount:(NSString *)est_type {
    
    //Create an NSFetchRequest to query the DineSafe entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"InspectionReport" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = [[NSError alloc] init];
    
    //Set a predicate to filter out only the type we want from the set of records
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"establishment_type LIKE %@", est_type]];
    NSArray *numOfObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSNumber *numOfDineSafeType = [NSNumber numberWithInt:[numOfObjects count]];
    
    return numOfDineSafeType;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showSlowDineSafeDetails" sender:[tableView cellForRowAtIndexPath:indexPath]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Assign the segue to the right segue on story board.
    
    if ( [segue.identifier isEqualToString:@"showSlowDineSafeDetails"] )
    {
        
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        //Assign the destination controller for the segue as BDSIDineSafeDetailViewController
        //Create an object for InspectionReport using the right initialization methord for insertNewObjectForEntityName as shown below.
        
        BDSIDineSafeDetailViewController *detailVC = [segue destinationViewController];
        InspectionReport *currentReport = (InspectionReport *)[NSEntityDescription insertNewObjectForEntityForName:@"InspectionReport" inManagedObjectContext:self.managedObjectContext];
        
        //Return the results of a fetched results controller in to a dictionary and assign te differnet attributes to the attributes in the new InspectionReport Object we created above.
        
        NSDictionary *tempDict = (NSDictionary *)[_fetchedResultsController objectAtIndexPath:indexPath];
        currentReport.inspection_date = [tempDict valueForKey:@"inspection_date"];
        currentReport.inspection_status = [tempDict valueForKey:@"inspection_status"];
        currentReport.establishment_id = [tempDict valueForKey:@"establishment_id"];
        currentReport.establishment_name = [tempDict valueForKey:@"establishment_name"];
        currentReport.establishment_type = [tempDict valueForKey:@"establishment_type"];
        currentReport.establishment_address = [tempDict valueForKey:@"establishment_address"];
        
        [detailVC setInspectionReport:currentReport];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequestSafeRest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entitySafeRest = [NSEntityDescription entityForName:@"InspectionReport" inManagedObjectContext:self.managedObjectContext];
    [fetchRequestSafeRest setEntity:entitySafeRest];
    
    // Set the batch size to a suitable number.
    [fetchRequestSafeRest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptorSafeRest = [[NSSortDescriptor alloc] initWithKey:@"establishment_name" ascending:YES];
    NSArray *sortDescriptorsSafeRest = @[sortDescriptorSafeRest];
    
    [fetchRequestSafeRest setSortDescriptors:sortDescriptorsSafeRest];
    
    /// start remove dupes ///
    [fetchRequestSafeRest setResultType:NSDictionaryResultType];
    [fetchRequestSafeRest setPropertiesToFetch:@[@"establishment_name", @"establishment_id", @"establishment_type", @"establishment_address", @"inspection_date", @"inspection_status"]];
    [fetchRequestSafeRest setReturnsDistinctResults:YES];
    /// end remove dupes ///
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    // Remove the cacheName during development to allow us to change the fetchRequests
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequestSafeRest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}


// removed from

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
   //Retrieve objects from fetchedResultsController into a dictionary.
   NSMutableDictionary *info = (NSMutableDictionary *)[_fetchedResultsController objectAtIndexPath:indexPath];
    
    //Give cells a background color
    cell.contentView.backgroundColor = [UIColor whiteColor];

    
    //Create a label as a subview in the cell to display the dine safe title
    UILabel *dineSafeTitle = [[UILabel alloc] initWithFrame:CGRectMake(40, 15, 250, 15)];
    dineSafeTitle.text = [info valueForKey:@"establishment_name"];
    [dineSafeTitle setFont:[UIFont fontWithName:@"American Typewriter" size:16]];
    [dineSafeTitle setLineBreakMode:NSLineBreakByTruncatingTail];
    dineSafeTitle.backgroundColor = [UIColor clearColor];
    dineSafeTitle.alpha = 0.5;
    
    //Create a label as a subview in the cell to display the dine safe status
    UILabel *dineSafeInspectionStatus = [[UILabel alloc] initWithFrame:CGRectMake(40, 30, 100, 15)];
    dineSafeInspectionStatus.text = [info valueForKey:@"inspection_status"];
    [dineSafeInspectionStatus setFont:[UIFont fontWithName:@"American Typewriter" size:12]];
    dineSafeInspectionStatus.backgroundColor = [UIColor clearColor];
    dineSafeInspectionStatus.alpha = 0.5;
    
    //Create a label as a subview in the cell to display the dine safe number of type
    UILabel *dineSafeNumOfType = [[UILabel alloc] initWithFrame:CGRectMake(150, 30, 100, 15)];
    [dineSafeNumOfType setFont:[UIFont fontWithName:@"American Typewriter" size:12]];
    dineSafeNumOfType.backgroundColor = [UIColor clearColor];
    dineSafeNumOfType.alpha = 0.5;
    NSNumber *numOfDineSafeType = [self findEstTypeCount:[info valueForKey:@"establishment_type"]];
    dineSafeNumOfType.text = [numOfDineSafeType stringValue];
    
    [cell.contentView addSubview:dineSafeTitle];
    [cell.contentView addSubview:dineSafeInspectionStatus];
    [cell.contentView addSubview:dineSafeNumOfType];
    
    //Create a image and image holder as a subview in the cell to display the dine safe image
    UIImage *dineSafeImage = [[UIImage alloc] init];
    NSString *imageName = [[info valueForKey:@"establishment_type"] stringByAppendingPathExtension:@"png"];
    dineSafeImage = [UIImage imageNamed:imageName];
    
    UIImageView *dineSafeImageHolder = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    dineSafeImageHolder.image = dineSafeImage;
                                
    [cell.contentView addSubview:dineSafeImageHolder];
    
}

@end
