//
//  BDSIScrollingTablesSelectionViewController.m
//  Ideas
//
//  Created by Darren Baptiste on 2012-09-27.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import "BDSIScrollingTablesSelectionViewController.h"

@interface BDSIScrollingTablesSelectionViewController ()

@end

@implementation BDSIScrollingTablesSelectionViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationItem setTitle:@"Table Scrolling"];
}
@end
