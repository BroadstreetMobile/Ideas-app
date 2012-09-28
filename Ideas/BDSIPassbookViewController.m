//
//  BDSIPassbookViewController.m
//  Ideas
//
//  Created by Darren Baptiste on 2012-09-12.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import "BDSIPassbookViewController.h"

@interface BDSIPassbookViewController ()

@end

@implementation BDSIPassbookViewController
@synthesize buttonNextStep = _buttonNextStep;

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
    [self.navigationItem setTitle:@"Using Passbook"];
    [self.navigationController setNavigationBarHidden:NO];
//    [self.buttonNextStep setEnabled:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = @"Coupon signup";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setButtonNextStep:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

#pragma mark - User Action methods
- (IBAction)emailEntry:(UITextField *)sender
{
    // if a (proper) email address was entered, enable the button to
    // proceed to the next step
    if ( [sender.text length] > 0 )
    {
        [self.buttonNextStep setEnabled:YES];
    }
}

- (IBAction)buttonNextStepPushed:(UIButton *)sender
{
}

@end
