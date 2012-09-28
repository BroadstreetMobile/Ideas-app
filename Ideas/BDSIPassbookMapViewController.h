//
//  BDSIPassbookMapViewController.h
//  Ideas
//
//  Created by Darren Baptiste on 2012-09-26.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface BDSIPassbookMapViewController : UIViewController
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITextField *lattitudeTextField;
@property (weak, nonatomic) IBOutlet UITextField *longitudeTextField;


@property (nonatomic,strong) NSString *userEmailAddress;
@end
