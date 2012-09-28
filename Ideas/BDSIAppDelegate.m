//
//  BDSIAppDelegate.m
//  Ideas
//
//  Created by Darren Baptiste on 2012-09-04.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import "BDSIAppDelegate.h"
#import "BDSIMasterViewController.h"
#import "BDSIDineSafeDataLoader.h"

@implementation BDSIAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [self setupControllers];
    }
    
    // load from XML
    if ( [self shouldLoadDineSafeData] )
    {
        NSString *localFile = @"dinesafe-full.xml";
        
        [self performSelectorInBackground:@selector(loadDineSafeDataFromFile:) withObject:localFile];
    }

    return YES;
}

- (void)setupControllers
{
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    splitViewController.delegate = (id)navigationController.topViewController;
    
    UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
    BDSIMasterViewController *controller = (BDSIMasterViewController *)masterNavigationController.topViewController;
    controller.managedObjectContext = self.managedObjectContext;
}

- (BOOL)shouldLoadDineSafeData
{
    if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"isDataLoaded"] )
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)loadDineSafeDataFromFile:(NSString *)localFileName
{
    if ( [self shouldLoadDineSafeData])
    {
        BDSIDineSafeDataLoader *dineSafeLoader = [[BDSIDineSafeDataLoader alloc] initWithDataFromFile:localFileName];
        if ( !dineSafeLoader)
        {
            // Houston, we have a problem...
            NSLog(@"Error! Unable to launch the DineSafeLoader");
        }
        else{
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isDataLoaded"];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Ideas" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Ideas.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
        // delete the existing store and start the creation process again
        [self removeExistingStoreAtUrl:storeURL];
        [self setupControllers];
    }    
    
    return _persistentStoreCoordinator;
}

/**
 *  Delete the existing datastore from the file system.
 *  @return BOOL YES, if the deletion was successful
 */
- (void)removeExistingStoreAtUrl:(NSURL *)storeUrl
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ( [fileManager removeItemAtURL:storeUrl error:&error] )
    {
        return;
    }
    else
    {
        // log the message and tell the user to update in the AppStore
        NSString *errorMessage = @"Unable to remove the old database";
        NSLog(@"%@", errorMessage);
        [self showUserFatalAlertMessage:errorMessage];

        //TODO: attempt a lightweight migration of the database
        /* Performing automatic lightweight migration by passing the following dictionary as the options parameter:
        @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
        
        Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
        */
        return;
    }
}

- (void)showUserFatalAlertMessage:(NSString *)message
{
    //TODO: add NSAlert message
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
