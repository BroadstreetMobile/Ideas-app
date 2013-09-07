//
//  BDSIPassbookTutorialViewController.m
//  Ideas
//
//  Created by Darren Baptiste on 2012-10-08.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import "BDSIPassbookTutorialViewController.h"

@interface BDSIPassbookTutorialViewController ()

@end

@implementation BDSIPassbookTutorialViewController

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
    NSString *path = [[NSBundle mainBundle] pathForResource:@"PassbookSolution" ofType:@"html"];
    NSURL *tutorialFileUrl = [NSURL fileURLWithPath:path];
    
    self.webView.delegate = self;
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:tutorialFileUrl];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}

#pragma mark - UIWebViewDelegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Failed to load the tutorial into the web view. Will load error text instead.");
    
    // display a custom error message on screen
    [webView loadHTMLString:@"<h1>Oops... sorry!</h1>" baseURL:nil];
}
@end
