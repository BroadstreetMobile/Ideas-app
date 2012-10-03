//
//  BDSIPassbookViewController.m
//  Ideas
//
//  Created by Darren Baptiste on 2012-09-12.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import "BDSIPassbookViewController.h"
#import "BDSIMapPin.h"

@interface BDSIPassbookViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (readonly) CLLocationCoordinate2D currentUserCoordinate;

@end

@implementation BDSIPassbookViewController
@synthesize buttonNextStep = _buttonNextStep;
@synthesize mapView = _mapView;
@synthesize currentLocationButton = _currentLocationButton;
@synthesize activityIndicator = _activityIndicator;
@synthesize locationManager = _locationManager;
@synthesize currentUserCoordinate = _currentUserCoordinate;

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
    [self.buttonNextStep setEnabled:NO];
    _currentUserCoordinate = kCLLocationCoordinate2DInvalid;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.activityIndicator stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _locationManager = nil;
}

- (void)viewDidUnload {
    [self setButtonNextStep:nil];
    [self setMapView:nil];
    [self setActivityIndicator:nil];
    [self setCurrentLocationButton:nil];
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
- (IBAction)buttonNextStepPushed:(UIBarButtonItem *)sender
{
    // read the coordinates of the pin on the mapview
    
    // what if there is no pin?
    
    [self requestPass];
}
- (IBAction)currentLocationButtonPushed:(UIButton *)sender
{
    self.currentLocationButton.enabled = NO;
    [self.activityIndicator startAnimating];
    [self startUpdatingCurrentLocation];
}

/*
- (IBAction)currentLocationButtonPushed:(UIBarButtonItem *)sender
{
    self.currentLocationButton.enabled = NO;
    [self.activityIndicator startAnimating];
    [self startUpdatingCurrentLocation];
}
*/
- (void)requestPass
{
    NSString *server = @"https://apps.darrenbaptiste.com/pass/pass_server.php/create";
    // send all of the users' collected data to the server to build a pass
    NSString *urlString = [NSString stringWithFormat:@"%@/%g/%g", server, _currentUserCoordinate.latitude, _currentUserCoordinate.longitude];
    
    NSLog(@"URL: %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    if ( ![[UIApplication sharedApplication] openURL:url] )
    {
        NSLog(@"Couldn't launch URL: %@", url);
    }
    
}

#pragma mark - CoreLocation Delegate methods
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

- (void)showCurrentLocation:(CLLocation *)location
{
    // update the current location clabel with these coords
    _currentUserCoordinate = [location coordinate];
    
    NSLog(@"%@", [NSString stringWithFormat:@"Location: φ:%.4F, λ:%.4F", _currentUserCoordinate.latitude, _currentUserCoordinate.longitude]);
    
    // show/move a pin to show this location
    [self displayLocation:location onMap:self.mapView];
    
    [self.buttonNextStep setEnabled:YES];
}

- (void)displayLocation:(CLLocation *)location onMap:(MKMapView *)map
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error)
                    {
                        if (error)
                        {
                            NSLog(@"Geocode failed with error: %@", error);
                            [self displayError:error];
                            return;
                        }
                        NSLog(@"Received placemarks: %@", placemarks);
                        [self displayPlacemarks:placemarks];
                    }];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // if the location is older than 30s ignore
    if (fabs([newLocation.timestamp timeIntervalSinceDate:[NSDate date]]) > 30)
    {
        return;
    }
    
    // after recieving a location, stop updating
    [self stopUpdatingCurrentLocation];
    
    [self showCurrentLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    
    // stop updating
    [self stopUpdatingCurrentLocation];
    
    // since we got an error, set selected location to invalid location
    _currentUserCoordinate = kCLLocationCoordinate2DInvalid;
    
    // show the error alert
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = @"Error updating location";
    alert.message = [error localizedDescription];
    [alert addButtonWithTitle:@"OK"];
    [alert show];
}

#pragma mark - Utility methods
// plot one or more placemarks onto the map
- (void)displayPlacemarks:(NSArray *)placemarks
{
    for (CLPlacemark *placemark in placemarks)
    {
        // create an MKAnnotation, then MKAnnotationView, then add to the map
        BDSIMapPin *mapPin = [[BDSIMapPin alloc] init];
        [mapPin setPlacemark:placemark];
        [self.mapView addAnnotation:mapPin];
    }
}

// display a given NSError in an UIAlertView
- (void)displayError:(NSError*)error
{
    dispatch_async(dispatch_get_main_queue(),^ {
        
        NSString *message;
        switch ([error code])
        {
            case kCLErrorGeocodeFoundNoResult: message = @"kCLErrorGeocodeFoundNoResult";
                break;
            case kCLErrorGeocodeCanceled: message = @"kCLErrorGeocodeCanceled";
                break;
            case kCLErrorGeocodeFoundPartialResult: message = @"kCLErrorGeocodeFoundNoResult";
                break;
            default: message = [error description];
                break;
        }
        
        UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:@"An error occurred."
                                                          message:message
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [alert show];
    });   
}


@end
