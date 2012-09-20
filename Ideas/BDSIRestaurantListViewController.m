//
//  BDSIRestaurantListViewController.m
//  Ideas
//
//  Created by tabinda siddiqi on 2012-09-12.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import "BDSIRestaurantListViewController.h"


@interface BDSIRestaurantListViewController ()

@end

@implementation BDSIRestaurantListViewController
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
    static NSString *CellIdentifier = @"restaurantCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue.identifier isEqualToString:@"showDineSafeDetails"] )
    {
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        BDSIDineSafeDetailViewController *detailVC = [segue destinationViewController];
        InspectionReport *currentReport = (InspectionReport *)[NSEntityDescription insertNewObjectForEntityForName:@"InspectionReport" inManagedObjectContext:self.managedObjectContext];
        
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

#pragma mark - NSFetchedResultsController delegate methods
// removed from

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *info = (NSMutableDictionary *)[_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [info valueForKey:@"establishment_name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [info valueForKey:@"inspection_status"]];
    NSString *imageName = [[info valueForKey:@"establishment_type"] stringByAppendingPathExtension:@"png"];
    
    cell.imageView.image = [UIImage imageNamed:imageName];
}

@end
