//
//  BDSIPassbookViewController.m
//  Ideas
//
//  Created by Darren Baptiste on 2012-09-12.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import "BDSIPassbookViewController.h"
#import "BDSIMapPin.h"
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>

@interface BDSIPassbookViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (readonly) CLLocationCoordinate2D currentUserCoordinate;
@property (nonatomic, strong) NSString *localAddress;

@end

@implementation BDSIPassbookViewController
@synthesize mapView = _mapView;
@synthesize requestCouponButton = _currentLocationButton;
@synthesize activityIndicator = _activityIndicator;
@synthesize locationManager = _locationManager;
@synthesize currentUserCoordinate = _currentUserCoordinate;
@synthesize localAddress = _localAddress;

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
    [self.navigationItem setTitle:@"Passbook"];
    [self.navigationController setNavigationBarHidden:NO];
    self.mapView.delegate = self;
    
    _currentUserCoordinate = kCLLocationCoordinate2DInvalid;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.activityIndicator stopAnimating];
    [self.mapView setShowsUserLocation:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _locationManager = nil;
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setActivityIndicator:nil];
    [self setRequestCouponButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - User Action methods
- (IBAction)requestCouponButtonPushed:(UIButton *)sender
{
    // if the user location is tracked on the map, then we can pass it forward,
    // otherwise tell the user
    if (self.mapView.userLocationVisible)
    {
        [self requestPass];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"We haven't tracked your location, therefore the pass we create will not have any addresses attached to it."
                                                           delegate:self cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
        [alertView show];
    }
}


- (void)requestPass
{
    
    NSString *server = @"https://apps.darrenbaptiste.com/pass/pass_server.php/create";
    // send all of the users' collected data to the server to build a pass
    NSString *urlString = [NSString stringWithFormat:@"%@/%g/%g/%@", server, _currentUserCoordinate.longitude, _currentUserCoordinate.latitude, self.localAddress];
    
    NSLog(@"URL: %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    if ( ![[UIApplication sharedApplication] openURL:url] )
    {
        NSLog(@"Couldn't launch URL: %@", url);
    }
    
}

#pragma mark - CoreLocation methods
- (void)reverseGeodocdeCurrentLocation:(CLLocation *)location
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         CLPlacemark *placemark = [placemarks lastObject];

         CFStringRef originalString =  CFBridgingRetain(placemark.thoroughfare);
         
         CFStringRef encodedString = CFURLCreateStringByAddingPercentEscapes(
                                                                             kCFAllocatorDefault,
                                                                             originalString,
                                                                             NULL,
                                                                             CFSTR(":/?#[]@!$&'()*+,;="),
                                                                             kCFStringEncodingUTF8);
         
         self.localAddress = (__bridge NSString *)(encodedString);
         
         NSLog(@"The address is: %@", self.localAddress);

         self.mapView.region = MKCoordinateRegionMakeWithDistance(_currentUserCoordinate, 3500, 3500);

     }];
}

#pragma mark - MapViewDelegateMethods
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocation *location = [mapView.userLocation location];
    _currentUserCoordinate = location.coordinate;
    [self reverseGeodocdeCurrentLocation:location];
    
}
#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // they only have a single button to press on the alert view, so we always send the request
    [self requestPass];
}

@end