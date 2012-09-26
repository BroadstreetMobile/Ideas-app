//
//  BDSIPassbookViewController.h
//  Ideas
//
//  Created by Darren Baptiste on 2012-09-12.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface BDSIPassbookViewController : UIViewController <UIWebViewDelegate>
@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
