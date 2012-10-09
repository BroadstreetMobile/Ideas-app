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
//    [self currentLocationButtonPushed:nil];
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
    NSString *urlString = [NSString stringWithFormat:@"%@/%g/%g/%@", server, _currentUserCoordinate.latitude, _currentUserCoordinate.longitude, self.localAddress];
    
    NSLog(@"URL: %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    if ( ![[UIApplication sharedApplication] openURL:url] )
    {
        NSLog(@"Couldn't launch URL: %@", url);
    }
    
}

#pragma mark - NSURLConnectionDelegate


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

         // TODO: use KVO to set this after self.lcalAddress is updated
         self.mapView.region = MKCoordinateRegionMakeWithDistance(_currentUserCoordinate, 10000, 10000);

     }];
}
/*
- (void)startUpdatingCurrentLocation
{
    // if location services are restricted do nothing
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted )
    {
        return;
    }
    
    // if locationManager does not currently exist, create it
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        _locationManager.distanceFilter = 10.0f; // we don't need to be any more accurate than 10m
        _locationManager.purpose = @"This may be used to obtain your reverse geocoded address";
    }
    
//    [_locationManager startMonitoringSignificantLocationChanges];   // for apps that need fairly static location info
    [_locationManager startUpdatingLocation];   // fetch constant location updates, mostly for navigation apps, but useful for our demo
    
    [self.activityIndicator startAnimating];
}

- (void)stopUpdatingCurrentLocation
{
//    [_locationManager stopMonitoringSignificantLocationChanges];
    [_locationManager stopUpdatingLocation];
    
    [self.activityIndicator stopAnimating];

}

#pragma mark - CoreLocation Delegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // if the location is older than 30s ignore
    if (fabs([newLocation.timestamp timeIntervalSinceDate:[NSDate date]]) > 30)
    {
        return;
    }
    
    MKCoordinateRegion cRegion = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 5000, 5000);
    [self.mapView setRegion:cRegion animated:YES];
    
    _currentUserCoordinate = newLocation.coordinate;
    
    [self.buttonNextStep setEnabled:YES];
    // after recieving a location, stop updating
    //[self stopUpdatingCurrentLocation];
    
//    [self showCurrentLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    
    // stop updating
    //[self stopUpdatingCurrentLocation];
    
    // since we got an error, set selected location to invalid location
    _currentUserCoordinate = kCLLocationCoordinate2DInvalid;
    
    // show the error alert
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = @"Error updating location";
    alert.message = [error localizedDescription];
    [alert addButtonWithTitle:@"OK"];
    [alert show];
}
*/

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