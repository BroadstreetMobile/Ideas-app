//
//  BDSIDineSafeDetailViewController.m
//  Ideas
//
//  Created by tabinda siddiqi on 2012-09-19.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import "BDSIDineSafeDetailViewController.h"

@interface BDSIDineSafeDetailViewController ()

@end

@implementation BDSIDineSafeDetailViewController

@synthesize inspectionReport = _inspectionReport;
@synthesize dineSafeDetailOuterShell = _dineSafeDetailOuterShell;
@synthesize torontoPublicHealthLabel = _torontoPublicHealthLabel;
@synthesize inspectionStatusLabel = _inspectionStatusLabel;
@synthesize addressLabel= _addressLabel;
@synthesize inspectionDateLabel = _inspectionDateLabel;
@synthesize inspectionTorontoLogo = _inspectionTorontoLogo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Return the managed context from AppDelegate
    BDSIAppDelegate *appDelegate = (BDSIAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    //define view details
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setTitle:@"Dine Safety Details"];

    if ([self.inspectionReport.inspection_status isEqualToString:@"Pass"]) {
        [self.dineSafeDetailOuterShell setBackgroundColor: [UIColor greenColor]];
    }
    
    else if ([self.inspectionReport.inspection_status isEqualToString:@"Fail"]){
        [self.dineSafeDetailOuterShell setBackgroundColor:[UIColor redColor]];
    }
    else if ([self.inspectionReport.inspection_status isEqualToString:@"Conditional Pass"]){
        [self.dineSafeDetailOuterShell setBackgroundColor: [UIColor yellowColor]];
    }
    else {
        [self.dineSafeDetailOuterShell setBackgroundColor: [UIColor grayColor]];
    }
    
    //define label details
    
    [self.torontoPublicHealthLabel setText: @"TORONTO PUBLIC HEALTH"];
    [self.torontoPublicHealthLabel setBackgroundColor:[UIColor blueColor]];
    [self.torontoPublicHealthLabel setTextColor: [UIColor whiteColor]];
    
    [self.inspectionStatusLabel setText: self.inspectionReport.inspection_status];
    
    [self.addressLabel setText: self.inspectionReport.establishment_address];
    //[self.addressLabel setBackgroundColor:[UIColor redColor]];
    [self.addressLabel setTextColor: [UIColor whiteColor]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString* inspectionDate = [formatter stringFromDate:self.inspectionReport.inspection_date];
    [self.inspectionDateLabel setText: inspectionDate];
    [self.inspectionDateLabel setTextColor: [UIColor whiteColor]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setAddressLabel:nil];
    [self setInspectionDateLabel:nil];
    [self setInspectionTorontoLogo:nil];
    [self setTorontoPublicHealthLabel:nil];
    [self setDineSafeDetailOuterShell:nil];
    [self setInspectionStatusLabel:nil];
    [super viewDidUnload];
}
@end
