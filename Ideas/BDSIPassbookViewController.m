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
@synthesize webView = _webView;

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
    
    [self loadFromWeb];
}

- (void)loadFromWeb
{
    
//    NSURL *localUrl = [NSURL URLWithString:@"http://pkpasses/subs/"];
//    [[UIApplication sharedApplication] openURL:localUrl];

    NSURL *localUrl = [NSURL URLWithString:@"http://bdsi.darrenbaptiste.com/pass/"];
    NSURLRequest *samplePassLocalUrl = [NSURLRequest requestWithURL:localUrl];
    [self.webView setDelegate:self];
    [self.webView loadRequest:samplePassLocalUrl];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _webView = nil;
}

#pragma mark - UIWebViewDelegate methods
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error loading web view: %@", error);
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
}
@end
