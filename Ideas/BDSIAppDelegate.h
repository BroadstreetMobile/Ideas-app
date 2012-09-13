//
//  BDSIAppDelegate.h
//  Ideas
//
//  Created by Darren Baptiste on 2012-09-04.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDSIAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
@end
