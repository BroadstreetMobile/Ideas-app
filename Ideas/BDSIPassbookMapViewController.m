//
//  BDSIPassbookMapViewController.m
//  Ideas
//
//  Created by Darren Baptiste on 2012-09-26.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import "BDSIPassbookMapViewController.h"

@interface BDSIPassbookMapViewController ()

@end

@implementation BDSIPassbookMapViewController
@synthesize userEmailAddress = _userEmailAddress;
@synthesize longitudeTextField = _longitudeTextField;


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

- (void)viewDidUnload {
    [self setUserEmailAddress:nil];
    [self setMapView:nil];
    [self setSendButton:nil];
    [self setLattitudeTextField:nil];
    [self setLongitudeTextField:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = @"Set Location";
}

#pragma mark - Action methods
- (IBAction)sendButtonPushed:(UIButton *)sender
{
    [self requestPass];
}

- (void)requestPass
{
    //TODO: send a POST rather than GET
    
    NSString *server = @"http://bdsi.darrenbaptiste.com/pass/subs/index.php";
    // send all of the users' collected data to the server to build a pass
    NSString *urlString = [NSString stringWithFormat:@"%@?lon=%@&lat=%@&email=%@", server, self.longitudeTextField.text, self.lattitudeTextField.text, @"bob@example.com"];
    
    NSLog(@"URL: %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    if ( ![[UIApplication sharedApplication] openURL:url] )
    {
        NSLog(@"Couldn't launch URL: %@", url);
    }
    
}
@end
