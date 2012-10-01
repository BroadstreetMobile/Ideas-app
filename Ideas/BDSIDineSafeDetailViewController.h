//
//  BDSIDineSafeDetailViewController.h
//  Ideas
//
//  Created by tabinda siddiqi on 2012-09-19.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestaurantSafetyInfo.h"
#import "InspectionReport.h"
#import "BDSIFastDineSafeListViewController.h"
#import "BDSISlowDineSafeListViewController.h"
#import <CoreData/CoreData.h>

@interface BDSIDineSafeDetailViewController : UIViewController
@property (nonatomic, strong) InspectionReport *inspectionReport;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UIView *dineSafeDetailOuterShell;
@property (strong, nonatomic) IBOutlet UILabel *torontoPublicHealthLabel;
@property (strong, nonatomic) IBOutlet UILabel *inspectionStatusLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *inspectionDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *establishmentTypeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *inspectionTorontoLogo;

@end
