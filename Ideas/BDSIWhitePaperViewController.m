//
//  BDSIWhitePaperViewController.m
//  Ideas
//
//  Created by Darren Baptiste on 2012-09-10.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import "BDSIWhitePaperViewController.h"

@interface BDSIWhitePaperViewController ()

@end

@implementation BDSIWhitePaperViewController
@synthesize whitepaper = _whitepaper;

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
    _whitepaper = nil;
}

@end
