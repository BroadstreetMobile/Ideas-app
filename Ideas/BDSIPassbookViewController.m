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
//@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic) NSArray *nearbyLocations;

@end

@implementation BDSIPassbookViewController
@synthesize buttonNextStep = _buttonNextStep;
@synthesize mapView = _mapView;
@synthesize currentLocationButton = _currentLocationButton;
@synthesize activityIndicator = _activityIndicator;
@synthesize locationManager = _locationManager;
@synthesize currentUserCoordinate = _currentUserCoordinate;
//@synthesize geocoder = _geocoder;
@synthesize nearbyLocations = _nearbyLocations;

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
    
//    self.geocoder = [[CLGeocoder alloc] init];

}

- (void)viewWillAppear:(BOOL)animated
{
    [self.activityIndicator stopAnimating];
    [self.mapView setShowsUserLocation:YES];
    [self currentLocationButtonPushed:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _locationManager = nil;
//    _geocoder = nil;
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
//    [self displayPlacemarksForBusinessName:@"McDonald's" nearLocation:nil];
    [self.mapView setShowsUserLocation:YES];
}

/*
- (IBAction)currentLocationButtonPushed:(UIBarButtonItem *)sender
{
    self.currentLocationButton.enabled = NO;
    [self.activityIndicator startAnimating];
    [self startUpdatingCurrentLocation];
}
*/
- (void)requestPass_ORIGINAL
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

// now try it by opening an NSURLConnection and passing it JSON-encoded arrays of nearby coordinates and addresses
- (void)requestPass
{
    // if the user location is tracked on the map, then we can pass it forward,
    // otherwise tell the user
    if (!self.mapView.userLocationVisible)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"We haven't tracked your location, therefore the pass we create will not have any addresses attached to it."
                                                           delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
        [alertView show];
    }
    
    NSString *server = @"https://apps.darrenbaptiste.com/pass/pass_server.php/create";
    // send all of the users' collected data to the server to build a pass
    NSString *urlString = [NSString stringWithFormat:@"%@/%g/%g", server, _currentUserCoordinate.latitude, _currentUserCoordinate.longitude];
    
    NSLog(@"URL: %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    
//    NSArray *array = [NSArray arrayWithObjects:@"", nil];
    NSString *postString = @"";
    
    NSData *bodyData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:bodyData];
    
    NSURLConnection *urlConnection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    [urlConnection start];
    
    if ( ![[UIApplication sharedApplication] openURL:url] )
    {
        NSLog(@"Couldn't launch URL: %@", url);
    }
    
}

#pragma mark - NSURLConnectionDelegate


#pragma mark - CoreLocation methods
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
//    [self.mapView setShowsUserLocation:YES];  // not used, as the user may want to manually move the pointer to their preferred lunctime location
    
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
                        [self displayPlacemarks:placemarks usingImage:nil];
                        
                        // wait a moment before launching a new query
                        int64_t delayInSeconds = 2.0;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            [self displayPlacemarksForBusinessName:@"Apple" nearLocation:location];
                        });
                    }
     ];
}

// center this search around the users' current location
- (void)displayPlacemarksForBusinessName:(NSString *)businessName nearLocation:(CLLocation *)location
{
    CLGeocoder *geocoderSearch = [[CLGeocoder alloc] init];

    // find the region for the location specified by the user
//    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:location.coordinate radius:500 identifier:@"Businesses"];
    
    
//    CFErrorRef *error;
    ABRecordRef aBusiness = ABPersonCreate();
    CFErrorRef error = NULL;
    ABRecordSetValue(aBusiness, kABPersonOrganizationProperty, (__bridge CFTypeRef)(businessName), &error);
    ABRecordSetValue(aBusiness, kABPersonKindProperty, kABPersonKindOrganization, &error);

    if (error != NULL)
    {
        NSLog(@"error during creation of record");
        error = NULL;
    }

    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);

    BDSIPassbookViewController * __weak weakSelf = self;  // avoid capturing self in the block
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef anError)
         {
            if (granted)
            {
                BOOL isAdded = ABAddressBookAddRecord (addressBook, aBusiness, &anError);
                
                if(isAdded)
                {
                    ABAddressBookSave(addressBook, &anError);
                    
//                    NSDictionary *addressDict = [NSDictionary dictionaryWithDictionary:(__bridge NSDictionary *)(ABRecordCopyValue(addressBook, kABMultiDictionaryPropertyType))];
//                    NSDictionary *addressDict = (__bridge NSDictionary *)aBusiness;
//                    NSString *streetName = @"Toronto Street";
//                    NSDictionary *addressDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Apple", @"name", @"Infinte Loop", @"thoroughfare", @"Cupertino", @"locality", nil];
/*
                    NSDictionary *addressDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       @"Toronto", @"City", 
                                                       @"Canada", @"Country", 
                                                       @"CA", @"CountryCode", 
//                                                       FormattedAddressLines =     (
//                                                                                    "301 Front St W",
//                                                                                    "Toronto ON M5V 2T6",
//                                                                                    Canada
//                                                                                    );
                                                       @"Ontario", @"State", 
                                                       @"301 Front St W", @"Street", 
                                                       @"Toronto", @"SubAdministrativeArea",
//                                                       @"Entertainment District", @"SubLocality",
                                                       @"301", @"SubThoroughfare",
                                                       @"Front St W", @"Thoroughfare", 
//                                                       @"M5V 2T6", @"ZIP",
                                                       nil];
*/
                    
                    NSDictionary *addressDict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                                 @"AreasOfInterest", @[@"National Park"],
                                                 @"Apple", @"Name",
//                                                 @"New York City", @"City",
//                                                 @"Canada", @"Country",
                                                 @"US", @"CountryCode",
//                                                 @"Utah", @"State",
//                                                 @"301 Front St W", @"Street",
//                                                 @"Toronto", @"SubAdministrativeArea",
                                                 //                                                       @"Entertainment District", @"SubLocality",
//                                                 @"301", @"SubThoroughfare",
//                                                 @"Front St W", @"Thoroughfare",
                                                 //                                                       @"M5V 2T6", @"ZIP",
                                                 nil];

                    
                    
//                    [geocoderSearch geocodeAddressString:@"301 Front Street West  Toronto, ON M5V 2T6" completionHandler:^(NSArray *placemarks, NSError *error)
                    [geocoderSearch geocodeAddressDictionary:addressDict completionHandler:^(NSArray *placemarks, NSError *error)
                         {
                             if (error)
                             {
//                                 NSLog(@"Geocode for businesses on %@ ", streetName);
                                 NSLog(@"Geocode for businesses named [ %@ ] failed with error: %@", businessName, error);
                                 [weakSelf displayError:error];
                                 return;
                             }
                             
                             // store these placemarks for sending to the pass_server later
                             //DARREN
                             
                             NSLog(@"While looking for [ %@ ], we received these placemarks: %@", businessName, placemarks);
                             [weakSelf displayPlacemarks:placemarks usingImage:[UIImage imageNamed:@"pushpin.png"]];
                             
                             
                         }
                     ];
                    
                    
                }
                
//                [weakSelf.mapView set]
            }
         });
}

#pragma mark - CoreLocation Delegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // if the location is older than 30s ignore
    if (fabs([newLocation.timestamp timeIntervalSinceDate:[NSDate date]]) > 30)
    {
        return;
    }
    
    // after recieving a location, stop updating
    //[self stopUpdatingCurrentLocation];
    
    [self showCurrentLocation:newLocation];
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

#pragma mark - MapViewDelegateMethods
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    NSString *reuseID = @"anno";
    
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseID];
    if (annotationView == nil)
    {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseID];
        [annotationView setImage:[UIImage imageNamed:@"pushpin"]];
    }
    
    return annotationView;
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    [self.buttonNextStep setEnabled:YES];
}

#pragma mark - Utility methods
// plot one or more placemarks onto the map
- (void)displayPlacemarks:(NSArray *)placemarks usingImage:(UIImage *)image
{
    for (CLPlacemark *placemark in placemarks)
    {
        NSLog(@"Placemark: %@", placemark.addressDictionary);

        // create an MKAnnotation, then MKAnnotationView, then add to the map
        BDSIMapPin *mapPin = [[BDSIMapPin alloc] init];
        [mapPin setPlacemark:placemark];
        
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:mapPin reuseIdentifier:nil];

        // if an image was sent, create an AnnotationView that uses it
        if (image)
        {
            [annotationView setImage:image];
        }
        
        [self.mapView addAnnotation:annotationView.annotation];
    }
    
    [self.activityIndicator stopAnimating];
}

// display a given NSError in an UIAlertView
- (void)displayError:(NSError*)error
{
    dispatch_async(dispatch_get_main_queue(),^ {
        
        NSString *message;
        switch ([error code])
        {
            case kCLErrorGeocodeFoundNoResult:
                message = @"No results to display ~ kCLErrorGeocodeFoundNoResult";
                break;
            case kCLErrorGeocodeCanceled: message = @"kCLErrorGeocodeCanceled";
                break;
            case kCLErrorGeocodeFoundPartialResult: message = @"kCLErrorGeocodeFoundNoResult+Partial";
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
